// Images stored directly in Firestore.
//
// Cloud Storage for Firebase needs the Blaze plan, so on the free Spark plan
// pictures are resized, compressed to JPEG and saved as a data URL
// ("data:image/jpeg;base64,...") in the existing text fields
// (users.photo_url, Restaurants.logo, Products.prod_img). [AppImage] shows
// either that or an ordinary https:// URL, with a placeholder when empty.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Largest encoded image we store. Firestore documents are limited to 1 MiB,
/// and base64 adds a third, so keep well below that.
const int _maxEncodedBytes = 350 * 1024;

class ImagePickException implements Exception {
  ImagePickException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Lets the user choose a photo and returns it as a compressed JPEG data URL,
/// or null if they cancelled. [maxSide] limits width and height in pixels.
Future<String?> pickImageAsDataUrl(
  BuildContext context, {
  int maxSide = 800,
}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
        ],
      ),
    ),
  );
  if (source == null) {
    return null;
  }
  final XFile? file;
  try {
    file = await ImagePicker().pickImage(source: source);
  } catch (e) {
    throw ImagePickException('Could not open the ${source.name}: $e');
  }
  if (file == null) {
    return null;
  }
  final bytes = await file.readAsBytes();
  final jpeg = _compress(bytes, maxSide);
  return 'data:image/jpeg;base64,${base64Encode(jpeg)}';
}

Uint8List _compress(Uint8List input, int maxSide) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw ImagePickException(
        'That file is not a supported image. Please choose a JPG or PNG.');
  }
  var image = img.bakeOrientation(decoded);
  if (image.width > maxSide || image.height > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }
  // Lower the quality until it fits.
  for (final quality in [80, 65, 50, 35]) {
    final out = img.encodeJpg(image, quality: quality);
    if (out.length <= _maxEncodedBytes) {
      return out;
    }
  }
  throw ImagePickException(
      'That image is too large even after compressing. Please choose a smaller one.');
}

/// Decoded data-URL bytes, cached so lists don't decode on every rebuild.
final Map<int, Uint8List> _dataUrlCache = {};

Uint8List? _bytesFromDataUrl(String url) {
  final key = url.hashCode;
  final cached = _dataUrlCache[key];
  if (cached != null) {
    return cached;
  }
  try {
    final bytes = UriData.parse(url).contentAsBytes();
    if (_dataUrlCache.length > 100) {
      _dataUrlCache.clear();
    }
    return _dataUrlCache[key] = bytes;
  } catch (_) {
    return null;
  }
}

/// Shows an image from a data URL or http(s) URL, or [placeholderIcon] when
/// the value is empty or can't be loaded.
class AppImage extends StatelessWidget {
  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;

  Widget _placeholder(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.alternate,
      alignment: Alignment.center,
      child: Icon(placeholderIcon, color: theme.secondaryText),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = (url ?? '').trim();
    if (value.startsWith('data:image')) {
      final bytes = _bytesFromDataUrl(value);
      if (bytes == null) {
        return _placeholder(context);
      }
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, _, __) => _placeholder(context),
      );
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: value,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, _) => _placeholder(context),
        errorWidget: (context, _, __) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }
}

/// A circular [AppImage] for profile pictures.
class AvatarImage extends StatelessWidget {
  const AvatarImage(this.url, {super.key, this.size = 45.0});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: AppImage(
          url,
          width: size,
          height: size,
          placeholderIcon: Icons.person,
        ),
      );
}
