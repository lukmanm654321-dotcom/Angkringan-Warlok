import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../views/login.dart'; // Arahkan ke halaman login

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isFormValid = false;

  // Menyembunyikan atau menampilkan password
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  // Validasi form agar tombol hanya aktif jika semua field valid
  void _validateForm() {
    setState(() {
      _isFormValid = nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          passwordController.text.length >= 6;
    });
  }

  // Fungsi registrasi pengguna
  void _registerUser() {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((value) {
      // Menyimpan nama lengkap ke profil pengguna
      User? user = value.user;
      if (user != null) {
        user.updateProfile(displayName: nameController.text).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Registrasi Berhasil! Silakan login."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Tunggu sebentar sebelum pindah ke halaman login
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage()), // Arahkan ke login
            );
          });
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registrasi Gagal: ${error.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
              child: Text(
                "REGISTRASI",
                style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              child: TextField(
                controller: nameController,
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
                  hintText: 'Nama Lengkap',
                ),
                onChanged: (_) => _validateForm(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              child: TextField(
                controller: emailController,
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
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              child: TextField(
                controller: passwordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Radius sudut
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Radius saat tidak fokus
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Radius saat fokus
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
              width: 270,
              child: ElevatedButton(
                onPressed: _isFormValid ? _registerUser : null,
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Agar sejajar di tengah
              children: [
                const Text('Sudah Memiliki Akun? '),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Klik Disini",
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
