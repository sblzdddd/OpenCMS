import 'package:flutter/material.dart';
import 'action_item/trash_can_item.dart';

// Custom ReorderableWrap widget for grid drag-and-drop
class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index)? onRemove;
  final VoidCallback? onReorderStart;
  final VoidCallback? onReorderEnd;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final bool isEditMode;
  final String? wrapId; // Unique identifier for this wrap instance

  const ReorderableWrap({
    super.key,
    required this.children,
    required this.onReorder,
    this.onRemove,
    this.onReorderStart,
    this.onReorderEnd,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.alignment = WrapAlignment.start,
    this.isEditMode = false,
    this.wrapId, // Optional unique identifier
  });

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  // Generate a unique identifier for this wrap instance if none provided
  late final String _uniqueId;

  @override
  void initState() {
    super.initState();
    _uniqueId = widget.wrapId ?? 'wrap_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
  }

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
        final isIgnorePointer = child is IgnorePointer; // Check for spacer items
        
        // If it's trash can, add action, or spacer, don't make it draggable
        if (isTrashCan || isIgnorePointer) {
          return DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              final draggedData = details.data;
              // Only accept items from the same wrap instance
              if (draggedData['wrapId'] != _uniqueId) return false;
              
              final draggedIndex = draggedData['index'] as int;
              if (isTrashCan) {
                // Trash can accepts any dragged item from the same wrap (except itself)
                return draggedIndex != index;
              }
              return false; // Add action and spacers don't accept anything
            },
            onAcceptWithDetails: (details) {
              final draggedData = details.data;
              final draggedIndex = draggedData['index'] as int;
              if (isTrashCan && widget.onRemove != null) {
                // Remove the dragged item
                widget.onRemove!(draggedIndex);
              }
            },
            builder: (context, candidateData, rejectedData) {
              // Only highlight if the candidate is from the same wrap
              final hasValidCandidate = candidateData.any((data) => data != null && data['wrapId'] == _uniqueId);
              
              if (isTrashCan && hasValidCandidate) {
                // Preserve the original full-width SizedBox and only toggle the inner TrashCanItem highlight
                if (child is SizedBox) {
                  final sized = child;
                  final inner = sized.child;
                  final TrashCanItem originalTrash = inner is TrashCanItem ? inner : const TrashCanItem();
                  return SizedBox(
                    key: child.key,
                    width: sized.width,
                    height: sized.height,
                    child: TrashCanItem(
                      isHighlighted: true,
                      tileWidth: originalTrash.tileWidth,
                    ),
                  );
                }
                // Fallback: ask the TrashCanItem to render its highlighted state
                final TrashCanItem original = child is TrashCanItem ? child : const TrashCanItem();
                return TrashCanItem(
                  key: child.key,
                  isHighlighted: true,
                  tileWidth: original.tileWidth,
                );
              }
              return RepaintBoundary(child: child);
            },
          );
        }
        
        // Regular draggable items
        return LongPressDraggable<Map<String, dynamic>>(
          delay: const Duration(milliseconds: 400),
          data: {
            'index': index,
            'wrapId': _uniqueId, // Include wrap identifier in drag data
          },
          ignoringFeedbackSemantics: true,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.7,
              child: Transform.scale(
                scale: 1.1,
                child: RepaintBoundary(child: child),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: RepaintBoundary(child: child),
          ),
          onDragStarted: () {
            // Call onReorderStart callback when dragging begins
            widget.onReorderStart?.call();
          },
          onDragEnd: (_) {
            // Call onReorderEnd callback when dragging ends
            widget.onReorderEnd?.call();
          },
          child: DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              final draggedData = details.data;
              // Only accept items from the same wrap instance
              if (draggedData['wrapId'] != _uniqueId) return false;
              
              final draggedIndex = draggedData['index'] as int;
              // Regular items accept reordering (not from trash can)
              return draggedIndex != index;
            },
            onAcceptWithDetails: (details) {
              final draggedData = details.data;
              final draggedIndex = draggedData['index'] as int;
              // Reorder items
              widget.onReorder(draggedIndex, index);
            },
            builder: (context, candidateData, rejectedData) {
              // Only highlight if the candidate is from the same wrap
              final hasValidCandidate = candidateData.any((data) => data != null && data['wrapId'] == _uniqueId);
              
              if (hasValidCandidate) {
                // Highlight regular items when reordering without changing size
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: RepaintBoundary(child: child),
                );
              }
              return RepaintBoundary(child: child);
            },
          ),
        );
      }).toList(),
    );
  }
}
