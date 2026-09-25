import '/app_state.dart';
import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/components/app_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Loads the Products for everything in the cart and rebuilds whenever the
/// cart changes, so quantities and totals update immediately.
class CartLinesBuilder extends StatefulWidget {
  const CartLinesBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, List<CartLine> lines) builder;

  @override
  State<CartLinesBuilder> createState() => _CartLinesBuilderState();
}

class _CartLinesBuilderState extends State<CartLinesBuilder> {
  final Map<DocumentReference, ProductsRecord?> _products = {};
  final Set<DocumentReference> _loading = {};
  Object? _error;

  Future<void> _load(Iterable<DocumentReference> refs) async {
    final missing = refs
        .where((r) => !_products.containsKey(r) && !_loading.contains(r))
        .toList();
    if (missing.isEmpty) {
      return;
    }
    _loading.addAll(missing);
    try {
      final snaps = await Future.wait(missing.map((r) => r.get()));
      if (!mounted) {
        return;
      }
      setState(() {
        for (final s in snaps) {
          _products[s.reference] =
              s.exists ? ProductsRecord.fromSnapshot(s) : null;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    } finally {
      _loading.removeAll(missing);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final quantities = cartQuantities();
    _load(quantities.keys);
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Could not load your cart: $_error',
              textAlign: TextAlign.center),
        ),
      );
    }
    if (quantities.keys.any((r) => !_products.containsKey(r))) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final lines = [
      for (final e in quantities.entries) CartLine(e.key, _products[e.key], e.value)
    ];
    return widget.builder(context, lines);
  }
}

/// A cart row: image, name, "₱250.00 × 2 = ₱500.00" and a [-] qty [+]
/// stepper. When [editable] is false (checkout summary) the stepper is hidden.
class CartLineTile extends StatelessWidget {
  const CartLineTile({super.key, required this.line, this.editable = true});

  final CartLine line;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final product = line.product;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: AppImage(product?.prodImg,
                width: 56.0, height: 56.0, placeholderIcon: Icons.fastfood),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: theme.titleMedium),
                const SizedBox(height: 2.0),
                Text(
                  line.available
                      ? '${peso(line.unitPrice)} × ${line.quantity} = ${peso(line.lineTotal)}'
                      : 'No longer available. Please remove it.',
                  style: line.available
                      ? theme.bodyMedium
                      : theme.bodyMedium.copyWith(color: theme.error),
                ),
              ],
            ),
          ),
          if (editable && line.available) ...[
            IconButton(
              tooltip: line.quantity > 1 ? 'Remove one' : 'Remove from cart',
              icon: Icon(
                line.quantity > 1
                    ? Icons.remove_circle_outline
                    : Icons.delete_outline,
                color: theme.error,
              ),
              onPressed: () => cartRemoveOne(product!),
            ),
            SizedBox(
              width: 24.0,
              child: Text('${line.quantity}',
                  textAlign: TextAlign.center, style: theme.titleMedium),
            ),
            IconButton(
              tooltip: 'Add one more',
              icon: Icon(Icons.add_circle_outline, color: theme.primary),
              onPressed: () => cartAddOne(product!),
            ),
          ] else if (editable)
            TextButton(
              onPressed: () => cartRemoveProduct(line.ref),
              child: const Text('Remove'),
            ),
        ],
      ),
    );
  }
}

/// Subtotal, delivery fee and total for the given lines.
class CartTotals extends StatelessWidget {
  const CartTotals({super.key, required this.lines});

  final List<CartLine> lines;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final subtotal = cartLinesSubtotal(lines);
    Widget row(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            children: [
              Text(label, style: bold ? theme.titleMedium : theme.bodyMedium),
              const Spacer(),
              Text(value, style: bold ? theme.titleLarge : theme.bodyMedium),
            ],
          ),
        );
    return Column(
      children: [
        row('Subtotal', peso(subtotal)),
        row('Delivery Fee', peso(kDeliveryFee)),
        const Divider(),
        row('TOTAL', peso(subtotal + kDeliveryFee), bold: true),
      ],
    );
  }
}
