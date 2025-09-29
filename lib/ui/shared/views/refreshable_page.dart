import 'package:flutter/material.dart';
import 'refreshable_view.dart';
import '../../../services/theme/theme_services.dart';
import '../../../ui/shared/widgets/custom_app_bar.dart';
import '../../../ui/shared/widgets/custom_scaffold.dart';
export '../../../services/theme/theme_services.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/error/empty_placeholder.dart';

/// A refreshable page that provides a scaffold with a customizable app bar
abstract class RefreshablePage<T extends StatefulWidget> extends RefreshableView<T> {
  final bool isTransparent;
  final String skinKey;
  RefreshablePage({this.isTransparent = false, this.skinKey = 'global'});

  /// Override this to provide a custom app bar title
  String get appBarTitle => 'Page';

  /// Override this to provide custom app bar actions
  List<Widget>? get appBarActions => null;

  /// Override this to provide custom app bar leading widget
  Widget? get appBarLeading => null;

  /// Override this to provide custom app bar background color
  Color? get appBarBackgroundColor => null;

  /// Override this to provide custom app bar foreground color
  Color? get appBarForegroundColor => null;

  /// Override this to provide custom app bar elevation
  double? get appBarElevation => null;

  /// Override this to provide custom body padding
  EdgeInsets get bodyPadding => const EdgeInsets.all(8);

  /// Override this to provide custom body background color
  Color? get bodyBackgroundColor => null;

  /// Override this to provide custom empty title (optional)
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
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      physics: const BouncingScrollPhysics(),
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
