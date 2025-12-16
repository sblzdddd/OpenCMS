import 'package:flutter/material.dart';
import 'keep_alive_wrapper.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_scaffold.dart';

/// Base widget for pages with tabs that provides common tab functionality
class TabbedPageBase extends StatefulWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final int initialTabIndex;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool isTransparent;
  final List<String> skinKey;

  const TabbedPageBase({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    this.initialTabIndex = 0,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.isTransparent = false,
    this.skinKey = const ['global'],
  });

  @override
  State<TabbedPageBase> createState() => _TabbedPageBaseState();
}

class _TabbedPageBaseState extends State<TabbedPageBase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // This will trigger a rebuild with the new skinKey
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isTransparent: widget.isTransparent,
      skinKey: widget.skinKey[_tabController.index],
      appBar: CustomAppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        actions: widget.actions,
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.tabs,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.tabViews
            .map((view) => KeepAliveWrapper(child: view))
            .toList(),
      ),
    );
  }
}
