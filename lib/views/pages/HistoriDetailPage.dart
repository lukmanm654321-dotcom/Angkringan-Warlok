import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class DetailHistoriPage extends StatefulWidget {
  final String transactionId;

  const DetailHistoriPage({super.key, required this.transactionId});

  @override
  State<DetailHistoriPage> createState() => _DetailHistoriPageState();
}

class _DetailHistoriPageState extends State<DetailHistoriPage> {
  List<BluetoothInfo> devices = [];
  String? selectedMacAddress;
  bool isLoading = false;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
    _initBluetoothConnection();
  }

  // Cek status koneksi awal menggunakan connectionStatus
  Future<void> _initBluetoothConnection() async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    setState(() {
      connected = isConnected ?? false;
    });
  }

  // Mendapatkan daftar perangkat bluetooth yang sudah di-pair
  Future<void> _getBluetoothDevices() async {
    setState(() => isLoading = true);
    try {
      List<BluetoothInfo> availableDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() {
        devices = availableDevices;
      });
    } catch (e) {
      log("Error get devices: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendapatkan daftar perangkat: Nyalakan Bluetooth!'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Menghubungkan ke perangkat printer
  Future<void> _connectToDevice(BluetoothInfo device) async {
    setState(() => isLoading = true);

    try {
      bool status = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress);
      
      if (status) {
        setState(() {
          connected = true;
          selectedMacAddress = device.macAdress;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terhubung ke printer')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal terhubung ke perangkat')),
          );
        }
      }
    } catch (e) {
      log("Error connect: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat menghubungkan')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Fungsi untuk mencetak struk
  Future<void> printReceipt(Map<String, dynamic> data) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer tidak terhubung.')),
        );
      }
      return;
    }

    try {
      String ticketContent = "";

      // Header Struk
      ticketContent += "\n\n";
      ticketContent += "\x1B\x61\x01"; // Center align
      ticketContent += "\x1B\x21\x30"; // Double width & height
      ticketContent += "Angkringan Warlok\n";
      ticketContent += "\x1B\x21\x00"; // Normal text
      ticketContent += "Jl. M. Ento No.19\n";
      ticketContent += "0812-2115-9537\n\n";

      // Informasi Transaksi
      ticketContent += "\x1B\x61\x00"; // Left align
      ticketContent += "Kasir       : ${data['kasir'] ?? "-"}\n";
      ticketContent += "No Transaksi: ${data['transactionNumber'] ?? "-"}\n";
      
      Timestamp? timestamp = data['timestamp'] as Timestamp?;
      String dateStr = timestamp != null ? timestamp.toDate().toString().split(' ')[0] : "-";
      String timeStr = timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : "-";
      
      ticketContent += "Tanggal     : $dateStr\n";
      ticketContent += "Jam         : $timeStr\n";
      ticketContent += "--------------------------------\n";
      ticketContent += "Detail Pesanan:\n";

      // Daftar Item Pesanan
      if (data['items'] is List) {
        for (var item in data['items']) {
          String name = "${item['quantity']}x ${item['name']}";
          String price = "Rp ${item['price']}";
          ticketContent += _formatLeftRight(name, price, 32);
        }
      }

      ticketContent += "--------------------------------\n";
      ticketContent += _formatLeftRight("Total:", "Rp ${data['total'] ?? 0}", 32);
      ticketContent += _formatLeftRight("Pembayaran:", "Rp ${data['pembayaran'] ?? 0}", 32);
      ticketContent += _formatLeftRight("Kembalian:", "Rp ${data['kembalian'] ?? 0}", 32);
      ticketContent += "--------------------------------\n";
      
      // Status Pembayaran (Center)
      ticketContent += "\x1B\x61\x01";
      ticketContent += "Status: ${data['status_pembayaran'] ?? '-'}\n\n\n";
      ticketContent += "\x1B\x69"; // Paper cut command

      // Kirim bytes ke printer
      await PrintBluetoothThermal.writeBytes(ticketContent.codeUnits);
    } catch (e) {
      log("Print error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencetak struk, periksa koneksi bluetooth')),
        );
      }
    }
  }

  // Helper format rata kiri-kanan
  String _formatLeftRight(String left, String right, int maxColumns) {
    int spaces = maxColumns - (left.length + right.length);
    if (spaces < 1) spaces = 1;
    String padding = ' ' * spaces;
    return "$left$padding$right\n";
  }

  // Dialog Pemilihan Perangkat Bluetooth
  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih Perangkat Bluetooth"),
        content: devices.isEmpty
            ? const Text("Tidak ada perangkat yang tersedia. Pastikan Bluetooth aktif dan sudah di-pairing.")
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(device.name.isNotEmpty ? device.name : "Unknown Device"),
                      subtitle: Text(device.macAdress),
                      onTap: () {
                        Navigator.pop(context);
                        _connectToDevice(device);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getBluetoothDevices();
            },
            child: const Text("Refresh"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: connected ? Colors.greenAccent : Colors.white,
            ),
            onPressed: _showBluetoothDialog,
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: isLoading
                ? null
                : () async {
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(widget.transactionId)
                        .get();

                    if (snapshot.exists) {
                      printReceipt(snapshot.data() as Map<String, dynamic>);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Data transaksi tidak ditemukan.')),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.transactionId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Angkringan Warlok',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                const Center(
                  child: Text(
                    'Jl. M. Ento No. 19',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const Center(
                  child: Text(
                    '0812-2115-9537',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const Divider(),
                Text(
                  'Kasir: ${data['kasir'] ?? "-"}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'No. Transaksi: ${data['transactionNumber'] ?? "-"}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Tanggal: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0] : "-"}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Jam: ${data['timestamp'] != null ? DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate()) : "-"}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Detail Pesanan:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List<Widget>.from(
                  (data['items'] as List? ?? []).map(
                    (item) => ListTile(
                      title: Text(
                        '${item['name']} x${item['quantity']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        'Rp ${item['price']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18)),
                    Text('Rp ${data['total'] ?? 0}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pembayaran', style: TextStyle(fontSize: 18)),
                    Text('Rp ${data['pembayaran'] ?? 0}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian', style: TextStyle(fontSize: 18)),
                    Text('Rp ${data['kembalian'] ?? 0}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}