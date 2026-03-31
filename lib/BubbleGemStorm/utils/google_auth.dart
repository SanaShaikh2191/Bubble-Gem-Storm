import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'bubble_gem_firestore_service.dart';

class GoogleAuthService {
  static final instance =
      GoogleAuthService(); // These are the variables the function was looking for:
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      // --- NEW LOGIC ADDED HERE ---
      if (userCred.user != null) {
        // This calls the initialization method we created in the Firestore service
        await BubbleGemFirestoreService.initializeNewUser(userCred.user!);
      }
      // ----------------------------

      return userCred.user;
    } catch (e) {
      print('Google Sign-In Error:$e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
