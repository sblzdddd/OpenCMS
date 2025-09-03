import 'package:flutter/material.dart';
import 'refreshable_view.dart';

/// A refreshable page that provides a scaffold with a customizable app bar
abstract class RefreshablePage<T extends StatefulWidget> extends RefreshableView<T> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: appBarLeading,
        actions: appBarActions,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        elevation: appBarElevation,
      ),
      backgroundColor: bodyBackgroundColor,
      body: super.build(context),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: bodyPadding,
      physics: const AlwaysScrollableScrollPhysics(),
      child: buildPageContent(context),
    );
  }

  /// Override this to build the main page content
  Widget buildPageContent(BuildContext context);

  @override
  Widget buildLoadingWidget(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
