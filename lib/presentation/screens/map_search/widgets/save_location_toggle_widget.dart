import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_search_places/theme/app_colors.dart';

class SaveLocationToggleWidget extends StatefulWidget {
  final bool value;
  final void Function(bool value) onTap;

  const SaveLocationToggleWidget({
    super.key,
    required this.value,
    required this.onTap,
  });

  @override
  State<SaveLocationToggleWidget> createState() =>
      _SaveLocationToggleWidgetState();
}

class _SaveLocationToggleWidgetState extends State<SaveLocationToggleWidget> {
  @override
  Widget build(BuildContext context) {
    const double scaleFactor = 0.8;

    return SizedBox(
      height: 24,
      width: 70,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.scale(
          scale: scaleFactor,
          alignment: Alignment.centerLeft,
          child: Platform.isIOS
              ? CupertinoSwitch(
                  activeColor: AppColors.primary,
                  value: widget.value,
                  onChanged: widget.onTap,
                  trackOutlineWidth: const WidgetStatePropertyAll(0),
                  inactiveThumbColor: AppColors.background,
                  inactiveTrackColor: AppColors.color999999,
                  thumbIcon: const WidgetStatePropertyAll(
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                )
              : Switch(
                  activeTrackColor: AppColors.primary,
                  activeColor: AppColors.background,
                  inactiveThumbColor: AppColors.background,
                  value: widget.value,
                  onChanged: widget.onTap,
                  trackOutlineWidth: const WidgetStatePropertyAll(0),
                  inactiveTrackColor: AppColors.color999999,
                  padding: EdgeInsets.zero,
                  thumbIcon: const WidgetStatePropertyAll(
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
