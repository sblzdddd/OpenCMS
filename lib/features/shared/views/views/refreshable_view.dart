import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../error/error_placeholder.dart';
import '../error/empty_placeholder.dart';
import '../custom_snackbar/snackbar_utils.dart';
import 'package:logging/logging.dart';
import 'package:dio/dio.dart';

final logger = Logger('RefreshableView');

/// Abstract base class for pages that need refresh functionality with loading and error states
abstract class RefreshableView<T extends StatefulWidget> extends State<T> {
  bool isTransparent = false;
  bool _isLoading = true;
  String? _error;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  RefreshableView({this.isTransparent = false});

  /// Get the theme notifier from Provider
  ThemeNotifier get themeNotifier =>
      Provider.of<ThemeNotifier>(context, listen: true);

  /// Override this to provide the main data fetching logic
  Future<void> fetchData({bool refresh = false});

  /// Override this to build the main content when data is loaded successfully
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier);

  /// Override this to provide custom loading widget (optional)
  Widget buildLoadingWidget(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  /// Override this to provide custom empty state widget (optional)
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

  /// Override this to provide custom error title (optional)
  String get errorTitle => 'Error loading data';

  /// Override this to provide custom empty title (optional)
  String get emptyTitle => 'No data available';

  /// Override this to check if data is empty (optional)
  bool get isEmpty => false;

  /// Get the current loading state
  bool get isLoading => _isLoading;

  /// Get the current error
  String? get error => _error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Load data with error handling
  Future<void> loadData({bool refresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await fetchData(refresh: refresh);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (refresh) {
          SnackbarUtils.showSuccess(context, 'Data refreshed successfully');
        }
      }
    } catch (e, stackTrace) {
      logger.severe('Error loading data: $e', e, stackTrace);
      if (mounted) {
        String errorMessage = e.toString();
        if (e is DioException) {
          errorMessage = e.message ?? e.toString();
        }
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  /// Build the page content with refresh indicator
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => loadData(refresh: true),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          ErrorPlaceholder(
            title: errorTitle,
            errorMessage: _error!,
            onRetry: () => loadData(refresh: true),
          ),
        ],
      );
    }

    if (_isLoading) {
      return buildLoadingWidget(context);
    }

    if (isEmpty) {
      return buildEmptyWidget(context, themeNotifier);
    }

    return buildContent(context, themeNotifier);
  }
}
