import 'package:flutter/material.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/ui/web_cms/web_cms_content.dart';
import 'package:opencms/data/constants/api_endpoints.dart';

class MyGpaView extends StatelessWidget {
  const MyGpaView({super.key});

  @override
  Widget build(BuildContext context) {
    final url =
        '${API.legacyCMSBaseUrl}/${di<LoginState>().currentUsername}/gpa/';
    return WebCmsContent(initialUrl: url);
  }
}
