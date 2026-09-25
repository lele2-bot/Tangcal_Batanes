const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
});

// ---------------------------------------------------------------------------
// Order push notifications.
//
// The app stores each device's FCM token at users/{uid}/fcm_tokens/{token}
// (lib/backend/push_notifications.dart). These triggers mirror the order flow
// in lib/backend/order_service.dart:
//
//   new order                 -> restaurant owner
//   Cooking / Ready / On Delivery / Delivered / Cancelled -> customer
//   Ready for Pickup          -> every rider
//   cancelled by the customer -> restaurant owner
// ---------------------------------------------------------------------------

const db = () => admin.firestore();

async function tokensForUser(uid) {
  if (!uid) return [];
  const snap = await db().collection(`users/${uid}/fcm_tokens`).get();
  return snap.docs.map((d) => ({ token: d.id, ref: d.ref }));
}

async function tokensForRole(role) {
  const users = await db().collection("users").where("role", "==", role).get();
  const lists = await Promise.all(users.docs.map((u) => tokensForUser(u.id)));
  return lists.flat();
}

async function send(entries, title, body, data) {
  if (entries.length === 0) return;
  const tokens = entries.map((e) => e.token);
  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: data || {},
    android: { priority: "high" },
    apns: { payload: { aps: { sound: "default" } } },
  });
  // Remove tokens for uninstalled apps / signed-out devices.
  const stale = [];
  response.responses.forEach((r, i) => {
    const code = r.error && r.error.code;
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      stale.push(entries[i].ref.delete());
    }
  });
  await Promise.all(stale);
}

function shortId(orderId) {
  return orderId.substring(0, 6).toUpperCase();
}

function peso(amount) {
  return "P" + Number(amount || 0).toFixed(2);
}

exports.onOrderCreated = functions.firestore
  .document("Orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const id = shortId(context.params.orderId);
    await send(
      await tokensForUser(order.restaurant_owner_id),
      "New order #" + id,
      `${order.customer_name || "A customer"} ordered ${peso(order.total_amount)}. Tap to accept it.`,
      { orderId: context.params.orderId, type: "new_order" }
    );
  });

const CUSTOMER_MESSAGES = {
  "Cooking": (o) => `${o.restaurant_name || "The restaurant"} accepted your order and is preparing it.`,
  "Ready for Pickup": () => "Your food is ready and waiting for a rider.",
  "On Delivery": (o) => `${o.rider_name || "A rider"} picked up your order and is on the way.`,
  "Delivered": () => "Your order was delivered. Enjoy your meal!",
  "Cancelled": (o) => o.cancelled_by === "customer"
    ? null // they did it themselves
    : `${o.restaurant_name || "The restaurant"} could not take your order, so it was cancelled.`,
};

exports.onOrderStatusChanged = functions.firestore
  .document("Orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.order_status === after.order_status) return;

    const orderId = context.params.orderId;
    const id = shortId(orderId);
    const status = after.order_status;
    const data = { orderId, status, type: "status_change" };
    const jobs = [];

    const message = CUSTOMER_MESSAGES[status] && CUSTOMER_MESSAGES[status](after);
    if (message) {
      jobs.push(
        tokensForUser(after.customer_id).then((t) =>
          send(t, `Order #${id}: ${status}`, message, data)
        )
      );
    }

    if (status === "Ready for Pickup" && !after.rider_id) {
      jobs.push(
        tokensForRole("Delivery Rider").then((t) =>
          send(
            t,
            "Delivery request #" + id,
            `Pickup at ${after.restaurant_name || "a restaurant"}. First rider to accept gets it.`,
            data
          )
        )
      );
    }

    // The customer cancelled: let the restaurant know.
    if (status === "Cancelled" && after.cancelled_by === "customer") {
      jobs.push(
        tokensForUser(after.restaurant_owner_id).then((t) =>
          send(t, `Order #${id} cancelled`, "This order was cancelled.", data)
        )
      );
    }

    await Promise.all(jobs);
  });
