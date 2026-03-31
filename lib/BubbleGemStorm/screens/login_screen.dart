import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';

import '../utils/google_auth.dart';
import '../widgets/text_gradient.dart';
import '../utils/animated_tap_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Scaffold(
      backgroundColor: Color(0xff070F2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(),
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
              //   "Test your reflexes,Beat the clock.!",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: w * 0.05,
              //     fontWeight: FontWeight.bold,
              //     color: whiteColor.withValues(alpha: 0.7),
              //     fontFamily: 'Baloo2',
              //   ),
              // ),
              const SizedBox(height: 32),
              // Google Sign In Button
              _GoogleSignInButton(
                onTap: () async {
                  // TODO: Implement Google Sign-In
                  final user = await GoogleAuthService.instance
                      .signInWithGoogle();
                  if (user != null && context.mounted) {
                    print('Sign in as :${user.email}');
                    context.go('/bubble-gem-home');
                    // Navigator.pushReplacementNamed(context, '/home');
                  }
                  debugPrint('Google Sign-In tapped');
                },
              ),

              const SizedBox(height: 16),

              // Guest Button
              // _GuestButton(
              //   onTap: () {
              //     context.go('/home');
              //     // Navigator.pushReplacementNamed(context, '/home');
              //   },
              // ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedTapButton(
      onTap: onTap,
      // borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google.png', height: 24),
            const SizedBox(width: 12),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _GuestButton extends StatelessWidget {
//   final VoidCallback onTap;
//
//   const _GuestButton({required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedTapButton(
//       onTap: onTap,
//       // borderRadius: BorderRadius.circular(12),
//       child: Container(
//         height: 54,
//         decoration: BoxDecoration(
//           // boxShadow: [
//           //   // BoxShadow(
//           //   //   offset: Offset(0, 0),
//           //   //   blurRadius: 5,
//           //   //   spreadRadius: -5,
//           //   //   // color: buttonC1.withOpacity(0.3),
//           //   // ),
//           // ],
//           gradient: LinearGradient(
//             colors: [aB1.withOpacity(0.2), buttonC3.withOpacity(0.2)],
//           ),
//           borderRadius: BorderRadius.circular(40),
//           border: Border.all(color: whiteColor.withOpacity(0.3)),
//         ),
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.login, size: 23.99, color: buttonC1),
//             const SizedBox(width: 12),
//             const Text(
//               'Continue as Guest',
//               style: TextStyle(
//                 color: buttonC1,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
