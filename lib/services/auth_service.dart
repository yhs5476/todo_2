import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
  }

  bool get isLoggedIn => currentUser.value != null;

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }

      // Obtain auth details from Google Sign In
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Return the user
      return userCredential.user;
    } catch (e) {
      Get.snackbar(
        "로그인 실패",
        "오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        "로그아웃 실패", 
        "오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
