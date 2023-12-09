// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metxtract/screens/home_screen.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:metxtract/utils/responsize_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/loading_dialog.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //auth
  String email = "";
  String password = "";

  bool isVisible = true;

  signIn() async {
    LoadingDialog.showLoadingDialog(context, 'Signing in');

    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pop(context); // Close the loading dialog.

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Fluttertoast.showToast(msg: "Error");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading dialog.
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.gray1,
      body: Container(
        margin: EdgeInsets.only(
          left: ResponsiveUtil.widthVar / 25,
          right: ResponsiveUtil.widthVar / 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/2.png",
              width: ResponsiveUtil.widthVar / 1.5,
              fit: BoxFit.fitHeight,
            ),
            SizedBox(
              height: ResponsiveUtil.heightVar / 20,
            ),
            TextField(
              onChanged: (value) {
                email = value;
              },
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Email',
                hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                contentPadding: EdgeInsets.all(15),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(
              height: ResponsiveUtil.heightVar / 80,
            ),
            TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: isVisible,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    if (isVisible == false) {
                      setState(() {
                        isVisible = true;
                      });
                    } else if (isVisible == true) {
                      setState(
                        () {
                          isVisible = false;
                        },
                      );
                    }
                  },
                  icon: isVisible == true
                      ? const Icon(Icons.remove_red_eye_outlined)
                      : const Icon(Icons.remove_red_eye_rounded),
                ),
                prefixIcon: const Icon(Icons.lock),
                hintText: 'Password',
                hintStyle: const TextStyle(fontSize: 15.0, color: Colors.grey),
                contentPadding: const EdgeInsets.all(15),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(
              height: ResponsiveUtil.heightVar / 80,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(ColorUtils.gray2),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    onPressed: () {
                      signIn();
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
