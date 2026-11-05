// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kembali'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/usus.jpg',
                width: 200,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Sate Usus',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 28),
              //   child: Text('Klik tombol "Pinjam" untuk meminjam buku'),
              // ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Tambahkan Pesanan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
