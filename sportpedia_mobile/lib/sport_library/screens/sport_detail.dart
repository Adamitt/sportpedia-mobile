import 'dart:convert'; // TAMBAHKAN INI (Penting untuk jsonEncode)
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportpedia_mobile/sport_library/models/sport.dart';
import 'package:sportpedia_mobile/sport_library/screens/sport_form.dart';
import 'package:sportpedia_mobile/sport_library/screens/sport_list.dart';

class SportDetailPage extends StatelessWidget {
  final Sport sport;
  const SportDetailPage({super.key, required this.sport});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // TODO: Ubah logic ini nanti sesuai status login User/Admin
    bool isAdmin = true; 

    return Scaffold(
      appBar: AppBar(
        title: Text(sport.name),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Kategori & Kesulitan
            Row(
              children: [
                Chip(
                  label: Text(sport.category), 
                  backgroundColor: Colors.blue[100],
                  avatar: const Icon(Icons.category, size: 18),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(sport.difficulty), 
                  backgroundColor: Colors.orange[100],
                  avatar: const Icon(Icons.signal_cellular_alt, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSectionTitle("Deskripsi"),
            Text(sport.description),
            const SizedBox(height: 12),

            _buildSectionTitle("Sejarah"),
            Text(sport.history),
            const SizedBox(height: 12),

            _buildSectionTitle("Aturan Dasar"),
            if (sport.rules.isEmpty) const Text("-"),
            ...sport.rules.map((e) => Text("• $e")),
            
            const SizedBox(height: 12),
            _buildSectionTitle("Teknik Dasar"),
            if (sport.techniques.isEmpty) const Text("-"),
            ...sport.techniques.map((e) => Text("• $e")),

            const SizedBox(height: 24),
            
            // Tombol Admin (Edit & Delete)
            if (isAdmin) 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SportFormPage(sport: sport)),
                        );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Edit", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                        // Konfirmasi sebelum hapus
                        bool confirm = await showDialog(
                          context: context, 
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Olahraga?'),
                            content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
                            actions: [
                              TextButton(onPressed: ()=>Navigator.pop(context, false), child: const Text('Batal')),
                              TextButton(onPressed: ()=>Navigator.pop(context, true), child: const Text('Hapus')),
                            ],
                          )
                        ) ?? false;

                        if (confirm) {
                          // Pastikan URL ini sesuai dengan views.py Django kamu
                          final response = await request.postJson(
                            "http://127.0.0.1:8000/api/delete-sport-flutter/${sport.id}/",
                            jsonEncode({}),
                          );
                          
                          if (context.mounted) {
                             if (response['status'] == 'success') {
                                Navigator.pop(context); // Tutup page detail
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SportListPage()));
                             } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus.")));
                             }
                          }
                        }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Hapus", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }
}