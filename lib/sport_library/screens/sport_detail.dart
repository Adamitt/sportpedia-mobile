import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/sport.dart';
import 'sport_form.dart';

class SportDetailPage extends StatefulWidget {
  final Sport sport;
  final bool isAdmin;

  const SportDetailPage({super.key, required this.sport, this.isAdmin = false});

  @override
  State<SportDetailPage> createState() => _SportDetailPageState();
}

class _SportDetailPageState extends State<SportDetailPage> {
  static const String baseUrl = 'http://localhost:8000';

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final sport = widget.sport;

    // Warna Gradasi Baru (Biru Tua ke Biru Terang)
    const gradientColors = [Color(0xFF1E3A8A), Color(0xFF3B82F6)];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Tinggi header dikurangi karena tidak ada foto
            expandedHeight: 180.0, 
            pinned: true,
            foregroundColor: Colors.white, // Ikon Back & Love jadi Putih
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                // FOTO DIHAPUS. Diganti background gradasi biru.
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(sport.category),
                          const SizedBox(width: 8),
                          _buildTag(sport.difficulty),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  sport.isSaved ? Icons.favorite : Icons.favorite_border,
                  // Ikon love tetap merah jika disimpan agar kontras, putih jika tidak
                  color: sport.isSaved ? const Color(0xFFEF4444) : Colors.white,
                  size: 26,
                ),
                onPressed: () async {
                   try {
                    final response = await request.post(
                      '$baseUrl/sportlibrary/api/toggle-saved-sport/${sport.id}/',
                      jsonEncode({}),
                    );
                    if (response['status'] == 'saved' || response['status'] == 'removed') {
                      setState(() {
                        sport.isSaved = !sport.isSaved;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message']),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error toggling saved sport: $e');
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Konten Detail
          SliverToBoxAdapter(
            child: Container(
              // Container putih ditarik sedikit ke atas agar menutupi sedikit gradasi
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection("Deskripsi", sport.description, Icons.description),
                    _buildSection("Sejarah", sport.history, Icons.history_edu),
                    _buildListSection("Aturan Dasar", sport.rules, Icons.gavel),
                    _buildListSection("Teknik Dasar", sport.techniques, Icons.accessibility_new),
                    _buildListSection("Manfaat", sport.benefits, Icons.health_and_safety),
                    
                    const SizedBox(height: 30),
                    
                    if (widget.isAdmin) _buildAdminButtons(sport),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25), // Background transparan putih
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    // ... (Kode ini sama persis dengan sebelumnya, tidak perlu diubah)
     return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text("-", style: TextStyle(color: Colors.grey))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bullet point warna biru
                      const Text("• ", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildAdminButtons(Sport sport) {
    // ... (Kode ini sama persis dengan sebelumnya, tidak perlu diubah)
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SportFormPage(sport: sport)),
              ).then((_) => Navigator.pop(context));
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text("Edit", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
             onPressed: () async {
                      bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Olahraga?'),
                              content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                              ],
                            ),
                          ) ?? false;

                      if (confirm) {
                        final request = context.read<CookieRequest>();
                        try {
                          final response = await request.postJson(
                            "$baseUrl/sportlibrary/api/delete-sport-flutter/${sport.id}/",
                            jsonEncode({}),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Berhasil menghapus olahraga")),
                              );
                              Navigator.pop(context); // Kembali ke list
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Gagal menghapus.")),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        }
                      }
                    },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text("Hapus", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}