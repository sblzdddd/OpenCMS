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
          // Placeholder: launch or navigate to the chosen action
          // Integrate real navigation when available
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Launching: '+action['title'])),
          );
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        _isEditMode ? IconButton(
                          onPressed: _isLoading ? null : _onResetActions,
                          icon: const Icon(Symbols.restart_alt_rounded),
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            fixedSize: const Size(32, 32),
                          ),
                          tooltip: 'Reset to default',
                        ) : const SizedBox.shrink(),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _isEditMode = !_isEditMode;
                            });
                          },
                          icon: Icon(_isEditMode ? Symbols.done_rounded : Symbols.edit_rounded),
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            fixedSize: const Size(32, 32),
                            backgroundColor: _isEditMode 
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                : null,
                            foregroundColor: _isEditMode 
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          tooltip: _isEditMode ? 'Done' : 'Edit',
                        ),
                      ],
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
                        const double minSpacing = 0.0;
                        const double itemWidth = 100.0;
                        const int itemHeight = 110;

                        final double availableWidth = constraints.maxWidth;
                        final int itemsPerRow =
                            ((availableWidth + minSpacing) / (itemWidth + minSpacing)).floor();

                        if (_isEditMode) {
                          // Build draggable action items
                          final List<Widget> displayChildren = actions
                              .map<Widget>((action) => ActionItem(
                                    action: action,
                                    isEditMode: true,
                                    onTap: action['id'] == QuickActionsConstants.moreAction['id']
                                        ? _onShowMoreActions
                                        : null,
                                  ))
                              .toList();

                          // Add edit utilities
                          displayChildren.add(const TrashCanItem());
                          displayChildren.add(AddActionItem(onTap: _onAddAction));

                          // Add spacers to keep last row left-aligned
                          if (itemsPerRow > 0) {
                            final int remainder = (actions.length + 2) % itemsPerRow;
                            if (remainder != 0) {
                              final int spacersNeeded = itemsPerRow - remainder;
                              for (int i = 0; i < spacersNeeded; i++) {
                                displayChildren.add(
                                  IgnorePointer(
                                    child: SizedBox(
                                      key: ValueKey('spacer_qa_$i'),
                                      width: itemWidth,
                                      height: itemHeight.toDouble(),
                                    ),
                                  ),
                                );
                              }
                            }
                          }

                          return ReorderableWrap(
                            spacing: minSpacing,
                            runSpacing: 0,
                            alignment: WrapAlignment.spaceBetween,
                            isEditMode: true,
                            onReorder: _onReorder,
                            onRemove: _onRemove,
                            onAdd: _onAddAction,
                            children: displayChildren,
                          );
                        } else {
                          // Non-edit mode: static items
                          final List<Widget> displayChildren = actions
                              .map<Widget>((action) => ActionItem(
                                    action: action,
                                    isEditMode: false,
                                    onTap: action['id'] == QuickActionsConstants.moreAction['id']
                                        ? _onShowMoreActions
                                        : null,
                                  ))
                              .toList();

                          if (itemsPerRow > 0) {
                            final int remainder = actions.length % itemsPerRow;
                            if (remainder != 0) {
                              final int spacersNeeded = itemsPerRow - remainder;
                              for (int i = 0; i < spacersNeeded; i++) {
                                displayChildren.add(
                                  IgnorePointer(
                                    child: SizedBox(
                                      key: ValueKey('spacer_qa_view_$i'),
                                      width: itemWidth,
                                      height: itemHeight.toDouble(),
                                    ),
                                  ),
                                );
                              }
                            }
                          }

                          return Wrap(
                            spacing: minSpacing,
                            runSpacing: 0,
                            alignment: WrapAlignment.spaceBetween,
                            children: displayChildren,
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
