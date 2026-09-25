import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RiderRecord extends FirestoreRecord {
  RiderRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "rider_id" field.
  DocumentReference? _riderId;
  DocumentReference? get riderId => _riderId;
  bool hasRiderId() => _riderId != null;

  // "vehicle_type" field.
  String? _vehicleType;
  String get vehicleType => _vehicleType ?? '';
  bool hasVehicleType() => _vehicleType != null;

  // "vehicle_model" field.
  String? _vehicleModel;
  String get vehicleModel => _vehicleModel ?? '';
  bool hasVehicleModel() => _vehicleModel != null;

  // "is_available" field.
  bool? _isAvailable;
  bool get isAvailable => _isAvailable ?? false;
  bool hasIsAvailable() => _isAvailable != null;

  // "first_name" field.
  String? _firstName;
  String get firstName => _firstName ?? '';
  bool hasFirstName() => _firstName != null;

  // "last_name" field.
  String? _lastName;
  String get lastName => _lastName ?? '';
  bool hasLastName() => _lastName != null;

  // "vehicle_brand" field.
  String? _vehicleBrand;
  String get vehicleBrand => _vehicleBrand ?? '';
  bool hasVehicleBrand() => _vehicleBrand != null;

  // "vehicle_color" field.
  String? _vehicleColor;
  String get vehicleColor => _vehicleColor ?? '';
  bool hasVehicleColor() => _vehicleColor != null;

  void _initializeFields() {
    _riderId = snapshotData['rider_id'] as DocumentReference?;
    _vehicleType = snapshotData['vehicle_type'] as String?;
    _vehicleModel = snapshotData['vehicle_model'] as String?;
    _isAvailable = snapshotData['is_available'] as bool?;
    _firstName = snapshotData['first_name'] as String?;
    _lastName = snapshotData['last_name'] as String?;
    _vehicleBrand = snapshotData['vehicle_brand'] as String?;
    _vehicleColor = snapshotData['vehicle_color'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Rider');

  static Stream<RiderRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RiderRecord.fromSnapshot(s));

  static Future<RiderRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RiderRecord.fromSnapshot(s));

  static RiderRecord fromSnapshot(DocumentSnapshot snapshot) => RiderRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RiderRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RiderRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RiderRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RiderRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRiderRecordData({
  DocumentReference? riderId,
  String? vehicleType,
  String? vehicleModel,
  bool? isAvailable,
  String? firstName,
  String? lastName,
  String? vehicleBrand,
  String? vehicleColor,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'rider_id': riderId,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'is_available': isAvailable,
      'first_name': firstName,
      'last_name': lastName,
      'vehicle_brand': vehicleBrand,
      'vehicle_color': vehicleColor,
    }.withoutNulls,
  );

  return firestoreData;
}

class RiderRecordDocumentEquality implements Equality<RiderRecord> {
  const RiderRecordDocumentEquality();

  @override
  bool equals(RiderRecord? e1, RiderRecord? e2) {
    return e1?.riderId == e2?.riderId &&
        e1?.vehicleType == e2?.vehicleType &&
        e1?.vehicleModel == e2?.vehicleModel &&
        e1?.isAvailable == e2?.isAvailable &&
        e1?.firstName == e2?.firstName &&
        e1?.lastName == e2?.lastName &&
        e1?.vehicleBrand == e2?.vehicleBrand &&
        e1?.vehicleColor == e2?.vehicleColor;
  }

  @override
  int hash(RiderRecord? e) => const ListEquality().hash([
        e?.riderId,
        e?.vehicleType,
        e?.vehicleModel,
        e?.isAvailable,
        e?.firstName,
        e?.lastName,
        e?.vehicleBrand,
        e?.vehicleColor
      ]);

  @override
  bool isValidKey(Object? o) => o is RiderRecord;
}
