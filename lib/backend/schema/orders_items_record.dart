import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrdersItemsRecord extends FirestoreRecord {
  OrdersItemsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "order_id" field.
  String? _orderId;
  String get orderId => _orderId ?? '';
  bool hasOrderId() => _orderId != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "unit_price" field.
  double? _unitPrice;
  double get unitPrice => _unitPrice ?? 0.0;
  bool hasUnitPrice() => _unitPrice != null;

  // "sub_total" field.
  double? _subTotal;
  double get subTotal => _subTotal ?? 0.0;
  bool hasSubTotal() => _subTotal != null;

  // "product_id" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _orderId = snapshotData['order_id'] as String?;
    _quantity = castToType<int>(snapshotData['quantity']);
    _unitPrice = castToType<double>(snapshotData['unit_price']);
    _subTotal = castToType<double>(snapshotData['sub_total']);
    _productId = snapshotData['product_id'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Orders_Items')
          : FirebaseFirestore.instance.collectionGroup('Orders_Items');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Orders_Items').doc(id);

  static Stream<OrdersItemsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OrdersItemsRecord.fromSnapshot(s));

  static Future<OrdersItemsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OrdersItemsRecord.fromSnapshot(s));

  static OrdersItemsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      OrdersItemsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrdersItemsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrdersItemsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrdersItemsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrdersItemsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrdersItemsRecordData({
  String? orderId,
  int? quantity,
  double? unitPrice,
  double? subTotal,
  DocumentReference? productId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'order_id': orderId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'sub_total': subTotal,
      'product_id': productId,
    }.withoutNulls,
  );

  return firestoreData;
}

class OrdersItemsRecordDocumentEquality implements Equality<OrdersItemsRecord> {
  const OrdersItemsRecordDocumentEquality();

  @override
  bool equals(OrdersItemsRecord? e1, OrdersItemsRecord? e2) {
    return e1?.orderId == e2?.orderId &&
        e1?.quantity == e2?.quantity &&
        e1?.unitPrice == e2?.unitPrice &&
        e1?.subTotal == e2?.subTotal &&
        e1?.productId == e2?.productId;
  }

  @override
  int hash(OrdersItemsRecord? e) => const ListEquality()
      .hash([e?.orderId, e?.quantity, e?.unitPrice, e?.subTotal, e?.productId]);

  @override
  bool isValidKey(Object? o) => o is OrdersItemsRecord;
}
