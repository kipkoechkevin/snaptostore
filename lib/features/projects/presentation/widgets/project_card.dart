import 'package:flutter/material.dart';
import 'package:snaptostore/core/theme/app_colors.dart';

class ProjectCard extends StatelessWidget {
final String title;
final String businessType;
final String status;
final String lastModified;
final String? thumbnailUrl;
final VoidCallback? onTap;
final VoidCallback? onLongPress;

const ProjectCard({
  super.key,
  required this.title,
  required this.businessType,
  required this.status,
  required this.lastModified,
  this.thumbnailUrl,
  this.onTap,
  this.onLongPress,
});

@override
Widget build(BuildContext context) {
  return Card(
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(),
          _buildProjectInfo(),
        ],
      ),
    ),
  );
}

Widget _buildThumbnail() {
  return Expanded(
    flex: 3,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: thumbnailUrl == null 
            ? LinearGradient(
                colors: [
                  _getBusinessTypeColor().withOpacity(0.3),
                  _getBusinessTypeColor().withOpacity(0.1),
                ],
              )
            : null,
      ),
      child: thumbnailUrl != null
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                thumbnailUrl!,
                fit: BoxFit.cover,
              ),
            )
          : Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
    ),
  );
}

Widget _buildStatusBadge() {
  return Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget _buildProjectInfo() {
  return Expanded(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getBusinessTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  businessType,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getBusinessTypeColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _getStatusIcon(),
                size: 12,
                color: _getStatusColor(),
              ),
            ],
          ),
          const Spacer(),
          Text(
            lastModified,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getBusinessTypeColor() {
  switch (businessType.toLowerCase()) {
    case 'thrift':
      return AppColors.thriftBoss;
    case 'boutique':
      return AppColors.boutiqueBoss;
    case 'beauty':
      return AppColors.beautyBoss;
    case 'handmade':
      return AppColors.handmadeBoss;
    default:
      return AppColors.primary;
  }
}

Color _getStatusColor() {
  switch (status.toLowerCase()) {
    case 'completed':
      return AppColors.success;
    case 'draft':
      return AppColors.warning;
    case 'archived':
      return AppColors.textTertiary;
    default:
      return AppColors.info;
  }
}

IconData _getStatusIcon() {
  switch (status.toLowerCase()) {
    case 'completed':
      return Icons.check_circle;
    case 'draft':
      return Icons.edit;
    case 'archived':
      return Icons.archive;
    default:
      return Icons.circle;
  }
}
}