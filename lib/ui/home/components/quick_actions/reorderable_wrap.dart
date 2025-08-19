import 'package:flutter/material.dart';
import 'action_item/trash_can_item.dart';

// Custom ReorderableWrap widget for grid drag-and-drop
class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index)? onRemove;
  final VoidCallback? onAdd;
  final VoidCallback? onReorderStart;
  final VoidCallback? onReorderEnd;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final bool isEditMode;

  const ReorderableWrap({
    super.key,
    required this.children,
    required this.onReorder,
    this.onRemove,
    this.onAdd,
    this.onReorderStart,
    this.onReorderEnd,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.alignment = WrapAlignment.start,
    this.isEditMode = false,
  });

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  int? _draggedIndex;
  int? _hoveredIndex;
  bool _isTrashCanHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      alignment: widget.alignment,
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final isTrashCan = child.key == const ValueKey('trash_can');
        final isAddAction = child.key == const ValueKey('add_action');
        final isIgnorePointer = child is IgnorePointer; // Check for spacer items
        
        // If it's trash can, add action, or spacer, don't make it draggable
        if (isTrashCan || isAddAction || isIgnorePointer) {
          return DragTarget<int>(
            onWillAcceptWithDetails: (details) {
              final draggedIndex = details.data;
              if (isTrashCan) {
                // Trash can accepts any dragged item (except itself)
                return draggedIndex != index;
              }
              return false; // Add action and spacers don't accept anything
            },
            onAcceptWithDetails: (details) {
              final draggedIndex = details.data;
              if (isTrashCan && widget.onRemove != null) {
                // Remove the dragged item
                widget.onRemove!(draggedIndex);
              }
              setState(() {
                _draggedIndex = null;
                _hoveredIndex = null;
                _isTrashCanHighlighted = false;
              });
            },
            onMove: (details) {
              if (isTrashCan && !_isTrashCanHighlighted) {
                setState(() {
                  _isTrashCanHighlighted = true;
                  _hoveredIndex = null;
                });
              }
            },
            onLeave: (_) {
              if (isTrashCan) {
                setState(() {
                  _isTrashCanHighlighted = false;
                });
              }
            },
            builder: (context, candidateData, rejectedData) {
              if (isTrashCan && _isTrashCanHighlighted) {
                // Return highlighted trash can
                return TrashCanItem(isHighlighted: true);
              }
              if (isAddAction) {
                // Add action item with tap handling
                return GestureDetector(
                  onTap: widget.onAdd,
                  child: child,
                );
              }
              return child;
            },
          );
        }
        
        // Regular draggable items
        return LongPressDraggable<int>(
          delay: const Duration(milliseconds: 300),
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.7,
              child: Transform.scale(
                scale: 1.1,
                child: child,
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: child,
          ),
          onDragStarted: () {
            setState(() {
              _draggedIndex = index;
            });
            // Call onReorderStart callback when dragging begins
            widget.onReorderStart?.call();
          },
          onDragEnd: (_) {
            setState(() {
              _draggedIndex = null;
              _hoveredIndex = null;
              _isTrashCanHighlighted = false;
            });
            // Call onReorderEnd callback when dragging ends
            widget.onReorderEnd?.call();
          },
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) {
              final draggedIndex = details.data;
              // Regular items accept reordering (not from trash can)
              return draggedIndex != index;
            },
            onAcceptWithDetails: (details) {
              final draggedIndex = details.data;
              // Reorder items
              widget.onReorder(draggedIndex, index);
              setState(() {
                _draggedIndex = null;
                _hoveredIndex = null;
                _isTrashCanHighlighted = false;
              });
            },
            onMove: (details) {
              if (_hoveredIndex != index) {
                setState(() {
                  _hoveredIndex = index;
                  _isTrashCanHighlighted = false;
                });
              }
            },
            onLeave: (_) {
              setState(() {
                _hoveredIndex = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              if (_hoveredIndex == index && _draggedIndex != index) {
                // Highlight regular items when reordering without changing size
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: child,
                );
              }
              return child;
            },
          ),
        );
      }).toList(),
    );
  }
}
