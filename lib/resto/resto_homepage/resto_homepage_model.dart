import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/createprofile/empty_state_orders/empty_state_orders_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/resto/order_items_carousel/order_items_carousel_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'resto_homepage_widget.dart' show RestoHomepageWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RestoHomepageModel extends FlutterFlowModel<RestoHomepageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Restaurant_Navigation_TABAR widget.
  TabController? restaurantNavigationTABARController;
  int get restaurantNavigationTABARCurrentIndex =>
      restaurantNavigationTABARController != null
          ? restaurantNavigationTABARController!.index
          : 0;
  int get restaurantNavigationTABARPreviousIndex =>
      restaurantNavigationTABARController != null
          ? restaurantNavigationTABARController!.previousIndex
          : 0;

  // Models for Order_Items_Carousel dynamic component.
  late FlutterFlowDynamicModels<OrderItemsCarouselModel>
      orderItemsCarouselModels;

  @override
  void initState(BuildContext context) {
    orderItemsCarouselModels =
        FlutterFlowDynamicModels(() => OrderItemsCarouselModel());
  }

  @override
  void dispose() {
    restaurantNavigationTABARController?.dispose();
    orderItemsCarouselModels.dispose();
  }
}
