import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo/ui/pages/home_page.dart';
import 'package:todo/ui/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already signed in
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // User is already signed in, navigate to HomePage
      Get.off(() => const HomePage());
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in process
        setState(() {
          _isLoading = false;
        });
        return;
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
      
      // Get the user from the UserCredential
      final User? user = userCredential.user;

      if (user != null) {
        // User successfully signed in
        Get.snackbar(
          "로그인 성공",
          "${user.displayName}님 환영합니다",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        
        // Navigate to HomePage
        Get.off(() => const HomePage());
      }
    } catch (e) {
      Get.snackbar(
        "로그인 실패",
        "오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? darkGreyClr : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon and Title
                Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Get.isDarkMode ? Colors.white : primaryClr,
                ),
                const SizedBox(height: 20),
                Text(
                  "할 일 관리",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode ? Colors.white : darkGreyClr,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Welcome Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "시작하려면 Google 계정으로 로그인하세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                
                // Google Sign In Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                        label: const Text(
                          "Google로 로그인",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryClr,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _signInWithGoogle,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
