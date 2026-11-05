import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProductDetailPage.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  // final List<Map<String, dynamic>> _pesanan = [];

  Future<void> _tambahProduk() async {
    String name = '';
    int price = 0;
    int stok = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nama Produk'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Harga Produk'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  price = int.tryParse(value) ?? 0;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  stok = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (name.isNotEmpty && price > 0) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('products')
                        .add({
                      'name': name,
                      'price': price,
                      'stok': stok,
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$name berhasil ditambahkan ke menu!')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menambahkan produk: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Silakan lengkapi semua field!')),
                  );
                }
              },
              child: Text('Tambah'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Produk',
        )),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu Produk', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('Tidak ada produk.'));
                        }

                        final menuItems = snapshot.data!.docs;

                        return ListView(
                          children: menuItems.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Card(
                              child: ListTile(
                                title: Text(data['name'],
                                    style: TextStyle(fontSize: 20)),
                                subtitle: Text(
                                  'Rp ${data['price']} - stok: ${data['stok']}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        productData: data,
                                        documentId: doc.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: _tambahProduk,
                backgroundColor: Colors.black,
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
