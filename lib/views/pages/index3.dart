import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../views/login.dart';

class Index3Page extends StatefulWidget {
  const Index3Page({Key? key}) : super(key: key);

  @override
  _Index3PageState createState() => _Index3PageState();
}

class _Index3PageState extends State<Index3Page> {
  String? email;
  String? name;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  void _getUserDetails() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
        name = user.displayName;
      });
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await GoogleSignIn().signOut(); // Logout dari Google
                await FirebaseAuth.instance.signOut(); // Logout dari Firebase
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 200, horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 100),
              Text('Nama : ${name ?? 'Nama Tidak Tersedia'}',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
              SizedBox(height: 20),
              Text("Email : ${email ?? 'Tidak tersedia'}"),
              SizedBox(height: 20),
              Divider(thickness: 2),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showLogoutConfirmation,
                child: Text('Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
