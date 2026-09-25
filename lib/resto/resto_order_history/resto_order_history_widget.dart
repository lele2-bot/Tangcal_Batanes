import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/components/order_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'resto_order_history_model.dart';
export 'resto_order_history_model.dart';

class RestoOrderHistoryWidget extends StatefulWidget {
  const RestoOrderHistoryWidget({super.key});

  static String routeName = 'RestoOrderHistory';
  static String routePath = '/restoOrderHistory';

  @override
  State<RestoOrderHistoryWidget> createState() =>
      _RestoOrderHistoryWidgetState();
}

class _RestoOrderHistoryWidgetState extends State<RestoOrderHistoryWidget> {
  late RestoOrderHistoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RestoOrderHistoryModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 50.0,
                    fillColor: const Color(0xFF8B4513),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24.0),
                    onPressed: () async {
                      context.safePop();
                    },
                  ),
                  const SizedBox(width: 16.0),
                  Text('Order History', style: theme.headlineMedium),
                ],
              ),
              const SizedBox(height: 24.0),
              OrderListWidget(
                stream: queryOrdersRecord(
                  queryBuilder: (q) => q
                      .where('restaurant_owner_id', isEqualTo: currentUserUid)
                      .orderBy('order_date', descending: true),
                ),
                filter: (o) => !OrderStatus.isActive(o.orderStatus),
                showRestaurant: false,
                emptyMessage: 'Delivered and cancelled orders will show here.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
