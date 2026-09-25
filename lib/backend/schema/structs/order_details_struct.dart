// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrderDetailsStruct extends FFFirebaseStruct {
  OrderDetailsStruct({
    String? orderNumber,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _orderNumber = orderNumber,
        super(firestoreUtilData);

  // "order_number" field.
  String? _orderNumber;
  String get orderNumber => _orderNumber ?? '2505001';
  set orderNumber(String? val) => _orderNumber = val;

  bool hasOrderNumber() => _orderNumber != null;

  static OrderDetailsStruct fromMap(Map<String, dynamic> data) =>
      OrderDetailsStruct(
        orderNumber: data['order_number'] as String?,
      );

  static OrderDetailsStruct? maybeFromMap(dynamic data) => data is Map
      ? OrderDetailsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'order_number': _orderNumber,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'order_number': serializeParam(
          _orderNumber,
          ParamType.String,
        ),
      }.withoutNulls;

  static OrderDetailsStruct fromSerializableMap(Map<String, dynamic> data) =>
      OrderDetailsStruct(
        orderNumber: deserializeParam(
          data['order_number'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'OrderDetailsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OrderDetailsStruct && orderNumber == other.orderNumber;
  }

  @override
  int get hashCode => const ListEquality().hash([orderNumber]);
}

OrderDetailsStruct createOrderDetailsStruct({
  String? orderNumber,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    OrderDetailsStruct(
      orderNumber: orderNumber,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

OrderDetailsStruct? updateOrderDetailsStruct(
  OrderDetailsStruct? orderDetails, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    orderDetails
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addOrderDetailsStructData(
  Map<String, dynamic> firestoreData,
  OrderDetailsStruct? orderDetails,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (orderDetails == null) {
    return;
  }
  if (orderDetails.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && orderDetails.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final orderDetailsData =
      getOrderDetailsFirestoreData(orderDetails, forFieldValue);
  final nestedData =
      orderDetailsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = orderDetails.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getOrderDetailsFirestoreData(
  OrderDetailsStruct? orderDetails, [
  bool forFieldValue = false,
]) {
  if (orderDetails == null) {
    return {};
  }
  final firestoreData = mapToFirestore(orderDetails.toMap());

  // Add any Firestore field values
  mapToFirestore(orderDetails.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getOrderDetailsListFirestoreData(
  List<OrderDetailsStruct>? orderDetailss,
) =>
    orderDetailss?.map((e) => getOrderDetailsFirestoreData(e, true)).toList() ??
    [];
