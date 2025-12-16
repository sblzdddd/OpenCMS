import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/services/theme_services.dart';
import 'action_item/action_item.dart';
import 'action_dialog/more_actions_dialog.dart';
import 'action_item/trash_can_item.dart';
import 'reorderable_wrap.dart';

import '../../../../shared/constants/quick_actions.dart';
import '../../../services/quick_actions_storage_service.dart';

/// Controller to trigger actions on QuickActions from parent widgets
class QuickActionsController extends ChangeNotifier {
  void Function(Map<String, dynamic> action)? _addActionHandler;
  void Function()? _resetHandler;
  List<Map<String, dynamic>> Function()? _getAddableActionsHandler;

  void addAction(Map<String, dynamic> action) {
    _addActionHandler?.call(action);
  }

  void resetActions() async {
    if (_resetHandler != null) {
      _resetHandler!.call();
      return;
    }
    // Fallback: write default actions directly to storage
    final QuickActionsStorageService storage = QuickActionsStorageService();
    final List<String> defaults = List<String>.from(
      QuickActionsConstants.defaultActionIds,
    );
    await storage.saveQuickActionsPreferences(defaults);
    notifyListeners();
  }

  List<Map<String, dynamic>> getAddableActions() {
    final handler = _getAddableActionsHandler;
    if (handler != null) {
      return handler();
    }
    // Fallback: compute from defaults when state not bound yet
    final currentIds = List<String>.from(
      QuickActionsConstants.defaultActionIds,
    );
    return QuickActionsConstants.getAvailableActionsToAdd(currentIds);
  }
}

class QuickActions extends StatefulWidget {
  final QuickActionsController? controller;
  const QuickActions({super.key, this.controller});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  bool _isEditMode = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> actions = [];
  final QuickActionsStorageService _storageService =
      QuickActionsStorageService();

  @override
  void initState() {
    super.initState();
    _loadQuickActionsPreferences();
    // Bind controller command handlers
    widget.controller?._addActionHandler = (action) {
      setState(() {
        actions.add(action);
      });
      _saveQuickActionsPreferences();
    };
    widget.controller?._resetHandler = () async {
      setState(() {
        actions = QuickActionsConstants.getActionsFromIds(
          QuickActionsConstants.defaultActionIds,
        );
        actions.add(QuickActionsConstants.moreAction);
      });
      await _saveQuickActionsPreferences();
    };
    widget.controller?._getAddableActionsHandler = () {
      final currentActionIds = QuickActionsConstants.getIdsFromActions(actions);
      return QuickActionsConstants.getAvailableActionsToAdd(currentActionIds);
    };
  }

  /// Load user's quick actions preferences from secure storage
  Future<void> _loadQuickActionsPreferences() async {
    try {
      final savedActionIds = await _storageService
          .loadQuickActionsPreferences();

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
      final hasMore = actions.any(
        (a) => a['id'] == QuickActionsConstants.moreAction['id'],
      );
      if (!hasMore) {
        actions.add(QuickActionsConstants.moreAction);
      }
    } catch (e) {
      debugPrint('QuickActions: Error loading quick actions preferences: $e');
      // Fallback to default actions
      actions = QuickActionsConstants.getActionsFromIds(
        QuickActionsConstants.defaultActionIds,
      );
      // Ensure persistent More... action exists
      final hasMore = actions.any(
        (a) => a['id'] == QuickActionsConstants.moreAction['id'],
      );
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
      debugPrint('QuickActions: Error saving quick actions preferences: $e');
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

  /// Handle showing hidden actions (More...)
  void _onShowMoreActions() {
    final currentActionIds = QuickActionsConstants.getIdsFromActions(actions);
    showDialog(
      context: context,
      builder: (context) => MoreActionsDialog(
        currentActionIds: currentActionIds,
        onActionChosen: (action) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 12,
                top: 12,
              ),
              decoration: BoxDecoration(
                color: themeNotifier.needTransparentBG
                    ? (!themeNotifier.isDarkMode
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.surfaceContainer
                                .withValues(alpha: 0.8))
                    : Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: themeNotifier.getBorderRadiusAll(1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            const double spacing = 10.0;
                            const double minTileWidth = 100.0;
                            // Item height is determined by each tile

                            final double availableWidth = constraints.maxWidth;
                            // Determine number of columns based on available width and minimum tile width
                            final int columns =
                                (((availableWidth + spacing) /
                                            (minTileWidth + spacing))
                                        .floor())
                                    .clamp(1, 8);
                            final double tileWidth =
                                (availableWidth - (columns - 1) * spacing) /
                                columns;

                            // Build draggable action items with stable keys
                            final List<Widget> displayChildren = actions
                                .map<Widget>(
                                  (action) => ActionItem(
                                    key: ValueKey('action_${action['id']}'),
                                    action: action,
                                    isEditMode: _isEditMode,
                                    onTap:
                                        action['id'] ==
                                            QuickActionsConstants
                                                .moreAction['id']
                                        ? _onShowMoreActions
                                        : null,
                                    tileWidth: tileWidth,
                                    onDelete:
                                        action['id'] ==
                                            QuickActionsConstants
                                                .moreAction['id']
                                        ? null
                                        : () {
                                            final String id =
                                                action['id'] as String;
                                            final int currentIndex = actions
                                                .indexWhere(
                                                  (a) => a['id'] == id,
                                                );
                                            if (currentIndex != -1) {
                                              _onRemove(currentIndex);
                                            }
                                          },
                                  ),
                                )
                                .toList();

                            if (_isEditMode) {
                              // Full-width trash can row
                              displayChildren.add(
                                SizedBox(
                                  key: const ValueKey('trash_can'),
                                  width: availableWidth,
                                  child: TrashCanItem(
                                    tileWidth: availableWidth,
                                  ),
                                ),
                              );
                            }
                            return ReorderableWrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              alignment: WrapAlignment.start,
                              isEditMode: _isEditMode,
                              wrapId:
                                  'quick_actions', // Unique identifier for this wrap
                              onReorderStart: () {
                                setState(() {
                                  _isEditMode = true;
                                });
                              },
                              onReorderEnd: () {
                                if (mounted) {
                                  setState(() => _isEditMode = false);
                                }
                              },
                              onReorder: _onReorder,
                              onRemove: _onRemove,
                              children: displayChildren,
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
