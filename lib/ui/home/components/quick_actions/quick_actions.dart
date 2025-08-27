import 'package:flutter/material.dart';
import 'action_item/action_item.dart';
import 'action_item/add_action_item.dart';
import 'action_dialog/add_action_dialog.dart';
import 'action_dialog/more_actions_dialog.dart';
import 'action_item/trash_can_item.dart';
import 'reorderable_wrap.dart';

import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../data/constants/quick_actions_constants.dart';
import '../../../../services/quick_actions/quick_actions_storage_service.dart';

class QuickActions extends StatefulWidget {
  const QuickActions({super.key});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  bool _isEditMode = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> actions = [];
  final QuickActionsStorageService _storageService = QuickActionsStorageService();

  @override
  void initState() {
    super.initState();
    _loadQuickActionsPreferences();
  }

  /// Load user's quick actions preferences from secure storage
  Future<void> _loadQuickActionsPreferences() async {
    try {
      final savedActionIds = await _storageService.loadQuickActionsPreferences();
      
      if (savedActionIds != null && savedActionIds.isNotEmpty) {
        // Load actions from saved preferences
        actions = QuickActionsConstants.getActionsFromIds(savedActionIds);
      } else {
        // Use default actions for first time users
        actions = QuickActionsConstants.getActionsFromIds(
          QuickActionsConstants.defaultActionIds,
        );
        // Save the default preferences
        await _saveQuickActionsPreferences();
      }
      // Ensure persistent More... action exists
      final hasMore = actions.any((a) => a['id'] == QuickActionsConstants.moreAction['id']);
      if (!hasMore) {
        actions.add(QuickActionsConstants.moreAction);
      }
    } catch (e) {
      print('Error loading quick actions preferences: $e');
      // Fallback to default actions
      actions = QuickActionsConstants.getActionsFromIds(
        QuickActionsConstants.defaultActionIds,
      );
      // Ensure persistent More... action exists
      final hasMore = actions.any((a) => a['id'] == QuickActionsConstants.moreAction['id']);
      if (!hasMore) {
        actions.add(QuickActionsConstants.moreAction);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Save current quick actions preferences to secure storage
  Future<void> _saveQuickActionsPreferences() async {
    try {
      final actionIds = QuickActionsConstants.getIdsFromActions(actions);
      await _storageService.saveQuickActionsPreferences(actionIds);
    } catch (e) {
      print('Error saving quick actions preferences: $e');
    }
  }

  /// Handle reordering of actions
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = actions.removeAt(oldIndex);
      actions.insert(newIndex, item);
    });
    _saveQuickActionsPreferences();
  }

  /// Handle removal of actions
  void _onRemove(int index) {
    setState(() {
      if (index >= 0 && index < actions.length) {
        final item = actions[index];
        if (item['id'] != QuickActionsConstants.moreAction['id']) {
          actions.removeAt(index);
        }
      }
    });
    _saveQuickActionsPreferences();
  }

  /// Handle adding new actions
  void _onAddAction() {
    final currentActionIds = QuickActionsConstants.getIdsFromActions(actions);
    
    showDialog(
      context: context,
      builder: (context) => AddActionDialog(
        currentActionIds: currentActionIds,
        onActionSelected: (action) {
          setState(() {
            actions.add(action);
          });
          _saveQuickActionsPreferences();
        },
      ),
    );
  }

  /// Handle showing hidden actions (More...)
  void _onShowMoreActions() {
    final currentActionIds = QuickActionsConstants.getIdsFromActions(actions);
    showDialog(
      context: context,
      builder: (context) => MoreActionsDialog(
        currentActionIds: currentActionIds,
        onActionChosen: (action) {
        },
      ),
    );
  }

  /// Reset to default actions (plus persistent More...)
  void _onResetActions() async {
    setState(() {
      actions = QuickActionsConstants.getActionsFromIds(
        QuickActionsConstants.defaultActionIds,
      );
      actions.add(QuickActionsConstants.moreAction);
    });
    await _saveQuickActionsPreferences();
  }

  /// Exit edit mode
  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14, top: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actions',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (_isEditMode) IconButton(
                          onPressed: _isLoading ? null : _onResetActions,
                          icon: const Icon(Symbols.restart_alt_rounded),
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            fixedSize: const Size(30, 30),
                          ),
                          tooltip: 'Reset to default',
                        ),
                      ],
                    ),
                  ),
                  _isLoading 
                      ? SizedBox(
                          height: 110,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          const double spacing = 12.0;
                          const double minTileWidth = 110.0;
                          // Item height is determined by each tile

                          final double availableWidth = constraints.maxWidth;
                          // Determine number of columns based on available width and minimum tile width
                          final int columns = (((availableWidth + spacing) /
                                      (minTileWidth + spacing))
                                  .floor())
                              .clamp(1, 8);
                          final double tileWidth =
                              (availableWidth - (columns - 1) * spacing) / columns;

                          // Build draggable action items with stable keys
                          final List<Widget> displayChildren = actions
                              .map<Widget>((action) => ActionItem(
                                    key: ValueKey('action_${action['id']}'),
                                    action: action,
                                    isEditMode: _isEditMode,
                                    onTap: action['id'] == QuickActionsConstants.moreAction['id']
                                        ? _onShowMoreActions
                                        : null,
                                    tileWidth: tileWidth,
                                  ))
                              .toList();

                          if (_isEditMode) {
                            // Add edit utilities with stable keys
                            displayChildren.add(TrashCanItem(
                              key: const ValueKey('trash_can'),
                              tileWidth: tileWidth,
                            ));
                            displayChildren.add(AddActionItem(
                              key: const ValueKey('add_action'),
                              onTap: _onAddAction,
                              tileWidth: tileWidth,
                            ));
                          }
                          return ReorderableWrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            alignment: WrapAlignment.start,
                            isEditMode: _isEditMode,
                            wrapId: 'quick_actions', // Unique identifier for this wrap
                            onReorderStart: () {
                              setState(() {
                                _isEditMode = true;
                              });
                            },
                            onReorder: _onReorder,
                            onRemove: _onRemove,
                            onAdd: _onAddAction,
                            children: displayChildren,
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
        // FAB to exit edit mode
        if (_isEditMode)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _exitEditMode,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Symbols.check_rounded),
              tooltip: 'Done',
            ),
          ),
      ],
    );
  }
}
