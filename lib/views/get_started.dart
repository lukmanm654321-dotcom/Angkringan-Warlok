// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, sort_child_properties_last, deprecated_member_use

import '../views/login.dart';
import 'package:flutter/material.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         ClipOval(
            child: Image.asset(
              'assets/logo_angkringan.jpg',
              width: 200, // Atur lebar sesuai kebutuhan
              height: 200, // Atur tinggi sesuai kebutuhan
              fit: BoxFit.cover, // Memastikan gambar terisi penuh
            )),
          Center( // Memusatkan teks
            child: Text(
              'CASHIER',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Memusatkan teks
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 28.0),
            child: Text(
              'Untuk memulai aplikasi klik Mulai.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 50,
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                    (Route<dynamic> route) => false);
              },
              child: Text('Mulai'),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(color: Colors.black),
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
