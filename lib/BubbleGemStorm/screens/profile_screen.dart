import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/haptic_manager.dart';
import '../utils/sound_manager.dart';
import '../utils/sounds_settings.dart';
import '../widgets/text_gradient.dart';
import 'game_screen.dart';
import '../utils/google_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool sound = true;
  bool notifications = true;
  bool vibration = true;

  Future<void> loadHapticSettings() async {
    vibration = await HapticSettings.isEnabled();
    setState(() {});
  }

  Future<void> loadSoundSettings() async {
    sound = await SoundSettings.isEnabled();
    SoundManager.instance.playHomeTheme();
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => LogoutConfirmDialog(
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (confirm == true) {
      await GoogleAuthService.instance.signOut();
      if (!mounted) return;
      context.go('/login');
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      print('Logout from your account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _backButton(),

                  // gradientText(
                  //   [title1, title2],
                  //   'Profile',
                  //   fontsize: 50,
                  //   letterSpacing: 1,
                  //   fontweight: FontWeight.w900,
                  // ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: whitecolor.withOpacity(0.05),
                      boxShadow: [
                        BoxShadow(
                          color: whitecolor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                      // gradient: LinearGradient(
                      //   colors: [
                      //     whiteColor.withOpacity(0.1),
                      //     whiteColor.withOpacity(0.1),
                      //   ],
                      // ),
                      border: Border.all(color: title1, width: 0.2),
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.push('/bubble-gem-settings');
                      },
                      icon: Icon(Icons.settings_outlined, color: title1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _profileCard(),

              const SizedBox(height: 24),

              // const Text(
              //   "GAME SETTINGS",
              //   style: TextStyle(
              //     color: Colors.white70,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),

              // const SizedBox(height: 12),
              //
              // _settingTile(
              //   icon: 'assets/images/sound.png',
              //   title: "Sound ",
              //   color: title1.withValues(alpha: 0.1),
              //   activeColor: title1,
              //   value: sound,
              //   onChanged: (v) async {
              //     await SoundSettings.setEnabled(v);
              //     setState(() {
              //       sound = v;
              //     });
              //     if (v) {
              //       SoundManager.instance.playHomeTheme();
              //     } else {
              //       SoundManager.instance.stopTheme();
              //     }
              //   },
              // ),
              // _settingTile(
              //   icon: 'assets/images/vib.png',
              //   title: "Vibration",
              //   color: title1.withValues(alpha: 0.1),
              //   activeColor: title1,
              //   value: vibration,
              //   onChanged: (v) async {
              //     await HapticSettings.setEnabled(v);
              //     setState(() {
              //       vibration = v;
              //     });
              //   },
              // ),
              //
              // const SizedBox(height: 24),
              // const Text(
              //   "ACCOUNT",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 14,
              //   ),
              // ),
              const SizedBox(height: 30),

              _logoutButton(),

              const Spacer(),

              const Center(
                child: Text(
                  "Created with ❤️ by CodeWright",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: whitecolor.withValues(alpha: 0.05),
        border: Border.all(color: whitecolor, width: 0.2),
      ),
      child: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(Icons.arrow_back, color: title1),
      ),
    );
  }

  Widget _profileCard() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        final String name = user?.displayName ?? "guest";
        final String email = user?.email ?? "";
        final String? photoUrl = user?.photoURL;
        return Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "G",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Name",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [bg4.withValues(alpha: 0.2), bg4.withValues(alpha: 0.1)],
                    // ),
                    // color: whitecolor.withValues(alpha: 0.03),
                    border: Border.all(color: subtitle, width: 0.4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.perm_identity, color: subtitle, size: 25),
                      SizedBox(width: 10),
                      Text(
                        name,
                        style: TextStyle(
                          color: subtitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Your Email",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [bg4.withValues(alpha: 0.2), bg4.withValues(alpha: 0.1)],
                    // ),
                    // color: subtitle.withValues(alpha: 0.5),
                    border: Border.all(color: subtitle, width: 0.4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, color: subtitle, size: 25),
                      SizedBox(width: 10),
                      Text(
                        user == null ? 'Tap to Login' : email,
                        style: TextStyle(
                          color: subtitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _settingTile({
    required String icon,
    required String title,
    required Color? color,
    required Color? activeColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [bg4.withValues(alpha: 0.2), bg4.withValues(alpha: 0.1)],
        // ),
        color: title1.withValues(alpha: 0.03),
        // border: Border.all(color: whitecolor, width: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color, // buttonC1.withValues(alpha: 0.1),
            ),

            child: Image.asset(icon),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                ),
              ),
              Text(
                value ? "Enabled" : "Disabled",
                style: TextStyle(
                  color: value ? title1 : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
          const Spacer(),
          Switch(value: value, activeColor: activeColor, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: _confirmLogout,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: logout, width: 1),

          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(
                color: logout,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const LogoutConfirmDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, color: logout, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Logout?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Baloo2',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'Baloo2',
              ),
            ),
            const SizedBox(height: 28),

            /// WATCH AD
            ///

            /// CANCEL
            TextButton(
              onPressed: onConfirm,
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontFamily: 'Baloo2',
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: onCancel,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: [title1, title2]),
                ),
                child: Text(
                  'CANCEL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: whitecolor,
                    fontSize: 20,
                    fontFamily: 'Baloo2',
                  ),
                ),
              ),
            ),

            // BouncyButton(
            //   onTap: onCancel,
            //   child: CustomButton(
            //     label: 'CANCEL',
            //     width: double.infinity,
            //     height: 50,
            //     fontSize: 20,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
