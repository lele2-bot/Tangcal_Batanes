import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/resto/product_form/product_form_widget.dart';
import '/components/app_image.dart';
import 'package:flutter/material.dart';

Future<void> showProductForm(BuildContext context, {ProductsRecord? product}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormWidget(product: product),
    );

/// The signed-in owner's products, with quick availability toggle, edit and
/// delete. Products from every Restaurants doc they own are included, so
/// items saved under an older duplicate restaurant profile still show up.
class RestaurantMenuWidget extends StatefulWidget {
  const RestaurantMenuWidget({super.key});

  @override
  State<RestaurantMenuWidget> createState() => _RestaurantMenuWidgetState();
}

class _RestaurantMenuWidgetState extends State<RestaurantMenuWidget> {
  late final Future<List<RestaurantsRecord>> _myRestaurants =
      queryRestaurantsRecordOnce(
    queryBuilder: (q) => q.where('owner_id', isEqualTo: currentUserReference),
    limit: 10,
  );

  Future<void> _delete(ProductsRecord product) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
            '"${product.productName}" will be removed from your menu. Past orders keep their totals.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await product.reference.delete();
      messenger.showSnackBar(
          SnackBar(content: Text('"${product.productName}" deleted.')));
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not delete: ${e.message ?? e.code}')));
    }
  }

  Future<void> _setAvailable(ProductsRecord product, bool value) async {
    try {
      await product.reference
          .update(createProductsRecordData(isAvailable: value));
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not update: ${e.message ?? e.code}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget message(String text) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(text,
                textAlign: TextAlign.center, style: theme.labelLarge),
          ),
        );

    return FutureBuilder<List<RestaurantsRecord>>(
      future: _myRestaurants,
      builder: (context, restaurants) {
        if (!restaurants.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final refs = restaurants.data!.map((r) => r.reference).toList();
        if (refs.isEmpty) {
          return message(
              'Set up your restaurant in Edit Profile before adding products.');
        }
        return StreamBuilder<List<ProductsRecord>>(
          stream: queryProductsRecord(
            queryBuilder: (q) => q.where('restaurant_id', whereIn: refs),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return message('Could not load products: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final products = snapshot.data!
              ..sort((a, b) => a.productName
                  .toLowerCase()
                  .compareTo(b.productName.toLowerCase()));
            if (products.isEmpty) {
              return message('No products yet. Tap + to add your first dish.');
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12.0),
              itemBuilder: (context, i) {
                final p = products[i];
                return Card(
                  margin: EdgeInsets.zero,
                  color: theme.secondaryBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AppImage(p.prodImg,
                              width: 64.0,
                              height: 64.0,
                              placeholderIcon: Icons.fastfood),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.productName, style: theme.titleMedium),
                              Text(
                                [
                                  '₱${p.price.toStringAsFixed(2)}',
                                  if (p.prepTime > 0) '${p.prepTime} mins',
                                  if (p.category.isNotEmpty) p.category,
                                ].join(' · '),
                                style: theme.labelMedium,
                              ),
                              Text(
                                p.isAvailable ? 'Available' : 'Not available',
                                style: theme.labelSmall.copyWith(
                                  color: p.isAvailable
                                      ? const Color(0xFF2E9E5B)
                                      : theme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: p.isAvailable,
                          onChanged: (v) => _setAvailable(p, v),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'More',
                          onSelected: (action) => action == 'edit'
                              ? showProductForm(context, product: p)
                              : _delete(p),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
