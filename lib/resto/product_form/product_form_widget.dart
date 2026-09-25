import '/backend/backend.dart';
import '/backend/order_service.dart';
import '/components/app_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Add a new product (when [product] is null) or edit an existing one.
/// Shown as a bottom sheet from the restaurant's Product Management list.
class ProductFormWidget extends StatefulWidget {
  const ProductFormWidget({super.key, this.product});

  final ProductsRecord? product;

  @override
  State<ProductFormWidget> createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.productName);
  late final _description =
      TextEditingController(text: widget.product?.description);
  late final _category = TextEditingController(text: widget.product?.category);
  late final _price = TextEditingController(
      text: widget.product == null ? '' : _plain(widget.product!.price));
  late final _prepTime = TextEditingController(
      text: (widget.product?.prepTime ?? 0) > 0
          ? '${widget.product!.prepTime}'
          : '');
  late bool _available = widget.product?.isAvailable ?? true;
  late String _imageUrl = widget.product?.prodImg ?? '';
  bool _uploading = false;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  void dispose() {
    for (final c in [_name, _description, _category, _price, _prepTime]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _uploading = true);
    try {
      // Resized/compressed and stored on the product document itself
      // (Cloud Storage needs the Blaze plan). See components/app_image.dart.
      final dataUrl = await pickImageAsDataUrl(context, maxSide: 800);
      if (dataUrl != null && mounted) {
        setState(() => _imageUrl = dataUrl);
      }
    } on ImagePickException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not use that photo: $e')));
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final data = createProductsRecordData(
        productName: _name.text.trim(),
        description: _description.text.trim(),
        category: _category.text.trim(),
        price: double.parse(_price.text.trim()),
        prepTime: int.tryParse(_prepTime.text.trim()) ?? 0,
        isAvailable: _available,
        prodImg: _imageUrl,
      );
      if (_isEdit) {
        // Products saved before restaurant linking existed have no
        // restaurant_id; attach them to this owner's restaurant on edit.
        final restaurantRef =
            widget.product!.restaurantId ?? (await getMyRestaurant())?.reference;
        await widget.product!.reference.update({
          ...data,
          if (restaurantRef != null)
            ...createProductsRecordData(restaurantId: restaurantRef),
        });
      } else {
        // Customers see a restaurant's menu by filtering Products on
        // restaurant_id, so every product must point at its restaurant.
        final restaurant = await getMyRestaurant();
        if (restaurant == null) {
          messenger.showSnackBar(const SnackBar(
              content: Text(
                  'Set up your restaurant profile before adding products.')));
          return;
        }
        await ProductsRecord.collection.doc().set({
          ...data,
          ...createProductsRecordData(restaurantId: restaurant.reference),
        });
      }
      if (mounted) {
        Navigator.pop(context);
      }
      messenger.showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Product updated.' : 'Product added.')));
    } on FirebaseException catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('Could not save the product: ${e.message ?? e.code}')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    InputDecoration deco(String label, {String? hint, String? suffix}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        );

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.0, 12.0, 20.0, 20.0 + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(_isEdit ? 'Edit Product' : 'Add Product',
                          style: theme.headlineSmall),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: _uploading ? null : _pickPhoto,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 140.0,
                        height: 140.0,
                        color: theme.alternate,
                        child: _uploading
                            ? const Center(child: CircularProgressIndicator())
                            : _imageUrl.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined,
                                          size: 32.0,
                                          color: theme.secondaryText),
                                      const SizedBox(height: 6.0),
                                      Text('Upload Photo',
                                          style: theme.labelMedium),
                                    ],
                                  )
                                : AppImage(_imageUrl,
                                    placeholderIcon: Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                if (_imageUrl.isNotEmpty && !_uploading)
                  TextButton(
                    onPressed: _pickPhoto,
                    child: const Text('Change Photo'),
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _name,
                  decoration: deco('Product Name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Enter a product name.'
                      : null,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _description,
                  decoration: deco('Description'),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _category,
                  decoration: deco('Category', hint: 'e.g. Rice Meals, Drinks'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        decoration: deco('Price', suffix: 'PHP'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          final price = double.tryParse((v ?? '').trim());
                          return price == null || price <= 0
                              ? 'Enter a valid price.'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        controller: _prepTime,
                        decoration: deco('Prep Time', suffix: 'mins'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) {
                            return null;
                          }
                          final mins = int.tryParse(text);
                          return mins == null || mins < 0 || mins > 600
                              ? 'Whole minutes only.'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available'),
                  subtitle: const Text(
                      'Turn off when sold out. Customers can\'t order it.'),
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: _saving || _uploading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.0)),
                  ),
                  child: Text(_saving
                      ? 'Saving...'
                      : _isEdit
                          ? 'Save Changes'
                          : 'Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
