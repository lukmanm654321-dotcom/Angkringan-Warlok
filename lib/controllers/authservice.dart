import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "966190527694-ejma5j0j0r972sk1rtg0a9ug622255h7.apps.googleusercontent.com", // Tambahkan Client ID khusus Web
    signInOption: SignInOption.standard,
  );

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Logout terlebih dahulu agar selalu memilih akun
      // Mulai proses sign-in Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Jika pengguna membatalkan login

      // Dapatkan kredensial otentikasi Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase dengan kredensial Google
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }
}
