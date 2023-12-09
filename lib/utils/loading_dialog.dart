import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:metxtract/utils/responsize_utils.dart';

import 'color_utils.dart';

class LoadingDialog {
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.discreteCircle(
                color: ColorUtils.darkPurple,
                size: 60,
              ),
              SizedBox(
                height: ResponsiveUtil.heightVar / 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        '.....',
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 500),
                      ),
                    ],
                    totalRepeatCount: 10,
                    pause: const Duration(milliseconds: 1000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
