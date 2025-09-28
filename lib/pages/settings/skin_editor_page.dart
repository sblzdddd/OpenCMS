import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/models/skin/skin.dart';
import '../../data/models/skin/skin_image_type.dart';
import '../../services/skin/skin_service.dart';
import '../../ui/skin/base_image_customizer.dart';
import '../../ui/skin/skin_categories_helper.dart';
import '../../ui/shared/widgets/custom_app_bar.dart';
import '../../ui/shared/custom_snackbar/snackbar_utils.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';

/// Dedicated page for editing skin configurations
class SkinEditorPage extends StatefulWidget {
  final Skin skin;

  const SkinEditorPage({
    super.key,
    required this.skin,
  });

  @override
  State<SkinEditorPage> createState() => _SkinEditorPageState();
}

class _SkinEditorPageState extends State<SkinEditorPage> with SingleTickerProviderStateMixin {
  final SkinService _skinService = SkinService();
  late Skin _currentSkin;
  bool _isLoading = false;
  String? _error;
  late TabController _tabController;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _currentSkin = widget.skin;
    _categories = SkinCategoriesHelper.getCategories();
    _skinService.initialize();
    _tabController = TabController(length: _categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateSkin(Skin updatedSkin) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _skinService.updateSkin(updatedSkin);
      if (response.success) {
        setState(() {
          _currentSkin = updatedSkin;
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
        _error = 'Failed to update skin: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSkin() async {
    await _updateSkin(_currentSkin);
    if (mounted && _error == null) {
      SnackbarUtils.showSuccess(context, 'Skin saved successfully');
    } else if (mounted && _error != null) {
      SnackbarUtils.showError(context, _error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Edit skin "${_currentSkin.name}"'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _saveSkin,
              icon: const Icon(Symbols.save_rounded),
              tooltip: 'Save Changes',
            ),
        ],
        bottom: TabBar(
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          ),
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Info'),
            ..._categories.map(
              (category) => Tab(
                text: category,
              ),
            ),
          ],
        ),
      ),
      body: _error != null
          ? _buildErrorState()
          : TabBarView(
              key: ValueKey('tabbarview_${_currentSkin.updatedAt.millisecondsSinceEpoch}'),
              controller: _tabController,
              children: [
                _buildInfoTab(),
                ..._categories.map(
                  (category) => _buildCategoryTab(category),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'Error loading skin',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
                _currentSkin = widget.skin;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return CustomChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skin Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentSkin.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentSkin.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            if (_currentSkin.author.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'by ${_currentSkin.author}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_currentSkin.isActive)
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
                    'Updated: ${_formatDate(_currentSkin.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (_currentSkin.version.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Version: ${_currentSkin.version}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customization Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Total Elements', '${_currentSkin.imageData.length}'),
                  _buildStatRow('Customized', '${_getCustomizedCount()}'),
                  _buildStatRow('Categories', '${_categories.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  int _getCustomizedCount() {
    return _currentSkin.imageData.values
        .where((imageData) => imageData.hasImage)
        .length;
  }

  Widget _buildCategoryTab(String category) {
    final keys = SkinCategoriesHelper.getKeysForCategory(category);
    
    if (keys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.image_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$category customization coming soon...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return CustomChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: keys.map((key) {
              return BaseImageCustomizer(
                key: ValueKey('${_currentSkin.id}_${key}_${_currentSkin.updatedAt.millisecondsSinceEpoch}'),
                skin: _currentSkin,
                imageKey: key,
                title: key.split('.').last,
                icon: _getIconForImageType(SkinCategoriesHelper.getImageTypeForKey(key)),
                onSkinUpdated: (updatedSkin) {
                  setState(() {
                    _currentSkin = updatedSkin;
                  });
                  // Auto-save when image is updated
                  _updateSkin(updatedSkin);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getIconForImageType(SkinImageType type) {
    switch (type) {
      case SkinImageType.background:
        return Symbols.photo_library_rounded;
      case SkinImageType.foreground:
        return Symbols.layers_rounded;
      case SkinImageType.icon:
        return Symbols.image_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
