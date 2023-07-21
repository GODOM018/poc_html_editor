import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:hyperion_components/hyperion_components.dart';

class AppTheme {
  static md.MarkdownStyleSheet getMarkdownStyleSheet(BuildContext context) =>
      md.MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        a: const TextStyle(
          color: HyperionColor.blue700,
          fontWeight: FontWeight.bold,
        ),
        blockquote: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: HyperionColor.grey800,
              fontStyle: FontStyle.italic,
            ),
        blockquotePadding: EdgeInsets.zero,
        blockSpacing: 0,
        h1: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
        h1Padding: const EdgeInsets.symmetric(
          vertical: HyperionPadding.xlarge,
        ),
        h2: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
        h2Padding: const EdgeInsets.symmetric(
          vertical: HyperionPadding.large,
        ),
        h3: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
        h3Padding: const EdgeInsets.symmetric(
          vertical: HyperionPadding.medium,
        ),
        h4: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
        h4Padding: const EdgeInsets.symmetric(
          vertical: HyperionPadding.medium,
        ),
        h5: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
        h5Padding: const EdgeInsets.symmetric(
          vertical: HyperionPadding.small,
        ),
        h6: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
        h6Padding: const EdgeInsets.symmetric(
          vertical: HyperionPadding.small,
        ),
        p: Theme.of(context).textTheme.bodyMedium,
        pPadding: EdgeInsets.zero,
      );

  static final ThemeData theme = ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      textTheme: TextTheme());
}
