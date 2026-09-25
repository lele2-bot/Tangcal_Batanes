import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/app_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

enum ProfileRole { customer, businessOwner, rider }

/// The Profile tab for all three roles.
///
/// Everything is loaded from the signed-in user's own documents: their
/// users/{uid} doc, and the Customers / Restaurants / Rider doc whose owner
/// field points at users/{uid}. Nothing is read from shared app state, so
/// switching accounts always shows the new account's details.
class ProfileTabWidget extends StatelessWidget {
  const ProfileTabWidget({super.key, required this.role});

  final ProfileRole role;

  @override
  Widget build(BuildContext context) {
    final userRef = currentUserReference;
    if (userRef == null) {
      return const Center(child: Text('Please log in.'));
    }
    return StreamBuilder<UsersRecord>(
      // Keyed by uid so a different account never reuses this stream.
      key: ValueKey(userRef.path),
      stream: UsersRecord.getDocument(userRef),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load your profile.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PhotoHeader(user: user),
                  const SizedBox(height: 20.0),
                  _Section(
                    title: 'Account Details',
                    children: [
                      _InfoRow('Email', user.email),
                      _InfoRow('Phone Number', user.phoneNumber),
                      _InfoRow('Account Type', user.role),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  _RoleDetails(role: role, userRef: userRef),
                  const SizedBox(height: 20.0),
                  _NavTile(
                    icon: Icons.account_circle_outlined,
                    label: 'Edit Profile',
                    onTap: () =>
                        context.pushNamed(Auth2EditProfileWidget.routeName),
                  ),
                  if (role == ProfileRole.customer)
                    _NavTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'My Orders',
                      onTap: () => context
                          .pushNamed(CustomerOrderHistoryWidget.routeName),
                    ),
                  if (role == ProfileRole.businessOwner)
                    _NavTile(
                      icon: Icons.history,
                      label: 'Completed Orders',
                      onTap: () =>
                          context.pushNamed(RestoOrderHistoryWidget.routeName),
                    ),
                  const SizedBox(height: 24.0),
                  OutlinedButton.icon(
                    onPressed: () async {
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();
                      context.goNamedAuth(
                          Auth2LoginWidget.routeName, context.mounted);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48.0)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Uploads [dataUrl] into [field] of [doc], with SnackBar feedback.
Future<void> _saveImage(BuildContext context, DocumentReference doc,
    String field, Future<String?> Function() pick) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final dataUrl = await pick();
    if (dataUrl == null) {
      return;
    }
    await doc.update({field: dataUrl});
    messenger.showSnackBar(const SnackBar(content: Text('Photo updated.')));
  } on ImagePickException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on FirebaseException catch (e) {
    messenger.showSnackBar(SnackBar(
        content: Text('Could not save the photo: ${e.message ?? e.code}')));
  } catch (e) {
    messenger.showSnackBar(
        SnackBar(content: Text('Could not update the photo: $e')));
  }
}

class _PhotoHeader extends StatefulWidget {
  const _PhotoHeader({required this.user});

  final UsersRecord user;

  @override
  State<_PhotoHeader> createState() => _PhotoHeaderState();
}

class _PhotoHeaderState extends State<_PhotoHeader> {
  bool _uploading = false;

  Future<void> _change() async {
    setState(() => _uploading = true);
    await _saveImage(context, widget.user.reference, 'photo_url',
        () => pickImageAsDataUrl(context, maxSide: 400));
    if (mounted) {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AvatarImage(widget.user.photoUrl, size: 110.0),
            if (_uploading)
              const SizedBox(
                  width: 110.0,
                  height: 110.0,
                  child: CircularProgressIndicator()),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: const Color(0xFF8B4513),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Change profile picture',
                  icon: const Icon(Icons.photo_camera, color: Colors.white),
                  onPressed: _uploading ? null : _change,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Text(
          widget.user.displayName.isEmpty
              ? 'No name yet'
              : widget.user.displayName,
          style: theme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RoleDetails extends StatelessWidget {
  const _RoleDetails({required this.role, required this.userRef});

  final ProfileRole role;
  final DocumentReference userRef;

  Widget _missing(BuildContext context, String what) => _Section(
        title: what,
        children: [
          Text('Not set up yet. Tap Edit Profile to add your details.',
              style: FlutterFlowTheme.of(context).labelMedium),
        ],
      );

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case ProfileRole.customer:
        return StreamBuilder<List<CustomersRecord>>(
          stream: queryCustomersRecord(
            queryBuilder: (q) => q.where('customer_id', isEqualTo: userRef),
            singleRecord: true,
          ),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox.shrink();
            }
            if (snap.data!.isEmpty) {
              return _missing(context, 'Delivery Details');
            }
            final c = snap.data!.first;
            return _Section(title: 'Delivery Details', children: [
              _InfoRow('Name', '${c.firstName} ${c.lastName}'.trim()),
              _InfoRow('Address', c.deliveryAddress),
            ]);
          },
        );
      case ProfileRole.businessOwner:
        return StreamBuilder<List<RestaurantsRecord>>(
          stream: queryRestaurantsRecord(
            queryBuilder: (q) => q.where('owner_id', isEqualTo: userRef),
            singleRecord: true,
          ),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox.shrink();
            }
            if (snap.data!.isEmpty) {
              return _missing(context, 'Restaurant');
            }
            return _RestaurantSection(restaurant: snap.data!.first);
          },
        );
      case ProfileRole.rider:
        return StreamBuilder<List<RiderRecord>>(
          stream: queryRiderRecord(
            queryBuilder: (q) => q.where('rider_id', isEqualTo: userRef),
            singleRecord: true,
          ),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox.shrink();
            }
            if (snap.data!.isEmpty) {
              return _missing(context, 'Vehicle');
            }
            final r = snap.data!.first;
            return _Section(title: 'Vehicle', children: [
              _InfoRow('Name', '${r.firstName} ${r.lastName}'.trim()),
              _InfoRow('Type', r.vehicleType),
              _InfoRow('Brand / Model',
                  [r.vehicleBrand, r.vehicleModel].where((s) => s.isNotEmpty).join(' ')),
              _InfoRow('Color', r.vehicleColor),
            ]);
          },
        );
    }
  }
}

class _RestaurantSection extends StatefulWidget {
  const _RestaurantSection({required this.restaurant});

  final RestaurantsRecord restaurant;

  @override
  State<_RestaurantSection> createState() => _RestaurantSectionState();
}

class _RestaurantSectionState extends State<_RestaurantSection> {
  bool _uploading = false;

  Future<void> _changeLogo() async {
    setState(() => _uploading = true);
    await _saveImage(context, widget.restaurant.reference, 'logo',
        () => pickImageAsDataUrl(context, maxSide: 600));
    if (mounted) {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    return _Section(title: 'Restaurant', children: [
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: AppImage(r.logo,
                width: 72.0, height: 72.0, placeholderIcon: Icons.storefront),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: _uploading
                ? const LinearProgressIndicator()
                : TextButton.icon(
                    onPressed: _changeLogo,
                    icon: const Icon(Icons.upload),
                    label: const Text('Change restaurant logo'),
                  ),
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      _InfoRow('Name', r.restaurantName),
      _InfoRow('Address', r.address),
      _InfoRow('Description', r.shortDescription),
      _InfoRow('Business Permit', r.businessPermit),
    ]);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.titleMedium),
            const SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130.0, child: Text(label, style: theme.labelMedium)),
          Expanded(
            child: Text(value.isEmpty ? '—' : value, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: theme.secondaryBackground,
      child: ListTile(
        leading: Icon(icon, color: theme.secondaryText),
        title: Text(label, style: theme.bodyLarge),
        trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
        onTap: onTap,
      ),
    );
  }
}
