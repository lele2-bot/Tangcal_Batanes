// Runs the TANGCAL order flow against firebase/firestore.rules in the local
// Firestore emulator, using the same writes the Flutter app makes
// (lib/backend/order_service.dart). Project id is a demo- id: no real project.
import fs from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, setDoc, getDoc, updateDoc, writeBatch, collection, query, where,
  orderBy, getDocs, runTransaction, serverTimestamp,
} from 'firebase/firestore';

const rulesPath = process.argv[2];
const env = await initializeTestEnvironment({
  projectId: 'demo-tangcal',
  firestore: { rules: fs.readFileSync(rulesPath, 'utf8'), host: '127.0.0.1', port: 8080 },
});

let passed = 0;
const failures = [];
async function check(name, fn) {
  try {
    await fn();
    passed++;
    console.log('  PASS  ' + name);
  } catch (e) {
    failures.push(name);
    console.log('  FAIL  ' + name + '\n        ' + (e && e.message ? e.message.split('\n')[0] : e));
  }
}

// ---- Seed data (rules bypassed) ----
await env.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  const u = (id) => doc(db, 'users', id);
  for (const [id, role] of [['cust', 'Customer'], ['cust2', 'Customer'],
    ['owner', 'Business Owner'], ['owner2', 'Business Owner'],
    ['rider', 'Delivery Rider'], ['rider2', 'Delivery Rider']]) {
    await setDoc(u(id), { uid: id, role, display_name: id, email: id + '@test.local' });
  }
  await setDoc(doc(db, 'Restaurants', 'r1'), { owner_id: u('owner'), restaurant_name: 'Takoballs', address: 'Basco' });
  await setDoc(doc(db, 'Restaurants', 'r2'), { owner_id: u('owner2'), restaurant_name: 'Other', address: 'Ivana' });
  await setDoc(doc(db, 'Products', 'p1'), { restaurant_id: doc(db, 'Restaurants', 'r1'), product_name: 'Takopizza', price: 250, is_available: true });
  await setDoc(doc(db, 'Customers', 'c1'), { customer_id: u('cust'), delivery_address: 'Home', first_name: 'C' });
});

const as = (uid) => env.authenticatedContext(uid).firestore();
const cust = as('cust'), cust2 = as('cust2'), owner = as('owner'), owner2 = as('owner2');
const rider = as('rider'), rider2 = as('rider2');
const anon = env.unauthenticatedContext().firestore();

// Mirrors placeOrderFromCart(): one batch = order + its items.
async function placeOrder(db, orderId, overrides = {}) {
  const batch = writeBatch(db);
  const orderRef = doc(db, 'Orders', orderId);
  batch.set(orderRef, {
    customer_id: 'cust', customer_name: 'cust', restaurant_id: 'r1',
    restaurant_owner_id: 'owner', restaurant_name: 'Takoballs', restaurant_address: 'Basco',
    rider_id: '', deliver_address: 'Home', special_instructions: '',
    subtotal: 500, delivery_fee: 20, total_amount: 520, order_status: 'Pending',
    order_date: serverTimestamp(), updated_at: serverTimestamp(), ...overrides,
  });
  batch.set(doc(db, 'Orders', orderId, 'Orders_Items', 'i1'), {
    order_id: orderId, product_id: doc(db, 'Products', 'p1'), quantity: 2, unit_price: 250, sub_total: 500,
  });
  await batch.commit();
}

// Mirrors _changeStatus(): transaction read + update.
async function changeStatus(db, orderId, from, to, extra = {}) {
  await runTransaction(db, async (tx) => {
    const ref = doc(db, 'Orders', orderId);
    const snap = await tx.get(ref);
    if (!snap.exists() || snap.data().order_status !== from) throw new Error('bad state ' + (snap.exists() && snap.data().order_status));
    tx.update(ref, { order_status: to, updated_at: serverTimestamp(), ...extra });
  });
}

const myOrders = (db, field, uid) => getDocs(query(collection(db, 'Orders'), where(field, '==', uid), orderBy('order_date', 'desc')));

console.log('\nCUSTOMER checkout');
await check('customer places order + items in one batch', () => assertSucceeds(placeOrder(cust, 'o1')));
await check('cannot place order as someone else', () => assertFails(placeOrder(cust2, 'x1')));
await check('cannot spoof restaurant owner', () => assertFails(placeOrder(cust, 'x2', { restaurant_owner_id: 'owner2' })));
await check('cannot create order already Cooking', () => assertFails(placeOrder(cust, 'x3', { order_status: 'Cooking' })));
await check('logged-out user cannot order', () => assertFails(placeOrder(anon, 'x4')));
await check('customer lists own orders (My Orders query)', async () => {
  const r = await assertSucceeds(myOrders(cust, 'customer_id', 'cust'));
  if (r.size !== 1) throw new Error('expected 1 order, got ' + r.size);
});
await check('customer reads order items', () => assertSucceeds(getDocs(collection(cust, 'Orders', 'o1', 'Orders_Items'))));
await check('another customer cannot read the order', () => assertFails(getDoc(doc(cust2, 'Orders', 'o1'))));

console.log('\nBUSINESS OWNER');
await check('owner lists own restaurant orders', async () => {
  const r = await assertSucceeds(myOrders(owner, 'restaurant_owner_id', 'owner'));
  if (r.size !== 1) throw new Error('expected 1, got ' + r.size);
});
await check('other owner cannot read it', () => assertFails(getDoc(doc(owner2, 'Orders', 'o1'))));
await check('other owner cannot accept it', () => assertFails(changeStatus(owner2, 'o1', 'Pending', 'Cooking')));
await check('customer cannot accept own order', () => assertFails(changeStatus(cust, 'o1', 'Pending', 'Cooking')));
await check('owner cannot skip Pending -> Ready', () => assertFails(changeStatus(owner, 'o1', 'Pending', 'Ready for Pickup')));
await check('owner accepts: Pending -> Cooking', () => assertSucceeds(changeStatus(owner, 'o1', 'Pending', 'Cooking')));
await check('customer cannot cancel once Cooking', () => assertFails(changeStatus(cust, 'o1', 'Cooking', 'Cancelled', { cancelled_by: 'customer' })));
await check('rider cannot see order while Cooking', () => assertFails(getDoc(doc(rider, 'Orders', 'o1'))));
await check('owner marks ready: Cooking -> Ready for Pickup', () => assertSucceeds(changeStatus(owner, 'o1', 'Cooking', 'Ready for Pickup')));

console.log('\nRIDER');
await check('rider lists Ready for Pickup orders', async () => {
  const r = await assertSucceeds(getDocs(query(collection(rider, 'Orders'), where('order_status', '==', 'Ready for Pickup'), orderBy('order_date'))));
  if (r.size !== 1) throw new Error('expected 1, got ' + r.size);
});
await check('customer cannot list all ready orders', () => assertFails(getDocs(query(collection(cust, 'Orders'), where('order_status', '==', 'Ready for Pickup'), orderBy('order_date')))));
await check('owner cannot claim delivery', () => assertFails(changeStatus(owner, 'o1', 'Ready for Pickup', 'On Delivery', { rider_id: 'owner', rider_name: 'x' })));
await check('rider cannot assign it to another rider', () => assertFails(changeStatus(rider, 'o1', 'Ready for Pickup', 'On Delivery', { rider_id: 'rider2', rider_name: 'x' })));
await check('rider accepts: Ready -> On Delivery (assigned)', () => assertSucceeds(changeStatus(rider, 'o1', 'Ready for Pickup', 'On Delivery', { rider_id: 'rider', rider_name: 'rider' })));
await check('second rider cannot claim it', () => assertFails(changeStatus(rider2, 'o1', 'Ready for Pickup', 'On Delivery', { rider_id: 'rider2', rider_name: 'rider2' })));
await check('rider lists own deliveries', async () => {
  const r = await assertSucceeds(myOrders(rider, 'rider_id', 'rider'));
  if (r.size !== 1) throw new Error('expected 1, got ' + r.size);
});
await check('rider reads the order items', () => assertSucceeds(getDocs(collection(rider, 'Orders', 'o1', 'Orders_Items'))));
await check('other rider cannot mark delivered', () => assertFails(changeStatus(rider2, 'o1', 'On Delivery', 'Delivered', { delivered_at: serverTimestamp() })));
await check('assigned rider marks Delivered', () => assertSucceeds(changeStatus(rider, 'o1', 'On Delivery', 'Delivered', { delivered_at: serverTimestamp() })));
await check('customer sees final status Delivered', async () => {
  const s = await assertSucceeds(getDoc(doc(cust, 'Orders', 'o1')));
  if (s.data().order_status !== 'Delivered') throw new Error('status is ' + s.data().order_status);
});

console.log('\nCANCELLATION');
await check('customer places second order', () => assertSucceeds(placeOrder(cust, 'o2')));
await check('customer cancels while Pending', () => assertSucceeds(changeStatus(cust, 'o2', 'Pending', 'Cancelled', { cancelled_by: 'customer' })));
await check('customer places third order', () => assertSucceeds(placeOrder(cust, 'o3')));
await check('owner declines Pending order', () => assertSucceeds(changeStatus(owner, 'o3', 'Pending', 'Cancelled', { cancelled_by: 'restaurant' })));

console.log('\nPROFILES, PHOTOS, PRODUCTS');
const photo = 'data:image/jpeg;base64,' + 'A'.repeat(200000);
await check('user saves own profile photo (200 KB data URL)', () => assertSucceeds(updateDoc(doc(cust, 'users', 'cust'), { photo_url: photo })));
await check('user cannot change another user\'s photo', () => assertFails(updateDoc(doc(cust, 'users', 'cust2'), { photo_url: photo })));
await check('owner updates own restaurant logo', () => assertSucceeds(updateDoc(doc(owner, 'Restaurants', 'r1'), { logo: photo })));
await check('other owner cannot change that logo', () => assertFails(updateDoc(doc(owner2, 'Restaurants', 'r1'), { logo: photo })));
await check('owner adds product with photo to own restaurant', () => assertSucceeds(setDoc(doc(owner, 'Products', 'p2'), { restaurant_id: doc(owner, 'Restaurants', 'r1'), product_name: 'Fries', price: 99, is_available: true, prod_img: photo })));
await check('owner cannot add product to another restaurant', () => assertFails(setDoc(doc(owner, 'Products', 'p3'), { restaurant_id: doc(owner, 'Restaurants', 'r2'), product_name: 'X', price: 1 })));
await check('owner edits own product photo', () => assertSucceeds(updateDoc(doc(owner, 'Products', 'p2'), { prod_img: photo })));
await check('customer reads own Customers profile', () => assertSucceeds(getDocs(query(collection(cust, 'Customers'), where('customer_id', '==', doc(cust, 'users', 'cust'))))));
await check('customer updates own delivery address', () => assertSucceeds(updateDoc(doc(cust, 'Customers', 'c1'), { customer_id: doc(cust, 'users', 'cust'), delivery_address: 'New' })));
await check('another customer cannot edit it', () => assertFails(updateDoc(doc(cust2, 'Customers', 'c1'), { delivery_address: 'Hacked' })));

await env.cleanup();
console.log(`\n${passed} passed, ${failures.length} failed`);
process.exit(failures.length ? 1 : 0);
