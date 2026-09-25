import '/backend/order_service.dart';
import '/components/cart_lines.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_model.dart';
export 'cart_model.dart';

/// The customer's cart: one row per product with a [-] qty [+] stepper and
/// live totals. Delivery details are entered on the Checkout page.
class CartWidget extends StatefulWidget {
  const CartWidget({
    super.key,
    this.cartRef,
  });

  // Kept for the existing route definition; not used.
  final DocumentReference? cartRef;

  static String routeName = 'cart';
  static String routePath = '/cart';

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late CartModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      cartClear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        foregroundColor: theme.primaryText,
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            icon: const Icon(Icons.remove_shopping_cart_outlined),
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: SafeArea(
        child: CartLinesBuilder(
          builder: (context, lines) {
            if (lines.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 56.0, color: theme.secondaryText),
                      const SizedBox(height: 12.0),
                      Text('Your cart is empty.', style: theme.titleMedium),
                      const SizedBox(height: 4.0),
                      Text('Open a restaurant and tap + to add dishes.',
                          style: theme.labelMedium),
                    ],
                  ),
                ),
              );
            }
            final hasUnavailable = lines.any((l) => !l.available);
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Card(
                        color: theme.secondaryBackground,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          child: Column(
                            children: [
                              for (final line in lines) CartLineTile(line: line),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Card(
                        color: theme.secondaryBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CartTotals(lines: lines),
                        ),
                      ),
                      if (hasUnavailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Remove unavailable items before checking out.',
                            style: theme.bodyMedium.copyWith(color: theme.error),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: ElevatedButton(
                    onPressed: hasUnavailable
                        ? null
                        : () => context.pushNamed(CheckoutWidget.routeName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.0)),
                    ),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
