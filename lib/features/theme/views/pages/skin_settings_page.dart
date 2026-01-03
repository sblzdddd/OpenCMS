import 'package:flutter/material.dart';
import 'package:opencms/di/locator.dart';
import '../../models/skin.dart';
import '../../services/skin_service.dart';
import '../widgets/editor/skin_card.dart';
import '../dialogs/create_skin_dialog.dart';
import 'skin_editor_page.dart';
import '../../../shared/views/widgets/custom_app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../shared/views/custom_snackbar/snackbar_utils.dart';
import '../../../shared/views/widgets/custom_scaffold.dart';
import '../../../../main.dart';
import '../../../shared/views/error/error_placeholder.dart';
import 'package:flutter/gestures.dart';
import 'package:file_picker/file_picker.dart';

/// Settings page for managing app skins
class SkinSettingsPage extends StatefulWidget {
  const SkinSettingsPage({super.key});

  @override
  State<SkinSettingsPage> createState() => _SkinSettingsPageState();
}

class _SkinSettingsPageState extends State<SkinSettingsPage> with RouteAware {
  List<Skin> _skins = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    di<SkinService>().initialize();
    _loadSkins();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _loadSkins();
  }

  @override
  void didPopNext() {
    _loadSkins();
  }

  Future<void> _loadSkins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await di<SkinService>().getAllSkins();
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
      builder: (context) => CreateSkinDialog(),
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
      final response = await di<SkinService>().setActiveSkin(skin.id);
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
      final response = await di<SkinService>().clearActiveSkin();
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
        final response = await di<SkinService>().deleteSkin(skin.id);
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
    await Navigator.push<Skin>(
      context,
      MaterialPageRoute(builder: (context) => SkinEditorPage(skin: skin)),
    );
    if (!mounted) return;
    await _loadSkins();
  }

  Future<void> _importSkin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['cmsk'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final response = await di<SkinService>().importSkinFromCmsk(file.path!);
          if (response.success && mounted) {
            await _loadSkins();
            if (!mounted) return;
            SnackbarUtils.showSuccess(
              context,
              response.message ?? 'Skin imported successfully',
            );
          } else if (!response.success && mounted) {
            SnackbarUtils.showError(
              context,
              response.error ?? 'Failed to import skin',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Import failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSkinCard(Skin skin) {
    return SkinCard(
      skin: skin,
      isSelected: skin.isActive,
      onTap: skin.isDefault
          ? () => _setDefaultSkin()
          : () => _setActiveSkin(skin),
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
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                ErrorPlaceholder(
                  title: 'Error loading skins',
                  errorMessage: _error!,
                  onRetry: () => _loadSkins(),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadSkins,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _skins.length + 1, // +1 for default skin card
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Create default skin with proper active state
                      final defaultSkin = di<SkinService>().createDefaultSkin();
                      final activeDefaultSkin = defaultSkin.copyWith(
                        isActive: _isDefaultSkinActive(),
                      );
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
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'import_skin',
              onPressed: _importSkin,
              icon: const Icon(Symbols.file_upload_rounded),
              label: const Text('Import Skin'),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'create_skin',
              onPressed: _createSkin,
              icon: const Icon(Symbols.add_rounded),
              label: const Text('Create Skin'),
            ),
          ],
        ),
      ),
    );
  }
}
