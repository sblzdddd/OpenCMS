import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../models/skin.dart';
import '../../../../shared/views/custom_snackbar/snackbar_utils.dart';
// import 'package:share_plus/share_plus.dart';
import '../../../services/skin_service.dart';
import 'package:file_picker/file_picker.dart';

/// A card widget for displaying and editing skin information
class SkinInfoCard extends StatefulWidget {
  final Skin skin;
  final Function(Skin) onSkinUpdated;
  final bool isReadOnly;

  const SkinInfoCard({
    super.key,
    required this.skin,
    required this.onSkinUpdated,
    this.isReadOnly = false,
  });

  @override
  State<SkinInfoCard> createState() => _SkinInfoCardState();
}

class _SkinInfoCardState extends State<SkinInfoCard> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _versionController;
  bool _isEditing = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(SkinInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skin != widget.skin) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.skin.name);
    _descriptionController = TextEditingController(
      text: widget.skin.description,
    );
    _versionController = TextEditingController(text: widget.skin.version);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to current skin values when canceling edit
        _nameController.text = widget.skin.name;
        _descriptionController.text = widget.skin.description;
        _versionController.text = widget.skin.version;
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, 'Skin name cannot be empty');
      return;
    }

    final updatedSkin = widget.skin.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      version: _versionController.text.trim(),
      updatedAt: DateTime.now(),
    );

    widget.onSkinUpdated(updatedSkin);

    if (mounted) {
      setState(() {
        _isEditing = false;
      });
      SnackbarUtils.showSuccess(
        context,
        'Skin information updated successfully',
      );
    }
  }

  Future<void> _exportAndShare() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
    });
    try {
      /* final path = */ await SkinService.instance.exportSkinToCmsk(widget.skin.id);

      // Use Share.shareXFiles for mobile and web platforms
      // await SharePlus.instance.share(
      //   ShareParams(
      //     files: [XFile(path, name: '${widget.skin.name}.cmsk')],
      //     text: '"${widget.skin.name}" OpenCMS skin',
      //   ),
      // );
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportAndSave() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
    });
    try {
      final path = await SkinService.instance.exportSkinToCmsk(widget.skin.id);
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save skin package',
        fileName: '${widget.skin.name}.cmsk',
        type: FileType.custom,
        allowedExtensions: ['cmsk'],
      );

      if (outputPath == null) {
        throw 'File save cancelled';
      }
      // Copy the exported file to the selected location
      await File(path).copy(outputPath);
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Skin package saved successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Skin Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!widget.isReadOnly && !_isEditing)
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isExporting ? null : _exportAndSave,
                        icon: _isExporting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Symbols.save_rounded),
                        tooltip: 'Export and Save',
                      ),
                      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                        IconButton(
                          onPressed: _isExporting ? null : _exportAndShare,
                          icon: _isExporting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Symbols.share_rounded),
                          tooltip: 'Export and Share',
                        ),
                      IconButton(
                        onPressed: _toggleEdit,
                        icon: const Icon(Symbols.edit_rounded),
                        tooltip: 'Edit Information',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              _buildEditableInfo(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _toggleEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ] else ...[
              _buildReadOnlyInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Skin Name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _versionController,
          decoration: const InputDecoration(
            labelText: 'Version',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (widget.skin.author.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Author: ${widget.skin.author}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Updated: ${widget.skin.updatedAt.toLocal().toString()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.skin.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.skin.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (widget.skin.author.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'by ${widget.skin.author}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.skin.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Updated: ${widget.skin.updatedAt.toLocal().toString()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        if (widget.skin.version.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Version: ${widget.skin.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}
