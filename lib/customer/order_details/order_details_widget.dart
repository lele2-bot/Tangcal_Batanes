import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/components/order_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Live view of one order: a status timeline, the items and totals. The
/// customer who placed it can cancel while it is still Pending.
class OrderDetailsWidget extends StatelessWidget {
  const OrderDetailsWidget({super.key, required this.orderRef});

  final DocumentReference? orderRef;

  static String routeName = 'OrderDetails';
  static String routePath = '/orderDetails';

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.cooking,
    OrderStatus.readyForPickup,
    OrderStatus.onDelivery,
    OrderStatus.delivered,
  ];

  static const _stepHelp = {
    OrderStatus.pending: 'Waiting for the restaurant to accept your order.',
    OrderStatus.cooking: 'The restaurant is preparing your food.',
    OrderStatus.readyForPickup: 'Your food is ready and waiting for a rider.',
    OrderStatus.onDelivery: 'A rider is bringing your order.',
    OrderStatus.delivered: 'Your order was delivered. Enjoy!',
    OrderStatus.cancelled: 'This order was cancelled.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        foregroundColor: theme.primaryText,
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SafeArea(
        child: orderRef == null
            ? const Center(child: Text('Order not found.'))
            : StreamBuilder<OrdersRecord>(
                stream: OrdersRecord.getDocument(orderRef!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Could not load this order.',
                            style: theme.bodyMedium),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final order = snapshot.data!;
                  final status = order.orderStatus;
                  final canCancel = status == OrderStatus.pending &&
                      order.customerId == currentUserUid;
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _StatusTimeline(status: status),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(_stepHelp[status] ?? status,
                            style: theme.bodyLarge),
                      ),
                      OrderCardWidget(
                        order: order,
                        actions: [
                          if (canCancel)
                            OrderCardAction(
                              'Cancel Order',
                              () => runOrderAction(
                                context,
                                () => customerCancelOrder(order.reference),
                                successMessage: 'Your order was cancelled.',
                              ),
                              destructive: true,
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: OrderStatus.color(status).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: OrderStatus.color(status)),
            const SizedBox(width: 12.0),
            Text('Cancelled',
                style: theme.titleMedium
                    .copyWith(color: OrderStatus.color(status))),
          ],
        ),
      );
    }
    final current = OrderDetailsWidget._steps.indexOf(status);
    return Card(
      color: theme.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          children: [
            for (var i = 0; i < OrderDetailsWidget._steps.length; i++)
              Row(
                children: [
                  Icon(
                    i < current
                        ? Icons.check_circle
                        : i == current
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                    color: i <= current
                        ? OrderStatus.color(OrderDetailsWidget._steps[i])
                        : theme.secondaryText,
                  ),
                  const SizedBox(width: 12.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      OrderDetailsWidget._steps[i],
                      style: i == current
                          ? theme.titleMedium
                          : theme.bodyMedium.copyWith(
                              color: i < current
                                  ? theme.primaryText
                                  : theme.secondaryText),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
