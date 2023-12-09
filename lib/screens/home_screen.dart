// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metxtract/screens/home_screen_components/docs_tab.dart';
import 'package:metxtract/screens/home_screen_components/home_tab.dart';
import 'package:metxtract/screens/home_screen_components/notifications_tab.dart';
import 'package:metxtract/screens/home_screen_components/profile_tab.dart';
import 'package:metxtract/screens/signin_screen.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:metxtract/utils/loading_dialog.dart';
import 'package:metxtract/utils/responsize_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0; // Default index of the first screen

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

  final iconList = <IconData>[
    Icons.home,
    Icons.document_scanner,
    Icons.notifications,
    Icons.person,
  ];

  List<Widget> screens = [
    const HomeTab(),
    const DocsTab(),
    const NotificationsTab(),
    const ProfileTab(),
  ];

  signOut() async {
    LoadingDialog.showLoadingDialog(context, "Signing out");
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignIn(),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error $e");
    }
  }

  signOutConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: const BoxDecoration(
              color: ColorUtils.darkPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  top: ResponsiveUtil.heightVar / 70,
                  bottom: ResponsiveUtil.heightVar / 70),
              child: const Center(
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          content: const Text(
            "Are you sure you want to sign out?",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: ColorUtils.darkPurple),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorUtils.darkPurple),
                    ),
                    onPressed: () {
                      signOut();
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorUtils.darkPurple,
        title: const Text(
          "METXTRACT",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Image.asset(
          "assets/images/4.png",
          height: 2,
          width: 2,
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(right: ResponsiveUtil.widthVar / 35),
              child: IconButton(
                onPressed: () {
                  signOutConfirmation();
                },
                icon: const Icon(
                  Icons.logout,
                  color: ColorUtils.background,
                ),
              ))
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_bottomNavIndex], // Display the current tab's content
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? ColorUtils.darkPurple : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 30,
                color: color,
              ),
            ],
          );
        },
        backgroundColor: ColorUtils.background,
        activeIndex: _bottomNavIndex,
        splashColor: ColorUtils.darkPurple,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.none,
        leftCornerRadius: 10,
        rightCornerRadius: 10,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        hideAnimationController: _hideBottomBarAnimationController,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  final IconData iconData;
  final Widget screen;

  const NavigationScreen(this.iconData, this.screen, {Key? key})
      : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void didUpdateWidget(NavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData) {
      _startAnimation();
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    super.initState();
  }

  _startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          const SizedBox(height: 64),
          Center(
            child: CircularRevealAnimation(
              animation: animation,
              centerOffset: const Offset(80, 80),
              maxRadius: MediaQuery.of(context).size.longestSide * 1.1,
              child: Icon(
                widget.iconData,
                color: ColorUtils.lightPurple,
                size: 160,
              ),
            ),
          ),
          // Display the current tab's content
          widget.screen,
        ],
      ),
    );
  }
}
