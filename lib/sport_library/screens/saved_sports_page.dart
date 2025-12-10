import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/sport.dart';
import 'sport_detail.dart';

class SavedSportsPage extends StatefulWidget {
  const SavedSportsPage({super.key});

  @override
  State<SavedSportsPage> createState() => _SavedSportsPageState();
}

class _SavedSportsPageState extends State<SavedSportsPage> {
  final String baseUrl = 'http://localhost:8000';

  Future<List<Sport>> fetchSavedSports(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/sportlibrary/api/saved-sports-json/');
      List<Sport> listSport = [];
      for (var d in response) {
        if (d != null) {
          listSport.add(Sport.fromJson(d));
        }
      }
      return listSport;
    } catch (e) {
      debugPrint('Error fetching saved sports: $e');
      return [];
    }
  }

  Future<void> removeSavedSport(int sportId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '$baseUrl/sportlibrary/api/toggle-saved-sport/$sportId/',
        jsonEncode({}),
      );
      if (response['status'] == 'removed') {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dihapus dari Favorit")),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // Warna Gradasi Baru (Biru Tua ke Biru Terang)
    const gradientColors = [Color(0xFF1E3A8A), Color(0xFF3B82F6)];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Olahraga Favorit Saya', style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white, // Ikon Back Putih
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors, // Gradasi Biru
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: fetchSavedSports(request),
        builder: (context, AsyncSnapshot<List<Sport>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada olahraga favorit.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final sport = snapshot.data![index];
                return _buildSavedCard(sport);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSavedCard(Sport sport) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SportDetailPage(sport: sport, isAdmin: false),
              ),
            ).then((_) => setState(() {}));
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // FOTO DIHAPUS. Diganti Ikon.
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  ),
                  child: const Icon(Icons.sports_soccer_rounded, color: Color(0xFF1E3A8A), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${sport.category} • ${sport.difficulty}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () => removeSavedSport(sport.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}