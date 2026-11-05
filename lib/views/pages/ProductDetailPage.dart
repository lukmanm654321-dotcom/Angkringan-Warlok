import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String documentId; // ID dokumen di Firestore

  ProductDetailPage({required this.productData, required this.documentId});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: productData['name']);
    TextEditingController priceController =
        TextEditingController(text: productData['price'].toString());
    TextEditingController stockController =
        TextEditingController(text: productData['stok'].toString());

    final CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Detail Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Stok'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () async {
                    try {
                      await products.doc(documentId).update({
                        'name': nameController.text,
                        'price':
                            int.parse(priceController.text), // Harga jadi int
                        'stok': int.parse(stockController.text),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Produk berhasil diperbarui!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal memperbarui produk!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    // Tampilkan dialog konfirmasi
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Konfirmasi Hapus'),
                        content: Text(
                            'Apakah Anda yakin ingin menghapus produk ini?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context, false); // Tutup dialog, tidak hapus
                            },
                            child: Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context,
                                  true); // Tutup dialog, konfirmasi hapus
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text('Hapus',style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    );

                    // Jika pengguna mengonfirmasi, hapus produk
                    if (confirmDelete == true) {
                      try {
                        await products.doc(documentId).delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Produk berhasil dihapus!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus produk!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Hapus',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
