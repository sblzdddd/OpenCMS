import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';

/// Reusable password input field component with customizable label
class PasswordInput extends StatefulWidget {
  /// Text editing controller for the password field
  final TextEditingController controller;

  /// Label text to display for the field
  final String labelText;

  /// Optional validator function
  final String? Function(String?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Optional prefix icon (defaults to lock icon)
  final IconData? prefixIcon;

  const PasswordInput({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  /// Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(widget.prefixIcon ?? Symbols.lock_rounded),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(
              _obscureText
                  ? Symbols.visibility_rounded
                  : Symbols.visibility_off_rounded,
            ),
            onPressed: _togglePasswordVisibility,
            tooltip: _obscureText ? 'Show password' : 'Hide password',
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(0.75),
        ),
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }

  /// Default password validator
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${widget.labelText.toLowerCase()}';
    }
    if (value.length < 6) {
      return '${widget.labelText} must be at least 6 characters';
    }
    return null;
  }
}
