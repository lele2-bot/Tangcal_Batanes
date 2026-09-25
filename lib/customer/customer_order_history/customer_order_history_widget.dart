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
import 'customer_order_history_model.dart';
export 'customer_order_history_model.dart';

class CustomerOrderHistoryWidget extends StatefulWidget {
  const CustomerOrderHistoryWidget({super.key});

  static String routeName = 'CustomerOrderHistory';
  static String routePath = '/customerOrderHistory';

  @override
  State<CustomerOrderHistoryWidget> createState() =>
      _CustomerOrderHistoryWidgetState();
}

class _CustomerOrderHistoryWidgetState
    extends State<CustomerOrderHistoryWidget> {
  late CustomerOrderHistoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomerOrderHistoryModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Stream<List<OrdersRecord>> _myOrders() => queryOrdersRecord(
        queryBuilder: (q) => q
            .where('customer_id', isEqualTo: currentUserUid)
            .orderBy('order_date', descending: true),
      );

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
              Text('Current Orders', style: theme.titleLarge),
              const SizedBox(height: 12.0),
              OrderListWidget(
                stream: _myOrders(),
                filter: (o) => OrderStatus.isActive(o.orderStatus),
                showCustomer: false,
                emptyMessage: 'You have no orders in progress.',
                actionsFor: (order) => order.orderStatus == OrderStatus.pending
                    ? [
                        OrderCardAction(
                          'Cancel Order',
                          () => runOrderAction(
                            context,
                            () => customerCancelOrder(order.reference),
                            successMessage: 'Your order was cancelled.',
                          ),
                          destructive: true,
                        ),
                      ]
                    : [],
              ),
              const SizedBox(height: 32.0),
              Text('Past Orders', style: theme.titleLarge),
              const SizedBox(height: 12.0),
              OrderListWidget(
                stream: _myOrders(),
                filter: (o) => !OrderStatus.isActive(o.orderStatus),
                showCustomer: false,
                emptyMessage: 'Delivered and cancelled orders will show here.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
