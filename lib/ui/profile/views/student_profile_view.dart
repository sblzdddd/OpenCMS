/// Student profile view displaying user profile information
library;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../../data/models/profile/profile.dart';
import '../../../services/profile/profile_service.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_photo_widget.dart';
import '../widgets/profile_section.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final ProfileService _profileService = ProfileService();
  ProfileResponse? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _profileService.getProfileSafe(refresh: true);

      if (result.isSuccess && result.profile != null) {
        setState(() {
          _profile = result.profile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(child: Text('No profile data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              ProfilePhotoWidget(
                photoUrl: _profile!.generalInfo.photo,
                name: _profile!.generalInfo.displayName,
                studentId: _profile!.generalInfo.id.toString(),
                studentType: _profile!.generalInfo.dormitoryKind,
                formGroup: _profile!.generalInfo.formGroup,
                house: _profile!.basicInfo.house,
              ),

              const SizedBox(height: 16),

              // Personal Information (2-column layout)
              ProfileSection(
                title: 'Personal Information',
                icon: Icons.person,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Student ID',
                          value: _profile!.generalInfo.id.toString(),
                          icon: Icons.badge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Status',
                          value: _profile!.generalInfo.isActive
                              ? 'Active'
                              : 'Inactive',
                          icon: Icons.check_circle,
                          valueColor: _profile!.generalInfo.isActive
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Chinese Name',
                          value: _profile!.generalInfo.name,
                          icon: Icons.translate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'English Name',
                          value: _profile!.generalInfo.enName,
                          icon: Icons.language,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Full Name',
                          value: _profile!.generalInfo.fullName,
                          icon: Icons.assignment_ind,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Form Group',
                          value: _profile!.generalInfo.formGroup,
                          icon: Icons.group,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Academic & Residential Information
              ProfileSection(
                title: 'Academic & Residential',
                icon: Icons.school,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Grade',
                          value: _profile!.basicInfo.grade,
                          icon: Icons.school,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'House',
                          value: _profile!.basicInfo.house,
                          icon: Icons.home,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Dormitory',
                          value: _profile!.basicInfo.dormitory,
                          icon: Icons.bed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Type',
                          value: _profile!.basicInfo.dormitoryKind,
                          icon: Icons.hotel,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Gender',
                          value: _profile!.basicInfo.gender,
                          icon: Icons.wc,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Enrolled',
                          value: _profile!.basicInfo.enrollment,
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contact Information
              ProfileSection(
                title: 'Contact Information',
                icon: Icons.contact_phone,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'Mobile',
                          value: _profile!.basicInfo.mobile,
                          icon: Icons.phone,
                          isClickable: true,
                          onTap: () => _showContactDialog(
                            'Mobile',
                            _profile!.basicInfo.mobile,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileInfoCard(
                          title: 'School Email',
                          value: _profile!.basicInfo.schoolEmail,
                          icon: Icons.email,
                          isClickable: true,
                          onTap: () => _showContactDialog(
                            'School Email',
                            _profile!.basicInfo.schoolEmail,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ProfileInfoCard(
                    title: 'Personal Email',
                    value: _profile!.basicInfo.studentEmail,
                    icon: Icons.alternate_email,
                    isClickable: true,
                    onTap: () => _showContactDialog(
                      'Personal Email',
                      _profile!.basicInfo.studentEmail,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactDialog(String type, String value) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        title: Text(type),
        content: SelectableText(value),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
