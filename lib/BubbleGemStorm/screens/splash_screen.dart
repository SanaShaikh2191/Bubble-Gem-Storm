import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '../widgets/text_gradient.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Scaffold(
      backgroundColor: Color(0xff070F2B),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Image.asset('assets/images/1SecLogo.png', height: 200),
              // SizedBox(height: 15),
              // // Icon(Icons.flash_on_rounded, color: Colors.amber, size: 98),
              // Text(
              //   'ONE',
              //   style: TextStyle(
              //     fontFamily: 'Righteous',
              //     fontSize: w * 0.18,
              //     height: 0.95,
              //     color: borderColor,
              //   ),
              // ),
              // Text(
              //   'SECOND',
              //   style: TextStyle(
              //     fontFamily: 'Righteous',
              //     fontSize: w * 0.18,
              //     height: 0.95,
              //     color: whiteColor,
              //   ),
              // ),
              // Text(
              //   'HERO',
              //   style: TextStyle(
              //     fontFamily: 'Righteous',
              //     fontSize: w * 0.18,
              //     height: 0.95,
              //     color: borderColor,
              //   ),
              // ),
              Image.asset('assets/images/gemLogo.png', height: 200),
              gradientText(
                [Color(0xffF7D4FA), Color(0xffDE01C1)],
                "Bubble  Gem ",
                fontsize: w * 0.17,
                height: 0.8,
                fontweight: FontWeight.bold,
              ),
              gradientText(
                [Color(0xffF7D4FA), Color(0xffDE01C1)],
                "Storm ",
                fontsize: w * 0.17,
                height: 1,
                fontweight: FontWeight.bold,
              ),
              SizedBox(height: h * 0.02),
              Text(
                "Tap fast,Survive,Dominate!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                  color: whitecolor.withValues(alpha: 0.7),
                  fontFamily: 'Baloo2',
                ),
              ),
              // SizedBox(height: 30),
              // Text(
              //   "Test your speed and reflexes",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: w * 0.05,
              //     fontWeight: FontWeight.bold,
              //     color: whiteColor.withValues(alpha: 0.7),
              //     fontFamily: 'Baloo2',
              //   ),
              // ),
              SizedBox(height: 30),
              // CircularProgressIndicator(color: Colors.white),
              DotLoader(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class DotLoader extends StatefulWidget {
  final List<Color> color;
  final double size;

  const DotLoader({
    super.key,
    this.color = const [
      // borderColor,
      // dialogColor, borderColor,
      Color(0xffF7D4FA),
      Color(0xffDE01C1),
      Color(0xffF7D4FA),
    ],
    this.size = 10,
  });

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final value = (_controller.value + index * 0.2) % 1;
        return Opacity(
          opacity: value < 0.5 ? value * 2 : (1 - value) * 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color[index % widget.color.length],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_dot(0), _dot(1), _dot(2)],
    );
  }
}
