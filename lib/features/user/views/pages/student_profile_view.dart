/// Student profile view displaying user profile information
library;

import 'package:flutter/material.dart';
import 'package:opencms/features/user/models/user_models.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../../services/profile_service.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_photo_widget.dart';
import '../../../shared/views/views/list_section.dart';
import '../../../shared/views/views/refreshable_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/shared/views/widgets/custom_scroll_view.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends RefreshableView<StudentProfileView> {
  final ProfileService _profileService = ProfileService();
  ProfileResponse? _profile;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final result = await _profileService.getProfile(refresh: true);
    _profile = result;
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_profile == null) {
      return const Center(child: Text('No profile data available'));
    }

    return CustomChildScrollView(
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
          ListSection(
            title: 'Personal Information',
            icon: Symbols.person_rounded,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Student ID',
                      value: _profile!.generalInfo.id.toString(),
                      icon: Symbols.badge_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Status',
                      value: _profile!.generalInfo.isActive
                          ? 'Active'
                          : 'Inactive',
                      icon: Symbols.check_circle_rounded,
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
                      icon: Symbols.translate_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'English Name',
                      value: _profile!.generalInfo.enName,
                      icon: Symbols.language_rounded,
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
                      icon: Symbols.assignment_ind_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Form Group',
                      value: _profile!.generalInfo.formGroup,
                      icon: Symbols.group_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Academic & Residential Information
          ListSection(
            title: 'Academic & Residential',
            icon: Symbols.school_rounded,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Grade',
                      value: _profile!.basicInfo.grade,
                      icon: Symbols.school_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'House',
                      value: _profile!.basicInfo.house,
                      icon: Symbols.home_rounded,
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
                      icon: Symbols.bed_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Type',
                      value: _profile!.basicInfo.dormitoryKind,
                      icon: Symbols.hotel_rounded,
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
                      icon: Symbols.wc_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Enrolled',
                      value: _profile!.basicInfo.enrollment,
                      icon: Symbols.calendar_today_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contact Information
          ListSection(
            title: 'Contact Information',
            icon: Symbols.contact_phone_rounded,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ProfileInfoCard(
                      title: 'Mobile',
                      value: _profile!.basicInfo.mobile,
                      icon: Symbols.phone_rounded,
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
                      icon: Symbols.email_rounded,
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
                icon: Symbols.alternate_email_rounded,
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
    );
  }

  @override
  String get errorTitle => 'Error loading profile';

  @override
  String get emptyTitle => 'No profile data available';

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
