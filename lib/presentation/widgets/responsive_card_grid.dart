import 'package:flutter/material.dart';

class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.minTileWidth = 170,
    this.childAspectRatio = 1.18,
  });

  final List<Widget> children;
  final double spacing;
  final double minTileWidth;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columns = (width / minTileWidth).floor().clamp(1, 2).toInt();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: columns == 1 ? 2.4 : childAspectRatio,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
