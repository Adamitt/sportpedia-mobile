import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/sport.dart';
import 'sport_detail.dart';
import 'sport_form.dart';
import 'saved_sports_page.dart';

class SportListPage extends StatefulWidget {
  final bool isAdmin;
  const SportListPage({super.key, this.isAdmin = false});

  @override
  State<SportListPage> createState() => _SportListPageState();
}

class _SportListPageState extends State<SportListPage> {
  // Ganti URL sesuai environment (Web/Android)
  final String baseUrl = 'http://localhost:8000';

  String selectedCategory = 'All';
  String selectedDifficulty = 'All';

  Future<List<Sport>> fetchSports(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/sportlibrary/api/show-sports-json/');
      List<Sport> listSport = [];
      for (var d in response) {
        if (d != null) {
          listSport.add(Sport.fromJson(d));
        }
      }
      return listSport;
    } catch (e) {
      debugPrint('Error fetching sports: $e');
      return [];
    }
  }

  List<Sport> filterSports(List<Sport> sports) {
    return sports.where((sport) {
      final categoryMatch = selectedCategory == 'All' || sport.category == selectedCategory;
      final difficultyMatch = selectedDifficulty == 'All' || sport.difficulty == selectedDifficulty;
      return categoryMatch && difficultyMatch;
    }).toList();
  }

  Future<void> toggleSavedSport(int sportId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '$baseUrl/sportlibrary/api/toggle-saved-sport/$sportId/',
        jsonEncode({}),
      );

      if (response['status'] == 'saved' || response['status'] == 'removed') {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error toggling saved sport: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengubah status favorit")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin = widget.isAdmin;

    const gradientColors = [Color(0xFF1E3A8A), Color(0xFF3B82F6)];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Sport Library',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmarks_rounded, color: Colors.white),
                tooltip: "Lihat Favorit",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SavedSportsPage()),
                  ).then((_) => setState(() {}));
                },
              )
            ],
          ),
        ],
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterGroup("Kategori", ['All', 'Indoor', 'Outdoor'], selectedCategory, (val) {
                    setState(() => selectedCategory = val);
                  }),
                  const SizedBox(height: 12),
                  _buildFilterGroup("Kesulitan", ['All', 'Pemula', 'Menengah', 'Lanjutan'], selectedDifficulty, (val) {
                    setState(() => selectedDifficulty = val);
                  }),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: fetchSports(request),
                builder: (context, AsyncSnapshot<List<Sport>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    final filteredSports = filterSports(snapshot.data!);
                    
                    if (filteredSports.isEmpty) {
                      return const Center(child: Text("Tidak ada olahraga yang cocok."));
                    }

                    return RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSports.length,
                        itemBuilder: (context, index) {
                          return _buildSportCard(filteredSports[index], isAdmin);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SportFormPage()),
                ).then((_) => setState(() {}));
              },
              backgroundColor: const Color(0xFF1E3A8A),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFilterGroup(String label, List<String> options, String selectedValue, Function(String) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          ...options.map((option) {
            final isSelected = selectedValue == option;
            final activeColor = const Color(0xFF1E3A8A); 
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onSelect(option),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSportCard(Sport sport, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SportDetailPage(sport: sport, isAdmin: isAdmin),
              ),
            ).then((_) => setState(() {}));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Ikon Peluit (Icons.sports)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  ),
                  // PERUBAHAN DI SINI: Icons.sports
                  child: const Icon(Icons.sports, color: Color(0xFF1E3A8A), size: 32),
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniBadge(sport.category, Colors.blue),
                          const SizedBox(width: 6),
                          _buildMiniBadge(sport.difficulty, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      sport.isSaved ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(sport.isSaved),
                      color: sport.isSaved ? const Color(0xFFEF4444) : Colors.grey,
                      size: 28,
                    ),
                  ),
                  onPressed: () => toggleSavedSport(sport.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada data olahraga.",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}