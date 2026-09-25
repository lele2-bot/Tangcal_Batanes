import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrderRecord extends FirestoreRecord {
  OrderRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "orderID" field.
  String? _orderID;
  String get orderID => _orderID ?? '';
  bool hasOrderID() => _orderID != null;

  // "ownedBy" field.
  DocumentReference? _ownedBy;
  DocumentReference? get ownedBy => _ownedBy;
  bool hasOwnedBy() => _ownedBy != null;

  // "orderList" field.
  List<String>? _orderList;
  List<String> get orderList => _orderList ?? const [];
  bool hasOrderList() => _orderList != null;

  // "total" field.
  double? _total;
  double get total => _total ?? 0.0;
  bool hasTotal() => _total != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  void _initializeFields() {
    _orderID = snapshotData['orderID'] as String?;
    _ownedBy = snapshotData['ownedBy'] as DocumentReference?;
    _orderList = getDataList(snapshotData['orderList']);
    _total = castToType<double>(snapshotData['total']);
    _timestamp = snapshotData['timestamp'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('order');

  static Stream<OrderRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OrderRecord.fromSnapshot(s));

  static Future<OrderRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OrderRecord.fromSnapshot(s));

  static OrderRecord fromSnapshot(DocumentSnapshot snapshot) => OrderRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrderRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrderRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrderRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrderRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrderRecordData({
  String? orderID,
  DocumentReference? ownedBy,
  double? total,
  DateTime? timestamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'orderID': orderID,
      'ownedBy': ownedBy,
      'total': total,
      'timestamp': timestamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class OrderRecordDocumentEquality implements Equality<OrderRecord> {
  const OrderRecordDocumentEquality();

  @override
  bool equals(OrderRecord? e1, OrderRecord? e2) {
    const listEquality = ListEquality();
    return e1?.orderID == e2?.orderID &&
        e1?.ownedBy == e2?.ownedBy &&
        listEquality.equals(e1?.orderList, e2?.orderList) &&
        e1?.total == e2?.total &&
        e1?.timestamp == e2?.timestamp;
  }

  @override
  int hash(OrderRecord? e) => const ListEquality()
      .hash([e?.orderID, e?.ownedBy, e?.orderList, e?.total, e?.timestamp]);

  @override
  bool isValidKey(Object? o) => o is OrderRecord;
}
