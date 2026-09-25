import '/app_state.dart';
import '/backend/order_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shopping-cart icon with the number of items; opens the Cart page.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final count = cartItemCount();
    final theme = FlutterFlowTheme.of(context);
    return IconButton(
      tooltip: 'View cart',
      onPressed: () => context.pushNamed(CartWidget.routeName),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: const Color(0xFF8B4513),
        child: Icon(Icons.shopping_cart_outlined,
            color: theme.primaryText, size: 28.0),
      ),
    );
  }
}
