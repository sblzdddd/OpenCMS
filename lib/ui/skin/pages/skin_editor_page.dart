import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/models/skin/skin.dart';
import '../../../data/models/skin/skin_image_type.dart';
import '../../../services/skin/skin_service.dart';
import '../widgets/base_image_customizer.dart';
import '../../../services/skin/skin_categories_helper.dart';
import '../widgets/editor_skin_info_card.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/custom_snackbar/snackbar_utils.dart';
import '../../shared/widgets/custom_scaffold.dart';
import '../../shared/widgets/custom_scroll_view.dart';
import '../../shared/error/error_placeholder.dart';

/// Dedicated page for editing skin configurations
class SkinEditorPage extends StatefulWidget {
  final Skin skin;

  const SkinEditorPage({super.key, required this.skin});

  @override
  State<SkinEditorPage> createState() => _SkinEditorPageState();
}

class _SkinEditorPageState extends State<SkinEditorPage>
    with SingleTickerProviderStateMixin {
  final SkinService _skinService = SkinService.instance;
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
    _tabController = TabController(length: _categories.length + 1, vsync: this);
    _loadLatestSkin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload skin when page becomes visible
    _loadLatestSkin();
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

  Future<void> _loadLatestSkin() async {
    try {
      final response = await _skinService.getSkinById(_currentSkin.id);
      if (response.success && response.skin != null && mounted) {
        setState(() {
          _currentSkin = response.skin!;
        });
      }
    } catch (_) {
      // ignore and keep current
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      skinKey: 'settings',
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
          labelStyle: Theme.of(context).textTheme.labelLarge,
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Info'),
            ..._categories.map((category) => Tab(text: category)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLatestSkin,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: _error != null
              ? ListView(
                  children: [
                    ErrorPlaceholder(
                      title: 'Error loading skin',
                      errorMessage: _error!,
                      onRetry: () => _loadLatestSkin(),
                    ),
                  ],
                )
              : TabBarView(
                  key: ValueKey(
                    'tabbarview_${_currentSkin.updatedAt.millisecondsSinceEpoch}',
                  ),
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    ..._categories.map(
                      (category) => _buildCategoryTab(category),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return CustomChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkinInfoCard(
            skin: _currentSkin,
            onSkinUpdated: (updatedSkin) async {
              await _updateSkin(updatedSkin);
            },
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
                  _buildStatRow(
                    'Total Elements',
                    '${_currentSkin.imageData.length}',
                  ),
                  _buildStatRow('Customized', '${_getCustomizedCount()}'),
                  _buildStatRow(
                    'Themed %',
                    '${(_getCustomizedCount() / _currentSkin.imageData.length * 100).toStringAsFixed(2)}%',
                  ),
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$category customization coming soon...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: keys.map((key) {
              return BaseImageCustomizer(
                key: ValueKey(
                  '${_currentSkin.id}_${key}_${_currentSkin.updatedAt.millisecondsSinceEpoch}',
                ),
                skin: _currentSkin,
                imageKey: key,
                title: key.split('.').last,
                icon: _getIconForImageType(
                  SkinCategoriesHelper.getImageTypeForKey(key),
                ),
                onSkinUpdated: (updatedSkin) {
                  setState(() {
                    _currentSkin = updatedSkin;
                  });
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
}
