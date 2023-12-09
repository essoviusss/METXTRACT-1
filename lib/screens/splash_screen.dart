import 'package:easy_splash_screen/easy_splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:metxtract/screens/signin_screen.dart';
import 'package:metxtract/utils/responsize_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset(
        "assets/images/2.png",
        width: ResponsiveUtil.widthVar / 1.5,
        fit: BoxFit.fitHeight,
      ),
      backgroundColor: Colors.grey.shade400,
      showLoader: true,
      loadingText: const Text("Loading..."),
      navigator: const SignIn(),
      durationInSeconds: 5,
    );
  }
}
