import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/authservice.dart';
import '../views/home.dart';
import '../views/register.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isFormValid = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        print("Login berhasil: ${user.email}");
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'User not found. Please register an account.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password. Please try again.';
      } else {
        errorMessage = 'Login failed. Error: ${e.message}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text('Login failed. Error: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _resetPassword(BuildContext context) async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email untuk reset password')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _usernameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email reset password telah dikirim')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim email: $e')),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: const Text(
                "LOGIN",
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Border radius 30
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Saat tidak fokus
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Saat fokus
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  hintText: 'Masukan Email Anda',
                ),
                onChanged: (_) => _validateForm(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              child: TextField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Border radius 30
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Saat tidak fokus
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Saat fokus
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  hintText: 'Masukan Password Anda',
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibility,
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                onChanged: (_) => _validateForm(),
              ),
            ),
            Container(
              height: 50,
              width: 290,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ElevatedButton(
                onPressed: _isFormValid ? () => _login(context) : null,
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 42, 76, 190),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/google_logo.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, color: Colors.red);
                },
              ),
              label: const Text(
                'Login Menggunakan Google',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                User? user = await AuthService().signInWithGoogle();

                if (user != null) {
                  // SIMPAN KE FIRESTORE
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set({
                    'uid': user.uid,
                    'email': user.email,
                    'name': user.displayName,
                    'photo': user.photoURL,
                    'provider': 'google',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _resetPassword(context),
              child: const Text(
                "Lupa Password?",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Agar sejajar di tengah
              children: [
                const Text('Belum Memiliki Akun? '),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Registrasi disini",
                    style: TextStyle(color: Colors.blue),
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
