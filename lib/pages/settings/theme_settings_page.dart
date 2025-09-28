import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../services/theme/theme_services.dart';
import '../../ui/shared/widgets/custom_app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:io';
import '../../services/theme/window_effect_service.dart';
import '../../ui/shared/widgets/custom_scaffold.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late TextEditingController _hexController;
  final bool _enableAlpha = false;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _showColorPicker(BuildContext context, ThemeNotifier themeNotifier) {
    Color currentColor = themeNotifier.customColor;
    _hexController.text = '#${currentColor.toHex().substring(1).toUpperCase()}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        title: const Text('Pick a custom color'),
        content: CustomChildScrollView(
          child: Column(
            children: [
              ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (Color color) {
                  currentColor = color;
                  _hexController.text = '#${color.toHex().substring(1).toUpperCase()}';
                },
                colorPickerWidth: 300,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: _enableAlpha,
                displayThumbColor: true,
                paletteType: PaletteType.hsvWithHue,
                labelTypes: const [],
                pickerAreaBorderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
                hexInputController: _hexController,
                portraitOnly: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _hexController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Symbols.tag_rounded),
                    labelText: 'Hex Color',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 9,
                  onChanged: (value) {
                    if (value.startsWith('#') && value.length == 7) {
                      try {
                        currentColor = Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
                      } catch (e) {
                        // Invalid hex color
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              themeNotifier.setCustomColor(currentColor);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }


  Widget _buildColorButton(ThemeColor color, String label, Color colorValue, ThemeNotifier themeNotifier) {
    bool isSelected = themeNotifier.selectedColor == color;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () => themeNotifier.setColorTheme(color),
          borderRadius: themeNotifier.getBorderRadiusAll(0.75),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorValue,
              borderRadius: themeNotifier.getBorderRadiusAll(0.75),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorValue.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      skinKey: 'settings',
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Theme Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return CustomChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Color',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Predefined color buttons
                Row(
                  children: [
                    _buildColorButton(
                      ThemeColor.red,
                      'Fire',
                      ThemeNotifier.predefinedColors[ThemeColor.red]!,
                      themeNotifier,
                    ),
                    _buildColorButton(
                      ThemeColor.golden,
                      'Metal',
                      ThemeNotifier.predefinedColors[ThemeColor.golden]!,
                      themeNotifier,
                    ),
                    _buildColorButton(
                      ThemeColor.blue,
                      'Water',
                      ThemeNotifier.predefinedColors[ThemeColor.blue]!,
                      themeNotifier,
                    ),
                    _buildColorButton(
                      ThemeColor.green,
                      'Wood',
                      ThemeNotifier.predefinedColors[ThemeColor.green]!,
                      themeNotifier,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Custom color button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showColorPicker(context, themeNotifier),
                    icon: const Icon(Symbols.palette_rounded),
                    label: const Text('Custom Color'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeNotifier.selectedColor == ThemeColor.custom
                          ? themeNotifier.customColor
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Border Radius
                Text(
                  'Border Radius',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Border Radius Slider
                Slider(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  value: themeNotifier.borderRadius,
                  min: 0,
                  max: 32,
                  divisions: 32,
                  onChanged: (value) => themeNotifier.setBorderRadius(value),
                ),

                // Only show window effects on desktop platforms
                if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ...[
                  const SizedBox(height: 32),
                  
                  Text(
                    'Window Effect',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Window Effect Dropdown
                  DropdownButtonFormField<WindowEffectType>(
                    value: themeNotifier.windowEffect,
                    decoration: InputDecoration(
                      labelText: 'Window Effect',
                      border: OutlineInputBorder(
                        borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                      ),
                      prefixIcon: const Icon(Symbols.window_rounded),
                    ),
                    items: ThemeNotifier.availableWindowEffects.map((effect) {
                      return DropdownMenuItem(
                        value: effect,
                        child: Text(ThemeNotifier.getWindowEffectDisplayName(effect)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setWindowEffect(value);
                      }
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
