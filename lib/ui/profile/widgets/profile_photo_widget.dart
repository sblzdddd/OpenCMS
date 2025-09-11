/// Profile photo widget with user information
library;

import 'package:flutter/material.dart';
import '../../../services/theme/theme_services.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String studentId;
  final String studentType;
  final String formGroup;
  final String? house;

  const ProfilePhotoWidget({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.studentId,
    required this.studentType,
    required this.formGroup,
    this.house,
  });

  @override
  Widget build(BuildContext context) {
    // Get house-based color or fallback to global theme
    final houseColor = house != null && house!.isNotEmpty 
        ? ThemeNotifier.getHouseColor(house)
        : Theme.of(context).colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            houseColor.withOpacity(0.1),
            houseColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: houseColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Profile Photo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: houseColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: houseColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: houseColor,
                  ),
                ),
                
                const SizedBox(height: 2),

                Row(
                  children: [
                    Text(
                      studentId,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formGroup,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: houseColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2),

                Text(
                  studentType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
