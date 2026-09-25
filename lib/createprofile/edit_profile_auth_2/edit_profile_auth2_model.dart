import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'edit_profile_auth2_widget.dart' show EditProfileAuth2Widget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class EditProfileAuth2Model extends FlutterFlowModel<EditProfileAuth2Widget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for photo_url widget.
  FocusNode? photoUrlFocusNode;
  TextEditingController? photoUrlTextController;
  late MaskTextInputFormatter photoUrlMask;
  String? Function(BuildContext, String?)? photoUrlTextControllerValidator;
  // State field(s) for phone_number widget.
  FocusNode? phoneNumberFocusNode;
  TextEditingController? phoneNumberTextController;
  late MaskTextInputFormatter phoneNumberMask;
  String? Function(BuildContext, String?)? phoneNumberTextControllerValidator;
  // State field(s) for first_name widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for last_name widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  // State field(s) for Address widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressTextControllerValidator;
  // State field(s) for restaurant_name widget.
  FocusNode? restaurantNameFocusNode;
  TextEditingController? restaurantNameTextController;
  String? Function(BuildContext, String?)?
      restaurantNameTextControllerValidator;
  // State field(s) for shortdesc widget.
  FocusNode? shortdescFocusNode;
  TextEditingController? shortdescTextController;
  String? Function(BuildContext, String?)? shortdescTextControllerValidator;
  // State field(s) for BusinessPermit widget.
  FocusNode? businessPermitFocusNode;
  TextEditingController? businessPermitTextController;
  String? Function(BuildContext, String?)?
      businessPermitTextControllerValidator;
  // State field(s) for vehicle_type widget.
  String? vehicleTypeValue;
  FormFieldController<String>? vehicleTypeValueController;
  // State field(s) for DriversLicence widget.
  FocusNode? driversLicenceFocusNode;
  TextEditingController? driversLicenceTextController;
  String? Function(BuildContext, String?)?
      driversLicenceTextControllerValidator;
  // State field(s) for Vehicle_Color widget.
  FocusNode? vehicleColorFocusNode;
  TextEditingController? vehicleColorTextController;
  String? Function(BuildContext, String?)? vehicleColorTextControllerValidator;
  // State field(s) for Vehicle_Brand widget.
  FocusNode? vehicleBrandFocusNode;
  TextEditingController? vehicleBrandTextController;
  String? Function(BuildContext, String?)? vehicleBrandTextControllerValidator;
  // State field(s) for Vehicle_Model widget.
  FocusNode? vehicleModelFocusNode;
  TextEditingController? vehicleModelTextController;
  String? Function(BuildContext, String?)? vehicleModelTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    photoUrlFocusNode?.dispose();
    photoUrlTextController?.dispose();

    phoneNumberFocusNode?.dispose();
    phoneNumberTextController?.dispose();

    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();

    addressFocusNode?.dispose();
    addressTextController?.dispose();

    restaurantNameFocusNode?.dispose();
    restaurantNameTextController?.dispose();

    shortdescFocusNode?.dispose();
    shortdescTextController?.dispose();

    businessPermitFocusNode?.dispose();
    businessPermitTextController?.dispose();

    driversLicenceFocusNode?.dispose();
    driversLicenceTextController?.dispose();

    vehicleColorFocusNode?.dispose();
    vehicleColorTextController?.dispose();

    vehicleBrandFocusNode?.dispose();
    vehicleBrandTextController?.dispose();

    vehicleModelFocusNode?.dispose();
    vehicleModelTextController?.dispose();
  }
}
