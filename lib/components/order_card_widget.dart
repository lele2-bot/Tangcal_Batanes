import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class OrderCardAction {
  const OrderCardAction(this.label, this.onPressed, {this.destructive = false});

  final String label;
  final Future<void> Function() onPressed;
  final bool destructive;
}

/// One order with its status, parties, items and the actions available to the
/// current viewer. Used by the customer, restaurant and rider screens.
class OrderCardWidget extends StatefulWidget {
  const OrderCardWidget({
    super.key,
    required this.order,
    this.actions = const [],
    this.showCustomer = true,
    this.showRestaurant = true,
    this.onTap,
  });

  final OrdersRecord order;
  final List<OrderCardAction> actions;
  final bool showCustomer;
  final bool showRestaurant;

  /// Opens the order, e.g. the Order Details page.
  final VoidCallback? onTap;

  @override
  State<OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget> {
  bool _busy = false;

  Future<void> _run(OrderCardAction action) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await action.onPressed();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final order = widget.order;
    final statusColor = OrderStatus.color(order.orderStatus);

    Widget line(IconData icon, String label, String value) => value.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16.0, color: theme.secondaryText),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: '$label: ',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: value),
                    ]),
                    style: theme.bodyMedium,
                  ),
                ),
              ],
            ),
          );

    return Card(
      margin: EdgeInsets.zero,
      color: theme.secondaryBackground,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.reference.id.substring(0, 6).toUpperCase()}',
                    style: theme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    order.orderStatus.isEmpty ? 'Unknown' : order.orderStatus,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0),
                  ),
                ),
              ],
            ),
            if (order.orderDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  dateTimeFormat('MMMEd', order.orderDate) +
                      ' · ' +
                      dateTimeFormat('jm', order.orderDate),
                  style: theme.labelSmall,
                ),
              ),
            if (widget.showRestaurant) ...[
              line(Icons.storefront, 'Restaurant', order.restaurantName),
              line(Icons.place_outlined, 'Pickup', order.restaurantAddress),
            ],
            if (widget.showCustomer)
              line(Icons.person_outline, 'Customer', order.customerName),
            line(Icons.home_outlined, 'Deliver to', order.deliverAddress),
            line(Icons.sticky_note_2_outlined, 'Note',
                order.specialInstructions),
            line(Icons.delivery_dining, 'Rider', order.riderName),
            _OrderItems(orderRef: order.reference),
            const Divider(height: 20.0),
            if (order.hasDeliveryFee()) ...[
              Row(
                children: [
                  Text('Subtotal', style: theme.labelMedium),
                  const Spacer(),
                  Text('₱${order.subtotal.toStringAsFixed(2)}',
                      style: theme.labelMedium),
                ],
              ),
              Row(
                children: [
                  Text('Delivery fee', style: theme.labelMedium),
                  const Spacer(),
                  Text('₱${order.deliveryFee.toStringAsFixed(2)}',
                      style: theme.labelMedium),
                ],
              ),
              const SizedBox(height: 4.0),
            ],
            Row(
              children: [
                Text('Total', style: theme.titleSmall),
                const Spacer(),
                Text('₱${order.totalAmount.toStringAsFixed(2)}',
                    style: theme.titleMedium),
              ],
            ),
            if (widget.actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    for (final action in widget.actions) ...[
                      if (action != widget.actions.first)
                        const SizedBox(width: 8.0),
                      Expanded(
                        child: action.destructive
                            ? OutlinedButton(
                                onPressed: _busy ? null : () => _run(action),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.error,
                                  side: BorderSide(color: theme.error),
                                  minimumSize: const Size.fromHeight(44.0),
                                ),
                                child: Text(action.label),
                              )
                            : ElevatedButton(
                                onPressed: _busy ? null : () => _run(action),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B4513),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(44.0),
                                ),
                                child: _busy
                                    ? const SizedBox(
                                        width: 18.0,
                                        height: 18.0,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            color: Colors.white),
                                      )
                                    : Text(action.label),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      )),
    );
  }
}

class _OrderItems extends StatelessWidget {
  const _OrderItems({required this.orderRef});

  final DocumentReference orderRef;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return FutureBuilder<List<OrdersItemsRecord>>(
      future: queryOrdersItemsRecordOnce(parent: orderRef),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    children: [
                      Text('${item.quantity}×  ', style: theme.bodyMedium),
                      Expanded(
                        child: item.productId == null
                            ? Text('Item', style: theme.bodyMedium)
                            : FutureBuilder<ProductsRecord>(
                                future: ProductsRecord.getDocumentOnce(
                                    item.productId!),
                                builder: (context, product) => Text(
                                  product.data?.productName ?? '…',
                                  style: theme.bodyMedium,
                                ),
                              ),
                      ),
                      Text('₱${item.subTotal.toStringAsFixed(2)}',
                          style: theme.bodyMedium),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A live list of orders from [stream], optionally filtered, with an empty
/// message and per-order actions.
class OrderListWidget extends StatelessWidget {
  const OrderListWidget({
    super.key,
    required this.stream,
    required this.emptyMessage,
    this.filter,
    this.actionsFor,
    this.onTapOrder,
    this.showCustomer = true,
    this.showRestaurant = true,
  });

  final Stream<List<OrdersRecord>> stream;
  final String emptyMessage;
  final bool Function(OrdersRecord order)? filter;
  final List<OrderCardAction> Function(OrdersRecord order)? actionsFor;
  final void Function(OrdersRecord order)? onTapOrder;
  final bool showCustomer;
  final bool showRestaurant;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return StreamBuilder<List<OrdersRecord>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Could not load orders: ${snapshot.error}',
              style: theme.bodyMedium.copyWith(color: theme.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final orders = snapshot.data!
            .where((o) => filter == null || filter!(o))
            .toList();
        if (orders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(emptyMessage,
                  textAlign: TextAlign.center, style: theme.labelLarge),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12.0),
          itemBuilder: (context, i) => OrderCardWidget(
            key: ValueKey(orders[i].reference.path),
            order: orders[i],
            actions: actionsFor?.call(orders[i]) ?? const [],
            onTap: onTapOrder == null ? null : () => onTapOrder!(orders[i]),
            showCustomer: showCustomer,
            showRestaurant: showRestaurant,
          ),
        );
      },
    );
  }
}
