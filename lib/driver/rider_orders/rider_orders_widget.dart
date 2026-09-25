import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/components/order_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

Widget _sectionTitle(BuildContext context, String title, String subtitle) {
  final theme = FlutterFlowTheme.of(context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.headlineSmall),
        Text(subtitle, style: theme.labelMedium),
      ],
    ),
  );
}

/// Orders the restaurant has marked "Ready for Pickup" that no rider has
/// taken yet. Accepting is first-come-first-served (see [riderAcceptOrder]).
class RiderAvailableOrdersWidget extends StatelessWidget {
  const RiderAvailableOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionTitle(context, 'Delivery Requests',
              'Orders ready for pickup. Accept one to start delivering.'),
          OrderListWidget(
            stream: queryOrdersRecord(
              queryBuilder: (q) => q
                  .where('order_status', isEqualTo: OrderStatus.readyForPickup)
                  .orderBy('order_date'),
            ),
            filter: (o) => o.riderId.isEmpty,
            emptyMessage: 'No orders are waiting for a rider right now.',
            actionsFor: (order) => [
              OrderCardAction(
                'Accept Delivery',
                () => runOrderAction(
                  context,
                  () => riderAcceptOrder(order.reference),
                  successMessage:
                      'Delivery accepted. Find it under your ongoing deliveries.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The signed-in rider's own deliveries: ongoing first, then completed.
class RiderMyDeliveriesWidget extends StatelessWidget {
  const RiderMyDeliveriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Stream<List<OrdersRecord>> myOrders() => queryOrdersRecord(
          queryBuilder: (q) => q
              .where('rider_id', isEqualTo: currentUserUid)
              .orderBy('order_date', descending: true),
        );
    return SingleChildScrollView(
      primary: false,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Ongoing Delivery',
              'Mark an order delivered once the customer has it.'),
          OrderListWidget(
            stream: myOrders(),
            filter: (o) => o.orderStatus == OrderStatus.onDelivery,
            emptyMessage:
                'You have no ongoing deliveries. Accept one from the Home tab.',
            actionsFor: (order) => [
              OrderCardAction(
                'Mark as Delivered',
                () => runOrderAction(
                  context,
                  () => riderMarkDelivered(order.reference),
                  successMessage: 'Order marked as delivered. Great job!',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          _sectionTitle(context, 'Completed', 'Your delivered orders.'),
          OrderListWidget(
            stream: myOrders(),
            filter: (o) => o.orderStatus == OrderStatus.delivered,
            emptyMessage: 'No completed deliveries yet.',
          ),
        ],
      ),
    );
  }
}
