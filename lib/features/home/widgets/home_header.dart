import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../auth/auth.dart';

class HomeHeader extends ConsumerWidget {
final UserModel? user;

const HomeHeader({super.key, required this.user});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24,
      right: 24,
      bottom: 24,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorScheme.primary,
          colorScheme.primary.withOpacity(0.8),
        ],
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row
        Row(
          children: [
            // Profile Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: user?.profileImageUrl != null
                    ? Image.network(
                        user!.profileImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
              ),
            ),

            const Spacer(),

            // Notifications
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Settings
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Greeting
        Text(
          _getGreeting(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          user?.fullName ?? 'Creative Entrepreneur',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 16),

        // Business Type Badge
        if (user?.businessType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getBusinessTypeLabel(user!.businessType!),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ),
  );
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _getBusinessTypeLabel(String businessType) {
  switch (businessType) {
    case 'thrift':
      return 'Thrift Boss';
    case 'boutique':
      return 'Boutique Boss';
    case 'beauty':
      return 'Beauty Boss';
    case 'handmade':
      return 'Handmade Boss';
    default:
      return 'Entrepreneur';
  }
}
}