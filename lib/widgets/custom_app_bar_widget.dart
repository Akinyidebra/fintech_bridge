import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showHelp;
  final VoidCallback? onHelpPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showHelp = false,
    this.onHelpPressed,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> appBarActions = [];
    
    // Add help button if requested
    if (showHelp) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
          onPressed: onHelpPressed,
        ),
      );
    }
    
    // Add any additional actions
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          fontSize: 18,
        ),
      ),
      leading: leading ?? (automaticallyImplyLeading 
        ? IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null),
      actions: appBarActions.isNotEmpty ? appBarActions : null,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}