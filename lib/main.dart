import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/starpath_shell.dart';
import 'core/starpath_style.dart';

void main() {
  runApp(const StarPathApp());
}

class StarPathApp extends StatelessWidget {
  const StarPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StarPath',
      theme: StarPathStyle.theme(),
      builder: (context, child) {
        final ThemeData theme = Theme.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: StarPathStyle.backgroundDeep,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Theme(
            data: theme.copyWith(
              splashFactory: InkSparkle.splashFactory,
              highlightColor: StarPathStyle.accent.withValues(alpha: 0.08),
              hoverColor: StarPathStyle.accent.withValues(alpha: 0.04),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const StarPathShell(),
    );
  }
}
