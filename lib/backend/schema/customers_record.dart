import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CustomersRecord extends FirestoreRecord {
  CustomersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "customer_id" field.
  DocumentReference? _customerId;
  DocumentReference? get customerId => _customerId;
  bool hasCustomerId() => _customerId != null;

  // "delivery_address" field.
  String? _deliveryAddress;
  String get deliveryAddress => _deliveryAddress ?? '';
  bool hasDeliveryAddress() => _deliveryAddress != null;

  // "first_name" field.
  String? _firstName;
  String get firstName => _firstName ?? '';
  bool hasFirstName() => _firstName != null;

  // "last_name" field.
  String? _lastName;
  String get lastName => _lastName ?? '';
  bool hasLastName() => _lastName != null;

  void _initializeFields() {
    _customerId = snapshotData['customer_id'] as DocumentReference?;
    _deliveryAddress = snapshotData['delivery_address'] as String?;
    _firstName = snapshotData['first_name'] as String?;
    _lastName = snapshotData['last_name'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Customers');

  static Stream<CustomersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CustomersRecord.fromSnapshot(s));

  static Future<CustomersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CustomersRecord.fromSnapshot(s));

  static CustomersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CustomersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CustomersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CustomersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CustomersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CustomersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCustomersRecordData({
  DocumentReference? customerId,
  String? deliveryAddress,
  String? firstName,
  String? lastName,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'customer_id': customerId,
      'delivery_address': deliveryAddress,
      'first_name': firstName,
      'last_name': lastName,
    }.withoutNulls,
  );

  return firestoreData;
}

class CustomersRecordDocumentEquality implements Equality<CustomersRecord> {
  const CustomersRecordDocumentEquality();

  @override
  bool equals(CustomersRecord? e1, CustomersRecord? e2) {
    return e1?.customerId == e2?.customerId &&
        e1?.deliveryAddress == e2?.deliveryAddress &&
        e1?.firstName == e2?.firstName &&
        e1?.lastName == e2?.lastName;
  }

  @override
  int hash(CustomersRecord? e) => const ListEquality()
      .hash([e?.customerId, e?.deliveryAddress, e?.firstName, e?.lastName]);

  @override
  bool isValidKey(Object? o) => o is CustomersRecord;
}
