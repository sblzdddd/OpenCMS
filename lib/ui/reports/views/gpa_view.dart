import 'package:flutter/material.dart';
import 'package:opencms/ui/web_cms/web_cms_content.dart';
import 'package:opencms/data/constants/api_endpoints.dart';
import 'package:opencms/services/auth/auth_service.dart';

class MyGpaView extends StatelessWidget {
  const MyGpaView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final url = '${ApiConstants.legacyCMSBaseUrl}/${authService.userInfo!.username}/gpa/';
    return WebCmsContent(initialUrl: url);
  }
}
