import 'package:flutter/material.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/web_cms/views/components/web_cms_content.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';

class MyGpaView extends StatelessWidget {
  const MyGpaView({super.key});

  @override
  Widget build(BuildContext context) {
    final url =
        '${API.legacyCMSBaseUrl}/${di<LoginState>().currentUsername}/gpa/';
    return WebCmsContent(initialUrl: url);
  }
}
