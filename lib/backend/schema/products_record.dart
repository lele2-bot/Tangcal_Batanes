import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductsRecord extends FirestoreRecord {
  ProductsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "restaurant_id" field.
  DocumentReference? _restaurantId;
  DocumentReference? get restaurantId => _restaurantId;
  bool hasRestaurantId() => _restaurantId != null;

  // "product_name" field.
  String? _productName;
  String get productName => _productName ?? '';
  bool hasProductName() => _productName != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "prod_img" field.
  String? _prodImg;
  String get prodImg => _prodImg ?? '';
  bool hasProdImg() => _prodImg != null;

  // "is_available" field.
  bool? _isAvailable;
  bool get isAvailable => _isAvailable ?? false;
  bool hasIsAvailable() => _isAvailable != null;

  // "prep_time" field (minutes).
  int? _prepTime;
  int get prepTime => _prepTime ?? 0;
  bool hasPrepTime() => _prepTime != null;

  void _initializeFields() {
    _restaurantId = snapshotData['restaurant_id'] as DocumentReference?;
    _productName = snapshotData['product_name'] as String?;
    _description = snapshotData['description'] as String?;
    _category = snapshotData['category'] as String?;
    _price = castToType<double>(snapshotData['price']);
    _prodImg = snapshotData['prod_img'] as String?;
    _isAvailable = snapshotData['is_available'] as bool?;
    _prepTime = castToType<int>(snapshotData['prep_time']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Products');

  static Stream<ProductsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProductsRecord.fromSnapshot(s));

  static Future<ProductsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProductsRecord.fromSnapshot(s));

  static ProductsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProductsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProductsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProductsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProductsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProductsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createProductsRecordData({
  DocumentReference? restaurantId,
  String? productName,
  String? description,
  String? category,
  double? price,
  String? prodImg,
  bool? isAvailable,
  int? prepTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'restaurant_id': restaurantId,
      'product_name': productName,
      'description': description,
      'category': category,
      'price': price,
      'prod_img': prodImg,
      'is_available': isAvailable,
      'prep_time': prepTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProductsRecordDocumentEquality implements Equality<ProductsRecord> {
  const ProductsRecordDocumentEquality();

  @override
  bool equals(ProductsRecord? e1, ProductsRecord? e2) {
    return e1?.restaurantId == e2?.restaurantId &&
        e1?.productName == e2?.productName &&
        e1?.description == e2?.description &&
        e1?.category == e2?.category &&
        e1?.price == e2?.price &&
        e1?.prodImg == e2?.prodImg &&
        e1?.isAvailable == e2?.isAvailable &&
        e1?.prepTime == e2?.prepTime;
  }

  @override
  int hash(ProductsRecord? e) => const ListEquality().hash([
        e?.restaurantId,
        e?.productName,
        e?.description,
        e?.category,
        e?.price,
        e?.prodImg,
        e?.isAvailable,
        e?.prepTime
      ]);

  @override
  bool isValidKey(Object? o) => o is ProductsRecord;
}
