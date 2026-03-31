import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/google_auth.dart';
import '../utils/haptic_manager.dart';
import '../utils/sound_manager.dart';
import '../utils/sounds_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                children: [
                  _backButton(),
                  // const Spacer(),
                  // gradientText(
                  //   [title1, title2],
                  //   'Profile',
                  //   fontsize: 50,
                  //   letterSpacing: 1,
                  //   fontweight: FontWeight.w900,
                  // ),
                  // const Spacer(),
                ],
              ),

              // const SizedBox(height: 20),

              // _profileCard(),
              const SizedBox(height: 24),

              const Text(
                "Game",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 12),

              _settingTile(
                icon: 'assets/images/sound.png',
                title: "Sound ",
                subtitle: 'Pops, bursts, and explosion',
                color: title1.withValues(alpha: 0.1),
                activeColor: title1,
                value: sound,
                onChanged: (v) async {
                  await SoundSettings.setEnabled(v);
                  setState(() {
                    sound = v;
                  });
                  if (v) {
                    SoundManager.instance.playHomeTheme();
                  } else {
                    SoundManager.instance.stopTheme();
                  }
                },
              ),
              _settingTile(
                icon: 'assets/images/vib.png',
                title: "Vibration",
                subtitle: 'Vibrate on interactions',
                color: title1.withValues(alpha: 0.1),
                activeColor: title1,
                value: vibration,
                onChanged: (v) async {
                  await HapticSettings.setEnabled(v);
                  setState(() {
                    vibration = v;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                "Account",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 12),

              _accountCards(
                name: 'Privacy Policy',
                icon: Icons.shield_outlined,
              ),
              _accountCards(
                name: 'Terms of Services',
                icon: Icons.wallet_outlined,
              ),
              _accountCards(name: 'About Game', icon: Icons.info_outline),

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

  Widget _settingTile({
    required String icon,
    required String title,
    required String subtitle,
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
        color: bg,
        // title1.withValues(alpha: 0.03),
        // border: Border.all(color: whitecolor, width: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 10,
            color: title2.withValues(alpha: 0.3),
          ),
        ],
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
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                  fontSize: 20,
                ),
              ),
              Text(
                subtitle,
                // value ? "Enabled" : "Disabled",
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

  Widget _accountCards({required IconData icon, required String name}) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [bg4.withValues(alpha: 0.2), bg4.withValues(alpha: 0.1)],
        // ),
        color: bg,
        // border: Border.all(color: whitecolor, width: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 10,
            color: title2.withValues(alpha: 0.3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          SizedBox(width: 30),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Baloo2',
              fontSize: 20,
            ),
          ),
          // Text(
          //   "Sign out of your account",
          //   style: TextStyle(
          //     color: Colors.white70,
          //     fontSize: 12,
          //     fontFamily: 'Baloo2',
          //   ),
          // ),
        ],
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
