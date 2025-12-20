import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/sport.dart';
import 'sport_detail.dart';
import 'sport_form.dart';
import 'saved_sports_page.dart';
import '../../config/api_config.dart';

class SportListPage extends StatefulWidget {
  final bool isAdmin;
  const SportListPage({super.key, this.isAdmin = false});

  @override
  State<SportListPage> createState() => _SportListPageState();
}

class _SportListPageState extends State<SportListPage> with TickerProviderStateMixin {
  final String baseUrl = ApiConfig.baseUrl;
  String selectedCategory = 'All';
  String selectedDifficulty = 'All';
  late AnimationController _fabController;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabController.forward();
    _headerController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

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
          SnackBar(
            content: const Text("Gagal mengubah status favorit"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin = widget.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: _buildFilterSection(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: FutureBuilder(
              future: fetchSports(request),
              builder: (context, AsyncSnapshot<List<Sport>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Memuat olahraga...",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState());
                } else {
                  final filteredSports = filterSports(snapshot.data!);
                  
                  if (filteredSports.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildNoResultsState(),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildSportCard(filteredSports[index], isAdmin, index),
                        );
                      },
                      childCount: filteredSports.length,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? ScaleTransition(
              scale: CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SportFormPage()),
                  ).then((_) => setState(() {}));
                },
                backgroundColor: const Color(0xFF1E3A8A),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Tambah Sport", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                elevation: 8,
              ),
            )
          : null,
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      stretch: true,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 50),
        title: FadeTransition(
          opacity: _headerController,
          child: const Text(
            'Sport Library',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 40,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Animated circles background
            Positioned(
              top: -50,
              right: -50,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1500),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedSportsPage()),
                ).then((_) => setState(() {}));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.bookmarks_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.filter_list_rounded, color: Color(0xFF1E3A8A), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Filter Olahraga",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFilterGroup(
            "Kategori",
            ['All', 'Indoor', 'Outdoor'],
            selectedCategory,
            Icons.category_rounded,
            (val) => setState(() => selectedCategory = val),
          ),
          const SizedBox(height: 16),
          _buildFilterGroup(
            "Kesulitan",
            ['All', 'Pemula', 'Menengah', 'Lanjutan'],
            selectedDifficulty,
            Icons.trending_up_rounded,
            (val) => setState(() => selectedDifficulty = val),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGroup(String label, List<String> options, String selectedValue, IconData icon, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelect(option),
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF1E3A8A).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSportCard(Sport sport, bool isAdmin, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SportDetailPage(sport: sport, isAdmin: isAdmin),
              ),
            ).then((_) => setState(() {}));
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Animated Icon Container
                  Hero(
                    tag: 'sport-${sport.id}',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A8A).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sport.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildAnimatedBadge(sport.category, const Color(0xFF3B82F6), Icons.location_on),
                            const SizedBox(width: 8),
                            _buildAnimatedBadge(sport.difficulty, const Color(0xFFF59E0B), Icons.bar_chart),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Animated Favorite Button
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sport.isSaved 
                          ? const Color(0xFFEF4444).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) {
                          return ScaleTransition(
                            scale: anim,
                            child: RotationTransition(
                              turns: anim,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          sport.isSaved ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(sport.isSaved),
                          color: sport.isSaved ? const Color(0xFFEF4444) : Colors.grey[400],
                          size: 26,
                        ),
                      ),
                      onPressed: () => toggleSavedSport(sport.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_soccer_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Belum ada data olahraga",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tambahkan olahraga pertama Anda!",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    size: 70,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            "Tidak ada hasil",
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba ubah filter pencarian Anda",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}