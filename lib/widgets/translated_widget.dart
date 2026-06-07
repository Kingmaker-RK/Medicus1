import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/localization_service.dart';

/// Widget that rebuilds when language changes, translating all text
class LanguageBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, String languageCode) builder;

  const LanguageBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<UserProvider>().selectedLanguage;
    return builder(context, languageCode);
  }
}

/// Text widget that translates automatically when language changes
class AutoTranslateText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const AutoTranslateText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch for language changes - this triggers rebuild
    final languageCode = context.watch<UserProvider>().selectedLanguage;

    // FutureBuilder with key that changes when language changes
    // This forces a new future to be created and executed
    return FutureBuilder<String>(
      key: ValueKey('${text}_$languageCode'), // Force rebuild on language change
      future: LocalizationService().translate(text),
      initialData: text,
      builder: (context, snapshot) {
        // Show loading indicator briefly while translating (only for non-English)
        if (snapshot.connectionState == ConnectionState.waiting &&
            languageCode != 'en') {
          return Text(
            text, // Show original text while loading
            style: style?.copyWith(color: style?.color?.withValues(alpha: 0.7)),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
          );
        }

        return Text(
          snapshot.data ?? text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
        );
      },
    );
  }
}

/// TextField label that translates automatically
class TranslatedInputDecoration extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String Function(BuildContext, String)? validator;
  final void Function(String)? onChanged;

  const TranslatedInputDecoration({
    Key? key,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch for language changes
    context.watch<UserProvider>().selectedLanguage;

    return FutureBuilder<String>(
      future: LocalizationService().translate(labelText),
      initialData: labelText,
      builder: (context, labelSnapshot) {
        return FutureBuilder<String>(
          future: hintText != null
              ? LocalizationService().translate(hintText!)
              : Future.value(''),
          initialData: hintText ?? '',
          builder: (context, hintSnapshot) {
            return TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: labelSnapshot.data ?? labelText,
                hintText: hintSnapshot.data?.isNotEmpty == true
                    ? hintSnapshot.data
                    : null,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
