import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HistoriDetailPage.dart';

class Index0Page extends StatefulWidget {
  @override
  _Index0PageState createState() => _Index0PageState();
}

class _Index0PageState extends State<Index0Page> {
  final List<Map<String, dynamic>> _pesanan = [];
  String? email;
  String? nameKasir;

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
        nameKasir = user.displayName;
      });
    }
  }

  void _tambahPesanan(String name, int price, int stok) {
    // Cek apakah stok masih ada
    if (stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok produk $name habis!')),
      );
      return;
    }

    setState(() {
      final existingItemIndex =
          _pesanan.indexWhere((item) => item['name'] == name);
      if (existingItemIndex != -1) {
        _pesanan[existingItemIndex]['quantity'] += 1;
        _pesanan[existingItemIndex]['price'] =
            price * _pesanan[existingItemIndex]['quantity'];
      } else {
        _pesanan.add({'name': name, 'price': price, 'quantity': 1});
      }
    });
  }

  void _hapusPesanan(int index) {
    setState(() {
      _pesanan.removeAt(index);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMenuItems() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'price': doc['price'],
        'stok': doc['stok'],
      };
    }).toList();
  }

  Future<String> _generateTransactionNumber() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .orderBy('transactionNumber', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String lastTransactionNumber = snapshot.docs.first['transactionNumber'];
      int lastNumber = int.parse(lastTransactionNumber.substring(1));
      return 'N${(lastNumber + 1).toString().padLeft(5, '0')}';
    } else {
      return 'N00001';
    }
  }

  void _bayar() async {
    if (_pesanan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada pesanan untuk dibayar!')),
      );
      return;
    }

    int total = _pesanan.fold(0, (sum, item) => sum + (item['price'] as int));

    showDialog(
      context: context,
      builder: (context) {
        int paymentAmount = 0;

        return AlertDialog(
          title: Text('Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total yang harus dibayar: Rp $total'),
              TextField(
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Masukkan Jumlah Pembayaran'),
                onChanged: (value) {
                  paymentAmount = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (paymentAmount < total) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Jumlah pembayaran tidak cukup!')),
                  );
                } else {
                  int change = paymentAmount - total;
                  String transactionNumber = await _generateTransactionNumber();

                  String? transactionId = await _uploadOrderToFirestore(
                      transactionNumber,
                      nameKasir ?? "Kasir Tidak Diketahui",
                      total,
                      paymentAmount,
                      change);

                  if (transactionId != null) {
                    setState(() {
                      _pesanan.clear();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaksi Berhasil!')),
                    );

                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailHistoriPage(transactionId: transactionId),
                        ),
                      );
                    });
                  }
                }
              },
              child: Text('Bayar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadOrderToFirestore(String transactionNumber,
      String nameKasir, int total, int payment, int change) async {
    final orderData = {
      'transactionNumber': transactionNumber,
      'kasir': nameKasir,
      'items': _pesanan,
      'total': total,
      'pembayaran': payment,
      'kembalian': change,
      'timestamp': FieldValue.serverTimestamp(),
      'status_pembayaran': 'Lunas',
    };

    try {
      for (var item in _pesanan) {
        QuerySnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: item['name'])
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          DocumentSnapshot productDoc = productSnapshot.docs.first;
          int currentStock = productDoc['stok'] ?? 0;
          int quantity = item['quantity'];

          int newStock = currentStock - quantity;

          if (newStock < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Stok produk "${item['name']}" tidak tersedia')),
            );
            return null;
          }

          await FirebaseFirestore.instance
              .collection('products')
              .doc(productDoc.id)
              .update({'stok': newStock});
        }
      }

      DocumentReference orderRef =
          await FirebaseFirestore.instance.collection('orders').add(orderData);

      return orderRef.id;
    } catch (e) {
      print('Error uploading order: $e');
      return null;
    }
  }

  Map<int, TextEditingController> _controllers = {}; // Store controllers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Sistem Kasir')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Text('Menu Produk', style: TextStyle(fontSize: 24)),
            ),
            SizedBox(
              height: 250,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchMenuItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No menu items found.');
                  }

                  final menuItems = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item['name'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Rp ${item['price']} - Stok: ${item['stok']}', // Tampilkan stok
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
                          trailing: IconButton(
                            icon: Icon(Icons.add_circle,
                                color: Colors.green, size: 30),
                            onPressed: () {
                              _tambahPesanan(item['name'], item['price'],
                                  item['stok']); // Tambahkan stok ke fungsi
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text('Detail Barang', style: TextStyle(fontSize: 24)),
            ),
            SizedBox(
              height: 250,
              child: _pesanan.isEmpty
                  ? const Center(child: Text('Belum ada pesanan.'))
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _pesanan.length,
                        itemBuilder: (context, index) {
                          final item = _pesanan[index];

                          // Initialize controller if it doesn't exist
                          _controllers.putIfAbsent(
                              index, () => TextEditingController());
                          _controllers[index]!.text =
                              item['quantity'].toString(); // Set the text

                          return Dismissible(
                            key: Key(item['name']),
                            onDismissed: (direction) {
                              _hapusPesanan(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${item['name']} dihapus')),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: ListTile(
                              title: Text(item['name']),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Rp. ${item['price']}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _kurangiJumlah(index);
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Center(
                                          child: Text( // Changed to Text widget
                                            item['quantity'].toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _tambahJumlah(index);
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _bayar,
                child: Text('Lanjutkan Pembayaran',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menambah dan mengurangi jumlah
  void _tambahJumlah(int index) {
    setState(() {
      _pesanan[index]['quantity']++;
      _pesanan[index]['price'] = _pesanan[index]['price'] ~/
          (_pesanan[index]['quantity'] - 1) *
          _pesanan[index]['quantity'];
    });
  }

  void _kurangiJumlah(int index) {
    setState(() {
      if (_pesanan[index]['quantity'] > 1) {
        // Quantity minimal 1, tidak boleh 0
        _pesanan[index]['quantity']--;
        _pesanan[index]['price'] = _pesanan[index]['price'] ~/
            (_pesanan[index]['quantity'] + 1) *
            _pesanan[index]['quantity'];
      } else if (_pesanan[index]['quantity'] == 1) {
        _pesanan[index]['quantity']--;
        _pesanan.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _controllers.forEach((index, controller) => controller.dispose());
    super.dispose();
  }
}
