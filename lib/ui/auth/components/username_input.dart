import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';  

/// Reusable username input field component with customizable label
class UsernameInput extends StatefulWidget {
  /// Text editing controller for the password field
  final TextEditingController controller;
  
  /// Label text to display for the field
  final String labelText;
  
  /// Optional validator function
  final String? Function(String?)? validator;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Optional prefix icon (defaults to person icon)
  final IconData? prefixIcon;

  const UsernameInput({
    super.key,
    required this.controller,
    this.labelText = 'Username',
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<UsernameInput> createState() => _UsernameInputState();
}

class _UsernameInputState extends State<UsernameInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(widget.prefixIcon ?? Symbols.person_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: widget.validator ?? _defaultValidator,
      enabled: widget.enabled,
    );
  }

  /// Default username validator
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${widget.labelText.toLowerCase()}';
    }
    return null;
  }
}
