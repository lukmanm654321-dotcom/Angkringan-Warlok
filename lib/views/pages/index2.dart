import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

import 'HistoriDetailPage.dart';

class HistoriTransaksiPage extends StatelessWidget {
  const HistoriTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada transaksi ditemukan.'));
          }
          final transactions = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionItem(transactions[index], context);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
      DocumentSnapshot transaction, BuildContext context) {
    final data = transaction.data() as Map<String, dynamic>;
    final amount = data['total']?.toDouble() ?? 0.0;
    final timestamp = data['timestamp'] as Timestamp?;
    final date = timestamp?.toDate().toLocal().toString().split(' ')[0] ?? 'Unknown Date';
    final time = timestamp?.toDate().toLocal().toString().split(' ')[1].substring(0, 5) ?? 'Unknown Time';
    final status = data['status_pembayaran'] ?? 'Transaksi Gagal';
    final transactionNumber = data['transactionNumber'] ?? 'Unknown';
    final statusColor = (status == 'Transaksi Gagal') ? Colors.red : Colors.green;

    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailHistoriPage(transactionId: transaction.id),
        ),
      ),
      title: Text('No. Transaksi: $transactionNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rp $amount', style: const TextStyle(color: Colors.green)),
          Text('$date, $time', style: const TextStyle(color: Colors.grey)),
          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }

  Future<void> _exportToExcel(BuildContext context) async {
    if (await _requestStoragePermission()) {
      await _exportData(context);
    } else {
      _showDialog(context, "Peringatan", "Izin penyimpanan tidak diberikan.");
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      return await Permission.manageExternalStorage.request().isGranted;
    }
    return true;
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      final transactions = snapshot.docs;

      if (transactions.isEmpty) {
        _showDialog(context, "Informasi", "Tidak ada data untuk diekspor.");
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel['Histori Transaksi'];
      final headers = transactions.first.data().keys.toList();
      sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (var transaction in transactions) {
        final data = transaction.data();
        final row = data.values.map((value) {
          if (value is Timestamp) {
            return TextCellValue(value.toDate().toLocal().toString());
          }
          return TextCellValue(value.toString());
        }).toList();
        sheet.appendRow(row);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception("Gagal membuat file Excel.");
      }

      Directory directory = Directory('/storage/emulated/0/Download/Cashier');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final filePath = '${directory.path}/Histori_Transaksi.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      print("File disimpan di: $filePath");

      // Hanya menampilkan pesan sukses, tanpa membuka file
      _showDialog(context, "Sukses", "File berhasil diekspor ke $filePath");

    } catch (e) {
      _showDialog(context, "Error", "Gagal mengekspor data: $e");
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
