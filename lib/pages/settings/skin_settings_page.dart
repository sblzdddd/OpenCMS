import 'package:flutter/material.dart';
import '../../data/models/skin/skin.dart';
import '../../services/skin/skin_service.dart';
import '../../ui/skin/skin_card.dart';
import '../../ui/skin/create_skin_dialog.dart';
import './skin_editor_page.dart';
import '../../ui/shared/widgets/custom_app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../ui/shared/custom_snackbar/snackbar_utils.dart';
import '../../ui/shared/widgets/custom_scaffold.dart';

/// Settings page for managing app skins
class SkinSettingsPage extends StatefulWidget {
  const SkinSettingsPage({super.key});

  @override
  State<SkinSettingsPage> createState() => _SkinSettingsPageState();
}

class _SkinSettingsPageState extends State<SkinSettingsPage> {
  final SkinService _skinService = SkinService.instance;
  List<Skin> _skins = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _skinService.initialize();
    _loadSkins();
  }

  Future<void> _loadSkins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _skinService.getAllSkins();
      if (response.success) {
        setState(() {
          _skins = response.skins ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load skins: $e';
        _isLoading = false;
      });
    }
  }

  /// Check if default skin is currently active
  bool _isDefaultSkinActive() {
    return !_skins.any((skin) => skin.isActive);
  }

  Future<void> _createSkin() async {
    final result = await showDialog<Skin>(
      context: context,
      builder: (context) => CreateSkinDialog(
        onSkinCreated: (skin) => Navigator.of(context).pop(skin),
      ),
    );

    if (result != null) {
      await _loadSkins();
      // Navigate to editor for the newly created skin
      if (mounted) {
        await _editSkin(result);
      }
    }
  }

  Future<void> _setActiveSkin(Skin skin) async {
    // If this skin is already active, do nothing
    if (skin.isActive) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _skinService.setActiveSkin(skin.id);
      if (response.success) {
        await _loadSkins();
        if (mounted) {
          SnackbarUtils.showSuccess(context, '${skin.name} is now active');
        }
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            response.error ?? 'Failed to activate skin',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setDefaultSkin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _skinService.clearActiveSkin();
      if (response.success) {
        await _loadSkins();
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Default skin is now active');
        }
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            response.error ?? 'Failed to activate default skin',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSkin(Skin skin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skin'),
        content: Text(
          'Are you sure you want to delete "${skin.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _skinService.deleteSkin(skin.id);
        if (response.success) {
          await _loadSkins();
          if (mounted) {
            SnackbarUtils.showSuccess(context, 'Skin deleted successfully');
          }
        } else {
          if (mounted) {
            SnackbarUtils.showError(
              context,
              response.error ?? 'Failed to delete skin',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Error: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _editSkin(Skin skin) async {
    final result = await Navigator.push<Skin>(
      context,
      MaterialPageRoute(builder: (context) => SkinEditorPage(skin: skin)),
    );

    if (result != null) {
      await _loadSkins();
    }
  }

  Widget _buildSkinCard(Skin skin) {
    return SkinCard(
      skin: skin,
      isSelected: skin.isActive,
      onTap: skin.isDefault ? () => _setDefaultSkin() : () => _setActiveSkin(skin),
      onEdit: skin.isDefault ? null : () => _editSkin(skin),
      onDelete: skin.isDefault ? null : () => _deleteSkin(skin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      skinKey: 'settings',
      appBar: CustomAppBar(
        title: const Text('Skins'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _createSkin,
            icon: const Icon(Symbols.add_rounded),
            tooltip: 'Create New Skin',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading skins',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSkins,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSkins,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _skins.length + 1, // +1 for default skin card
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Create default skin with proper active state
                    final defaultSkin = _skinService.createDefaultSkin();
                    final activeDefaultSkin = defaultSkin.copyWith(isActive: _isDefaultSkinActive());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildSkinCard(activeDefaultSkin),
                    );
                  }
                  final skin = _skins[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSkinCard(skin),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSkin,
        icon: const Icon(Symbols.add_rounded),
        label: const Text('Create Skin'),
      ),
    );
  }
}
