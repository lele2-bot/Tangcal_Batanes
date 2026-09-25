import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RestaurantsRecord extends FirestoreRecord {
  RestaurantsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "owner_id" field.
  DocumentReference? _ownerId;
  DocumentReference? get ownerId => _ownerId;
  bool hasOwnerId() => _ownerId != null;

  // "restaurant_name" field.
  String? _restaurantName;
  String get restaurantName => _restaurantName ?? '';
  bool hasRestaurantName() => _restaurantName != null;

  // "business_permit" field.
  String? _businessPermit;
  String get businessPermit => _businessPermit ?? '';
  bool hasBusinessPermit() => _businessPermit != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "short_description" field.
  String? _shortDescription;
  String get shortDescription => _shortDescription ?? '';
  bool hasShortDescription() => _shortDescription != null;

  // "logo" field.
  String? _logo;
  String get logo => _logo ?? '';
  bool hasLogo() => _logo != null;

  // "order_number" field.
  String? _orderNumber;
  String get orderNumber => _orderNumber ?? '';
  bool hasOrderNumber() => _orderNumber != null;

  // "resto_id" field.
  String? _restoId;
  String get restoId => _restoId ?? '';
  bool hasRestoId() => _restoId != null;

  void _initializeFields() {
    _ownerId = snapshotData['owner_id'] as DocumentReference?;
    _restaurantName = snapshotData['restaurant_name'] as String?;
    _businessPermit = snapshotData['business_permit'] as String?;
    _address = snapshotData['address'] as String?;
    _shortDescription = snapshotData['short_description'] as String?;
    _logo = snapshotData['logo'] as String?;
    _orderNumber = snapshotData['order_number'] as String?;
    _restoId = snapshotData['resto_id'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Restaurants');

  static Stream<RestaurantsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RestaurantsRecord.fromSnapshot(s));

  static Future<RestaurantsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RestaurantsRecord.fromSnapshot(s));

  static RestaurantsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RestaurantsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RestaurantsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RestaurantsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RestaurantsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RestaurantsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRestaurantsRecordData({
  DocumentReference? ownerId,
  String? restaurantName,
  String? businessPermit,
  String? address,
  String? shortDescription,
  String? logo,
  String? orderNumber,
  String? restoId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'owner_id': ownerId,
      'restaurant_name': restaurantName,
      'business_permit': businessPermit,
      'address': address,
      'short_description': shortDescription,
      'logo': logo,
      'order_number': orderNumber,
      'resto_id': restoId,
    }.withoutNulls,
  );

  return firestoreData;
}

class RestaurantsRecordDocumentEquality implements Equality<RestaurantsRecord> {
  const RestaurantsRecordDocumentEquality();

  @override
  bool equals(RestaurantsRecord? e1, RestaurantsRecord? e2) {
    return e1?.ownerId == e2?.ownerId &&
        e1?.restaurantName == e2?.restaurantName &&
        e1?.businessPermit == e2?.businessPermit &&
        e1?.address == e2?.address &&
        e1?.shortDescription == e2?.shortDescription &&
        e1?.logo == e2?.logo &&
        e1?.orderNumber == e2?.orderNumber &&
        e1?.restoId == e2?.restoId;
  }

  @override
  int hash(RestaurantsRecord? e) => const ListEquality().hash([
        e?.ownerId,
        e?.restaurantName,
        e?.businessPermit,
        e?.address,
        e?.shortDescription,
        e?.logo,
        e?.orderNumber,
        e?.restoId
      ]);

  @override
  bool isValidKey(Object? o) => o is RestaurantsRecord;
}
