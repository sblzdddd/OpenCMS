import 'package:flutter/material.dart';
import 'refreshable_view.dart';
import '../../../services/theme/theme_services.dart';
import '../../../ui/shared/widgets/custom_app_bar.dart';
import '../../../ui/shared/widgets/custom_scaffold.dart';
export '../../../services/theme/theme_services.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/error/empty_placeholder.dart';

/// A refreshable page that provides a scaffold with a customizable app bar
abstract class RefreshablePage<T extends StatefulWidget>
    extends RefreshableView<T> {
  final String skinKey;
  RefreshablePage({super.isTransparent = false, this.skinKey = 'global'});

  String get appBarTitle => 'Page';
  List<Widget>? get appBarActions => null;
  Widget? get appBarLeading => null;
  Color? get appBarBackgroundColor => null;
  Color? get appBarForegroundColor => null;
  double? get appBarElevation => null;
  EdgeInsets get bodyPadding => const EdgeInsets.all(8);
  Color? get bodyBackgroundColor => null;

  @override
  String get emptyTitle => 'No data available';

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isTransparent: isTransparent,
      skinKey: skinKey,
      appBar: CustomAppBar(
        title: Text(appBarTitle),
        leading: appBarLeading,
        actions: appBarActions,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        elevation: appBarElevation,
      ),
      body: super.build(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    return CustomChildScrollView(
      padding: bodyPadding,
      child: buildPageContent(context, themeNotifier),
    );
  }

  /// Override this to build the main page content
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier);

  @override
  Widget buildLoadingWidget(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        EmptyPlaceholder(
          title: emptyTitle,
          onRetry: () => loadData(refresh: true),
        ),
      ],
    );
  }
}
