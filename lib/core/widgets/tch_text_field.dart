import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Champ : hauteur 56, rayon 16, bordure 1,5 px ; focus = bordure verte + halo.
class TchTextField extends StatefulWidget {
  const TchTextField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.semanticLabel,
    this.height = 56,
    this.hint,
    this.fontSize = 16,
    this.horizontalPadding = 16,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;
  final double height;
  final String? hint;
  final double fontSize;
  final double horizontalPadding;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TchTextField> createState() => _TchTextFieldState();
}

class _TchTextFieldState extends State<TchTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: Tch.selectDuration,
    height: widget.height,
    padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Tch.surface,
      borderRadius: BorderRadius.circular(Tch.fieldRadius),
      border: Border.all(color: _focused ? Tch.green : Tch.border, width: 1.5),
      boxShadow: _focused
          ? const [BoxShadow(color: Color(0x264F7A5A), spreadRadius: 4)]
          : null,
    ),
    child: Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        cursorColor: Tch.green,
        style: Tch.style(widget.fontSize),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: widget.hint,
          hintStyle: Tch.style(widget.fontSize, color: Tch.textSecondary),
        ),
      ),
    ),
  );
}
