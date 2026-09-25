import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CartItemsRecord extends FirestoreRecord {
  CartItemsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "item_name" field.
  String? _itemName;
  String get itemName => _itemName ?? '';
  bool hasItemName() => _itemName != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "product_image" field.
  String? _productImage;
  String get productImage => _productImage ?? '';
  bool hasProductImage() => _productImage != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "resto_id" field.
  String? _restoId;
  String get restoId => _restoId ?? '';
  bool hasRestoId() => _restoId != null;

  // "owned" field.
  DocumentReference? _owned;
  DocumentReference? get owned => _owned;
  bool hasOwned() => _owned != null;

  // "price" field.
  String? _price;
  String get price => _price ?? '';
  bool hasPrice() => _price != null;

  void _initializeFields() {
    _itemName = snapshotData['item_name'] as String?;
    _quantity = castToType<int>(snapshotData['quantity']);
    _productImage = snapshotData['product_image'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _restoId = snapshotData['resto_id'] as String?;
    _owned = snapshotData['owned'] as DocumentReference?;
    _price = snapshotData['price'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('cart_items');

  static Stream<CartItemsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CartItemsRecord.fromSnapshot(s));

  static Future<CartItemsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CartItemsRecord.fromSnapshot(s));

  static CartItemsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CartItemsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CartItemsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CartItemsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CartItemsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CartItemsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCartItemsRecordData({
  String? itemName,
  int? quantity,
  String? productImage,
  DateTime? timestamp,
  String? restoId,
  DocumentReference? owned,
  String? price,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'item_name': itemName,
      'quantity': quantity,
      'product_image': productImage,
      'timestamp': timestamp,
      'resto_id': restoId,
      'owned': owned,
      'price': price,
    }.withoutNulls,
  );

  return firestoreData;
}

class CartItemsRecordDocumentEquality implements Equality<CartItemsRecord> {
  const CartItemsRecordDocumentEquality();

  @override
  bool equals(CartItemsRecord? e1, CartItemsRecord? e2) {
    return e1?.itemName == e2?.itemName &&
        e1?.quantity == e2?.quantity &&
        e1?.productImage == e2?.productImage &&
        e1?.timestamp == e2?.timestamp &&
        e1?.restoId == e2?.restoId &&
        e1?.owned == e2?.owned &&
        e1?.price == e2?.price;
  }

  @override
  int hash(CartItemsRecord? e) => const ListEquality().hash([
        e?.itemName,
        e?.quantity,
        e?.productImage,
        e?.timestamp,
        e?.restoId,
        e?.owned,
        e?.price
      ]);

  @override
  bool isValidKey(Object? o) => o is CartItemsRecord;
}
