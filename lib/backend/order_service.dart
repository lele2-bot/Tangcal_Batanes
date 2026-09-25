// Order flow shared by the Customer, Restaurant and Rider sides.
//
// Lifecycle of a document in `Orders`:
//
//   Pending ──(restaurant accepts)──▶ Cooking ──(restaurant: food ready)──▶
//   Ready for Pickup ──(rider accepts)──▶ On Delivery ──(rider)──▶ Delivered
//
//   Pending ──(customer cancels / restaurant declines)──▶ Cancelled
//
// Every status change runs inside a Firestore transaction so two riders can't
// grab the same order and a stale screen can't skip or repeat a step.
//
// Ownership fields on each order (all Firebase Auth uids / doc ids as Strings):
//   customer_id          uid of the customer who placed it
//   restaurant_id        id of the Restaurants document it was ordered from
//   restaurant_owner_id  uid of that restaurant's owner
//   rider_id             uid of the assigned rider ('' until a rider accepts)

import 'package:flutter/material.dart';

import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

class OrderStatus {
  static const pending = 'Pending';
  static const cooking = 'Cooking';
  static const readyForPickup = 'Ready for Pickup';
  static const onDelivery = 'On Delivery';
  static const delivered = 'Delivered';
  static const cancelled = 'Cancelled';

  static const active = [pending, cooking, readyForPickup, onDelivery];
  static const finished = [delivered, cancelled];

  static bool isActive(String status) => active.contains(status);

  static Color color(String status) {
    switch (status) {
      case pending:
        return const Color(0xFFE0A100);
      case cooking:
        return const Color(0xFFD9822B);
      case readyForPickup:
        return const Color(0xFF2B7BD9);
      case onDelivery:
        return const Color(0xFF7A4BD9);
      case delivered:
        return const Color(0xFF2E9E5B);
      case cancelled:
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFF888888);
    }
  }
}

/// Flat delivery fee added to every order, in pesos. Change it here only:
/// the cart screen and checkout both read this value.
const double kDeliveryFee = 20.0;

// Cart helpers. The cart is stored as one entry per unit in
// FFAppState().myCart (product refs) with a parallel list of unit prices in
// FFAppState().myCartSummary, so both must change together.

void cartAddOne(ProductsRecord product) {
  FFAppState().update(() {
    FFAppState().addToMyCart(product.reference);
    FFAppState().addToMyCartSummary(product.price);
  });
}

void cartRemoveOne(ProductsRecord product) {
  FFAppState().update(() {
    FFAppState().removeFromMyCart(product.reference);
    FFAppState().removeFromMyCartSummary(product.price);
  });
}

void cartClear() {
  FFAppState().update(() {
    FFAppState().myCart = [];
    FFAppState().myCartSummary = [];
    FFAppState().cartTotal = 0.0;
  });
}

const _cartOwnerKey = 'tangcal_cart_owner_uid';

/// The cart is saved on the device, so tie it to the signed-in account: when a
/// different user (or nobody) is signed in, the previous user's cart is
/// cleared. Called from main.dart whenever the auth user changes.
void bindCartToUser(String uid) {
  final prefs = FFAppState().prefs;
  final owner = prefs.getString(_cartOwnerKey) ?? '';
  if (owner != uid) {
    cartClear();
    prefs.setString(_cartOwnerKey, uid);
  }
}

/// Total number of units in the cart (for the cart badge).
int cartItemCount() => FFAppState().myCart.length;

/// Distinct products in the cart with how many of each, in first-added order.
Map<DocumentReference, int> cartQuantities() {
  final quantities = <DocumentReference, int>{};
  for (final ref in FFAppState().myCart) {
    quantities[ref] = (quantities[ref] ?? 0) + 1;
  }
  return quantities;
}

/// Removes every unit of [ref] from the cart (e.g. a deleted product).
void cartRemoveProduct(DocumentReference ref, {double? unitPrice}) {
  FFAppState().update(() {
    final count = FFAppState().myCart.where((r) => r == ref).length;
    FFAppState().myCart = FFAppState().myCart.where((r) => r != ref).toList();
    if (unitPrice != null) {
      for (var i = 0; i < count; i++) {
        FFAppState().removeFromMyCartSummary(unitPrice);
      }
    }
  });
}

/// One product in the cart, priced from the live Products document.
class CartLine {
  CartLine(this.ref, this.product, this.quantity);

  final DocumentReference ref;

  /// Null when the product was deleted.
  final ProductsRecord? product;
  final int quantity;

  bool get available =>
      product != null && (!product!.hasIsAvailable() || product!.isAvailable);
  String get name => product?.productName ?? 'Unavailable item';
  double get unitPrice => product?.price ?? 0;
  double get lineTotal => unitPrice * quantity;
}

double cartLinesSubtotal(Iterable<CartLine> lines) => lines
    .where((l) => l.available)
    .fold<double>(0, (total, l) => total + l.lineTotal);

/// Money in the app's display format, e.g. ₱250.00.
String peso(double amount) => '₱${amount.toStringAsFixed(2)}';

/// An error whose message is safe to show to the user.
class OrderException implements Exception {
  OrderException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The Restaurants document owned by the signed-in user, if any.
Future<RestaurantsRecord?> getMyRestaurant() async {
  final userRef = currentUserReference;
  if (userRef == null) {
    return null;
  }
  final result = await queryRestaurantsRecordOnce(
    queryBuilder: (q) => q.where('owner_id', isEqualTo: userRef),
    limit: 1,
  );
  return result.isEmpty ? null : result.first;
}

/// Creates the role profile (Customers / Restaurants / Rider) the first time,
/// and updates the same document afterwards instead of adding duplicates.
Future<DocumentReference> upsertRoleProfile({
  required CollectionReference collection,
  required String ownerField,
  required Map<String, dynamic> data,
}) async {
  final existing = await collection
      .where(ownerField, isEqualTo: currentUserReference)
      .limit(1)
      .get();
  if (existing.docs.isNotEmpty) {
    final ref = existing.docs.first.reference;
    await ref.update(data);
    return ref;
  }
  final ref = collection.doc();
  await ref.set(data);
  return ref;
}

/// Turns the local cart into an order the restaurant can see.
///
/// Writes the `Orders` document and its `Orders_Items` in one batch, then
/// clears the cart. Throws [OrderException] with a user-facing message when
/// the cart can't be ordered.
Future<DocumentReference> placeOrderFromCart({
  required String deliveryAddress,
  String specialInstructions = '',
}) async {
  if (currentUserUid.isEmpty) {
    throw OrderException('Please log in before checking out.');
  }
  final quantities = cartQuantities();
  if (quantities.isEmpty) {
    throw OrderException('Your cart is empty.');
  }
  if (deliveryAddress.trim().isEmpty) {
    throw OrderException('Please enter your delivery address.');
  }

  final products = <ProductsRecord>[];
  for (final ref in quantities.keys) {
    final snap = await ref.get();
    if (!snap.exists) {
      throw OrderException(
          'An item in your cart is no longer available. Please remove it and try again.');
    }
    products.add(ProductsRecord.fromSnapshot(snap));
  }

  final unavailable = products.where((p) => p.hasIsAvailable() && !p.isAvailable);
  if (unavailable.isNotEmpty) {
    throw OrderException(
        '"${unavailable.first.productName}" is currently unavailable. Please remove it from your cart.');
  }

  final restaurantRefs = products.map((p) => p.restaurantId).toSet();
  if (restaurantRefs.contains(null)) {
    throw OrderException(
        'An item in your cart is not linked to a restaurant. Please remove it and try again.');
  }
  if (restaurantRefs.length > 1) {
    throw OrderException(
        'Your cart has items from more than one restaurant. Please order from one restaurant at a time.');
  }

  final restaurantSnap = await restaurantRefs.first!.get();
  if (!restaurantSnap.exists) {
    throw OrderException(
        'This restaurant is no longer available. Please clear your cart and order from another restaurant.');
  }
  final restaurant = RestaurantsRecord.fromSnapshot(restaurantSnap);
  final ownerUid = restaurant.ownerId?.id ?? '';
  if (ownerUid.isEmpty) {
    throw OrderException(
        'This restaurant is not set up to receive orders yet.');
  }

  // Priced from the current menu, not the prices saved in the cart.
  final subtotal = products.fold<double>(
      0, (total, p) => total + p.price * quantities[p.reference]!);

  final batch = FirebaseFirestore.instance.batch();
  final orderRef = OrdersRecord.collection.doc();
  batch.set(orderRef, {
    ...createOrdersRecordData(
      customerId: currentUserUid,
      customerName: currentUserDisplayName,
      restaurantId: restaurant.reference.id,
      restaurantOwnerId: ownerUid,
      restaurantName: restaurant.restaurantName,
      restaurantAddress: restaurant.address,
      riderId: '',
      deliverAddress: deliveryAddress.trim(),
      specialInstructions: specialInstructions.trim(),
      subtotal: subtotal,
      deliveryFee: kDeliveryFee,
      totalAmount: subtotal + kDeliveryFee,
      orderStatus: OrderStatus.pending,
    ),
    'order_date': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });
  for (final product in products) {
    final qty = quantities[product.reference]!;
    batch.set(
      OrdersItemsRecord.createDoc(orderRef),
      createOrdersItemsRecordData(
        orderId: orderRef.id,
        productId: product.reference,
        quantity: qty,
        unitPrice: product.price,
        subTotal: product.price * qty,
      ),
    );
  }
  await batch.commit();

  cartClear();
  return orderRef;
}

/// Moves an order from one of [from] to [to], after [check] (if given)
/// approves the current document.
Future<void> _changeStatus(
  DocumentReference orderRef, {
  required List<String> from,
  required String to,
  String? Function(OrdersRecord order)? check,
  Map<String, dynamic> extra = const {},
}) async {
  final problem =
      await FirebaseFirestore.instance.runTransaction<String?>((tx) async {
    final snap = await tx.get(orderRef);
    if (!snap.exists) {
      return 'This order no longer exists.';
    }
    final order = OrdersRecord.fromSnapshot(snap);
    if (!from.contains(order.orderStatus)) {
      return 'This order is already "${order.orderStatus}".';
    }
    final problem = check?.call(order);
    if (problem != null) {
      return problem;
    }
    tx.update(orderRef, {
      'order_status': to,
      'updated_at': FieldValue.serverTimestamp(),
      ...extra,
    });
    return null;
  });
  if (problem != null) {
    throw OrderException(problem);
  }
}

String? _mustOwnRestaurantOrder(OrdersRecord order) =>
    order.restaurantOwnerId == currentUserUid
        ? null
        : 'This order belongs to another restaurant.';

// Restaurant actions.

Future<void> restaurantAcceptOrder(DocumentReference orderRef) => _changeStatus(
      orderRef,
      from: [OrderStatus.pending],
      to: OrderStatus.cooking,
      check: _mustOwnRestaurantOrder,
    );

Future<void> restaurantDeclineOrder(DocumentReference orderRef) =>
    _changeStatus(
      orderRef,
      from: [OrderStatus.pending],
      to: OrderStatus.cancelled,
      check: _mustOwnRestaurantOrder,
      extra: {'cancelled_by': 'restaurant'},
    );

Future<void> restaurantMarkReady(DocumentReference orderRef) => _changeStatus(
      orderRef,
      from: [OrderStatus.cooking],
      to: OrderStatus.readyForPickup,
      check: _mustOwnRestaurantOrder,
    );

// Rider actions.

Future<void> riderAcceptOrder(DocumentReference orderRef) => _changeStatus(
      orderRef,
      from: [OrderStatus.readyForPickup],
      to: OrderStatus.onDelivery,
      check: (order) => order.riderId.isEmpty
          ? null
          : 'Another rider already accepted this order.',
      extra: {
        'rider_id': currentUserUid,
        'rider_name': currentUserDisplayName,
      },
    );

Future<void> riderMarkDelivered(DocumentReference orderRef) => _changeStatus(
      orderRef,
      from: [OrderStatus.onDelivery],
      to: OrderStatus.delivered,
      check: (order) => order.riderId == currentUserUid
          ? null
          : 'This delivery is assigned to another rider.',
      extra: {'delivered_at': FieldValue.serverTimestamp()},
    );

// Customer actions.

Future<void> customerCancelOrder(DocumentReference orderRef) => _changeStatus(
      orderRef,
      from: [OrderStatus.pending],
      to: OrderStatus.cancelled,
      check: (order) => order.customerId == currentUserUid
          ? null
          : 'This is not your order.',
      extra: {'cancelled_by': 'customer'},
    );

/// Runs an order action from a button, showing the result in a SnackBar.
Future<bool> runOrderAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (successMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    }
    return true;
  } on OrderException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on FirebaseException catch (e) {
    messenger.showSnackBar(SnackBar(
      content: Text(e.code == 'permission-denied'
          ? 'You are not allowed to do that. Check that the latest Firestore rules are deployed.'
          : 'Something went wrong: ${e.message ?? e.code}'),
    ));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
  }
  return false;
}
