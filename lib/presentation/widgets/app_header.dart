import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.showBack = false, this.showProfile = false});

  final bool showBack;
  final bool showProfile;

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.adaptiveBlack(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: showBack
                ? IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: iconColor),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              'ShelfSight',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: showProfile
                ? IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: Icon(Icons.account_circle_outlined, color: iconColor),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
