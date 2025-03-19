import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  final bool isFullScreen;

  const LoadingScreen({
    super.key,
    this.message = 'Processing your request...',
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget loadingContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom SpinKit animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.primaryLightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SpinKitDoubleBounce(
                color: AppConstants.primaryColor,
                size: 70.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait...',
            style: AppConstants.bodySmallSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (isFullScreen) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: loadingContent,
        ),
      );
    } else {
      return Center(
        child: loadingContent,
      );
    }
  }
}

// Use this class to show the loading overlay
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) {
      hide();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingScreen(
        message: message ?? 'Processing your request...',
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
