import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_dimensions.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.safeBottom = true,
    this.bottomNavigationBar,
  });

  final Widget child;
  final bool safeBottom;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        bottom: safeBottom,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.pageMaxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
