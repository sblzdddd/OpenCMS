/// Profile page containing the student profile view
library;

import 'package:flutter/material.dart';
import '../views/student_profile_view.dart';
import '../../../ui/shared/widgets/custom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Student Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: const StudentProfileView(),
    );
  }
}
