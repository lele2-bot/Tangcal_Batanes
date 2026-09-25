import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrdersRecord extends FirestoreRecord {
  OrdersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "customer_id" field.
  String? _customerId;
  String get customerId => _customerId ?? '';
  bool hasCustomerId() => _customerId != null;

  // "restaurant_id" field.
  String? _restaurantId;
  String get restaurantId => _restaurantId ?? '';
  bool hasRestaurantId() => _restaurantId != null;

  // "rider_id" field.
  String? _riderId;
  String get riderId => _riderId ?? '';
  bool hasRiderId() => _riderId != null;

  // "order_date" field.
  DateTime? _orderDate;
  DateTime? get orderDate => _orderDate;
  bool hasOrderDate() => _orderDate != null;

  // "deliver_address" field.
  String? _deliverAddress;
  String get deliverAddress => _deliverAddress ?? '';
  bool hasDeliverAddress() => _deliverAddress != null;

  // "total_amount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  // "order_status" field.
  String? _orderStatus;
  String get orderStatus => _orderStatus ?? '';
  bool hasOrderStatus() => _orderStatus != null;

  // "special_instructions" field.
  String? _specialInstructions;
  String get specialInstructions => _specialInstructions ?? '';
  bool hasSpecialInstructions() => _specialInstructions != null;

  // "customer_name" field.
  String? _customerName;
  String get customerName => _customerName ?? '';
  bool hasCustomerName() => _customerName != null;

  // "restaurant_owner_id" field (uid of the restaurant owner).
  String? _restaurantOwnerId;
  String get restaurantOwnerId => _restaurantOwnerId ?? '';
  bool hasRestaurantOwnerId() => _restaurantOwnerId != null;

  // "restaurant_name" field.
  String? _restaurantName;
  String get restaurantName => _restaurantName ?? '';
  bool hasRestaurantName() => _restaurantName != null;

  // "restaurant_address" field.
  String? _restaurantAddress;
  String get restaurantAddress => _restaurantAddress ?? '';
  bool hasRestaurantAddress() => _restaurantAddress != null;

  // "rider_name" field.
  String? _riderName;
  String get riderName => _riderName ?? '';
  bool hasRiderName() => _riderName != null;

  // "subtotal" field (items only, before delivery fee).
  double? _subtotal;
  double get subtotal => _subtotal ?? 0.0;
  bool hasSubtotal() => _subtotal != null;

  // "delivery_fee" field.
  double? _deliveryFee;
  double get deliveryFee => _deliveryFee ?? 0.0;
  bool hasDeliveryFee() => _deliveryFee != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "delivered_at" field.
  DateTime? _deliveredAt;
  DateTime? get deliveredAt => _deliveredAt;
  bool hasDeliveredAt() => _deliveredAt != null;

  void _initializeFields() {
    _customerId = snapshotData['customer_id'] as String?;
    _restaurantId = snapshotData['restaurant_id'] as String?;
    _riderId = snapshotData['rider_id'] as String?;
    _orderDate = snapshotData['order_date'] as DateTime?;
    _deliverAddress = snapshotData['deliver_address'] as String?;
    _totalAmount = castToType<double>(snapshotData['total_amount']);
    _orderStatus = snapshotData['order_status'] as String?;
    _specialInstructions = snapshotData['special_instructions'] as String?;
    _customerName = snapshotData['customer_name'] as String?;
    _restaurantOwnerId = snapshotData['restaurant_owner_id'] as String?;
    _restaurantName = snapshotData['restaurant_name'] as String?;
    _restaurantAddress = snapshotData['restaurant_address'] as String?;
    _riderName = snapshotData['rider_name'] as String?;
    _subtotal = castToType<double>(snapshotData['subtotal']);
    _deliveryFee = castToType<double>(snapshotData['delivery_fee']);
    _updatedAt = snapshotData['updated_at'] as DateTime?;
    _deliveredAt = snapshotData['delivered_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Orders');

  static Stream<OrdersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OrdersRecord.fromSnapshot(s));

  static Future<OrdersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OrdersRecord.fromSnapshot(s));

  static OrdersRecord fromSnapshot(DocumentSnapshot snapshot) => OrdersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrdersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrdersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrdersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrdersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrdersRecordData({
  String? customerId,
  String? restaurantId,
  String? riderId,
  DateTime? orderDate,
  String? deliverAddress,
  double? totalAmount,
  String? orderStatus,
  String? specialInstructions,
  String? customerName,
  String? restaurantOwnerId,
  String? restaurantName,
  String? restaurantAddress,
  String? riderName,
  double? subtotal,
  double? deliveryFee,
  DateTime? updatedAt,
  DateTime? deliveredAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'customer_id': customerId,
      'restaurant_id': restaurantId,
      'rider_id': riderId,
      'order_date': orderDate,
      'deliver_address': deliverAddress,
      'total_amount': totalAmount,
      'order_status': orderStatus,
      'special_instructions': specialInstructions,
      'customer_name': customerName,
      'restaurant_owner_id': restaurantOwnerId,
      'restaurant_name': restaurantName,
      'restaurant_address': restaurantAddress,
      'rider_name': riderName,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'updated_at': updatedAt,
      'delivered_at': deliveredAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class OrdersRecordDocumentEquality implements Equality<OrdersRecord> {
  const OrdersRecordDocumentEquality();

  @override
  bool equals(OrdersRecord? e1, OrdersRecord? e2) {
    return e1?.customerId == e2?.customerId &&
        e1?.restaurantId == e2?.restaurantId &&
        e1?.riderId == e2?.riderId &&
        e1?.orderDate == e2?.orderDate &&
        e1?.deliverAddress == e2?.deliverAddress &&
        e1?.totalAmount == e2?.totalAmount &&
        e1?.orderStatus == e2?.orderStatus &&
        e1?.specialInstructions == e2?.specialInstructions &&
        e1?.customerName == e2?.customerName &&
        e1?.restaurantOwnerId == e2?.restaurantOwnerId &&
        e1?.restaurantName == e2?.restaurantName &&
        e1?.restaurantAddress == e2?.restaurantAddress &&
        e1?.riderName == e2?.riderName &&
        e1?.subtotal == e2?.subtotal &&
        e1?.deliveryFee == e2?.deliveryFee &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.deliveredAt == e2?.deliveredAt;
  }

  @override
  int hash(OrdersRecord? e) => const ListEquality().hash([
        e?.customerId,
        e?.restaurantId,
        e?.riderId,
        e?.orderDate,
        e?.deliverAddress,
        e?.totalAmount,
        e?.orderStatus,
        e?.specialInstructions,
        e?.customerName,
        e?.restaurantOwnerId,
        e?.restaurantName,
        e?.restaurantAddress,
        e?.riderName,
        e?.subtotal,
        e?.deliveryFee,
        e?.updatedAt,
        e?.deliveredAt
      ]);

  @override
  bool isValidKey(Object? o) => o is OrdersRecord;
}
