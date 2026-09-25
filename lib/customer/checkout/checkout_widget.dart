import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/components/cart_lines.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Order summary, delivery address and Place Order. The order itself is
/// created by [placeOrderFromCart] in lib/backend/order_service.dart.
class CheckoutWidget extends StatefulWidget {
  const CheckoutWidget({super.key});

  static String routeName = 'Checkout';
  static String routePath = '/checkout';

  @override
  State<CheckoutWidget> createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends State<CheckoutWidget> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _instructions = TextEditingController();
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    // Prefill with the address saved on this customer's own profile.
    queryCustomersRecordOnce(
      queryBuilder: (q) =>
          q.where('customer_id', isEqualTo: currentUserReference),
      limit: 1,
    ).then((customers) {
      if (mounted && customers.isNotEmpty && _address.text.isEmpty) {
        _address.text = customers.first.deliveryAddress;
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _address.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_placing || !_formKey.currentState!.validate()) {
      return;
    }
    final router = GoRouter.of(context);
    setState(() => _placing = true);
    DocumentReference? orderRef;
    final ok = await runOrderAction(
      context,
      () async {
        orderRef = await placeOrderFromCart(
          deliveryAddress: _address.text,
          specialInstructions: _instructions.text,
        );
      },
      successMessage: 'Order placed! Waiting for the restaurant to accept it.',
    );
    if (!mounted) {
      return;
    }
    setState(() => _placing = false);
    if (ok && orderRef != null) {
      // Leave the (now empty) cart and checkout behind, then show the order.
      router.goNamed(CustomerHomepageWidget.routeName);
      router.pushNamed(
        OrderDetailsWidget.routeName,
        queryParameters: {
          'orderRef': serializeParam(orderRef, ParamType.DocumentReference),
        }.withoutNulls,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    InputDecoration deco(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        );

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        foregroundColor: theme.primaryText,
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SafeArea(
        child: CartLinesBuilder(
          builder: (context, lines) {
            if (lines.isEmpty) {
              return Center(
                child: Text('Your cart is empty.', style: theme.titleMedium),
              );
            }
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text('ORDER SUMMARY', style: theme.labelLarge),
                  const SizedBox(height: 8.0),
                  Card(
                    color: theme.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          for (final line in lines)
                            CartLineTile(line: line, editable: false),
                          const Divider(),
                          CartTotals(lines: lines),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text('DELIVERY', style: theme.labelLarge),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _address,
                    decoration: deco('Delivery Address',
                        hint: 'House no., street, barangay, town'),
                    maxLines: 2,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Please enter your delivery address.'
                        : null,
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _instructions,
                    decoration: deco('Special Instructions (optional)',
                        hint: 'e.g. No onions, call when outside'),
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _placing || lines.any((l) => !l.available)
                        ? null
                        : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.0)),
                    ),
                    child: Text(_placing
                        ? 'Placing order...'
                        : 'Place Order · ${peso(cartLinesSubtotal(lines) + kDeliveryFee)}'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
