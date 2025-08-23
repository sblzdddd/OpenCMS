import 'package:flutter/material.dart';
import 'keep_alive_wrapper.dart';

/// Base widget for pages with tabs that provides common tab functionality
class TabbedPageBase extends StatefulWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final int initialTabIndex;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const TabbedPageBase({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    this.initialTabIndex = 0,
    this.actions,
    this.automaticallyImplyLeading = true,
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        actions: widget.actions,
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.tabs,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.tabViews.map((view) => KeepAliveWrapper(child: view)).toList(),
      ),
    );
  }
}
