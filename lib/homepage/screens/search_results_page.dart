import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
// Import untuk navigate ke detail
import '../../screens/gear_detail_page.dart';
import '../../models/gear_list.dart';
import '../../services/gearguide_service.dart';
import '../../sport_library/models/sport.dart';
import '../../sport_library/screens/sport_detail.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  
  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _gearResults = [];
  List<dynamic> _sportResults = [];
  List<Datum> _allGears = []; 

  @override
  void initState() {
    super.initState();
    _loadAllGears(); 
    _performSearch();
  }

  Future<void> _loadAllGears() async {
    try {
      final gears = await GearGuideService.fetchGears();
      setState(() {
        _allGears = gears;
      });
    } catch (e) {
      debugPrint('Warning: Failed to load all gears: $e');
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await HomepageApiService.search(query: widget.query);
      
      setState(() {
        _gearResults = results['gear_results'] ?? [];
        _sportResults = results['sport_results'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Search Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlueDark,
                    AppColors.primaryBlue,
                    const Color(0xFF0f1f3d),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 110, 24, 60),
              child: Column(
                children: [
                  Text(
                    'Hasil pencarian untuk:',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      widget.query,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Results
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Terjadi kesalahan', style: GoogleFonts.poppins()),
                    TextButton(onPressed: _performSearch, child: const Text('Coba Lagi')),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -30), // Tarik ke atas sedikit agar estetik
                child: Column(
                  children: [
                    // --- SECTION GEAR ---
                    _buildResultSection(
                      title: 'Gear',
                      icon: Icons.precision_manufacturing,
                      count: _gearResults.length,
                      isEmpty: _gearResults.isEmpty,
                      // Gunakan Horizontal List
                      child: _buildHorizontalGearList(),
                    ),

                    const SizedBox(height: 24),

                    // --- SECTION SPORTS ---
                    _buildResultSection(
                      title: 'Sports',
                      icon: Icons.sports_soccer,
                      count: _sportResults.length,
                      isEmpty: _sportResults.isEmpty,
                      // Gunakan Horizontal List
                      child: _buildHorizontalSportList(),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget Container untuk setiap Section
  Widget _buildResultSection({
    required String title,
    required IconData icon,
    required int count,
    required bool isEmpty,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlueDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count items',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Isi Content (Horizontal List atau Empty State)
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada hasil ditemukan',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            child,
        ],
      ),
    );
  }

  // --- HORIZONTAL LIST GEAR ---
  Widget _buildHorizontalGearList() {
    return SizedBox(
      height: 310, // Tinggi fix untuk list horizontal
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _gearResults.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 200, // Lebar fix tiap kartu
            child: _buildGearCard(_gearResults[index]),
          );
        },
      ),
    );
  }

  // --- HORIZONTAL LIST SPORTS ---
  Widget _buildHorizontalSportList() {
    return SizedBox(
      height: 230, // Tinggi fix untuk list horizontal
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _sportResults.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 260, // Lebar fix tiap kartu
            child: _buildSportCard(_sportResults[index]),
          );
        },
      ),
    );
  }

  // --- CARD GEAR (Fix Overflow) ---
  Widget _buildGearCard(Map<String, dynamic> gear) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToGearDetail(gear),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar (Fixed Height)
            Container(
              height: 140, // Tinggi gambar tetap agar tidak geser konten lain
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: gear['image'] != null && gear['image'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        gear['image'].toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.sports, color: Colors.grey.shade400, size: 40),
                      ),
                    )
                  : Icon(Icons.sports, color: Colors.grey.shade400, size: 40),
            ),
            
            // Konten
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Kategori
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        gear['sport']?['name'] ?? 'General',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Nama Gear
                    Text(
                      gear['name'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(), // Dorong harga/detail ke bawah
                    
                    // Harga
                    Text(
                      gear['price_range'] ?? '-',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Link Detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primaryBlue),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CARD SPORT (Fix Overflow) ---
  Widget _buildSportCard(Map<String, dynamic> sport) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToSportDetail(sport),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📚 Library',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentRedDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Nama Sport
              Text(
                sport['name'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlueDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Deskripsi
              Expanded(
                child: Text(
                  sport['description'] ?? sport['history'] ?? 'No description',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Pelajari',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryBlue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NAVIGATION HELPERS ---
  void _navigateToGearDetail(Map<String, dynamic> gearMap) {
    final gearId = gearMap['id']?.toString();
    if (gearId == null || gearId.isEmpty) return;

    final gear = _allGears.firstWhere(
      (g) => g.id == gearId,
      orElse: () => _convertSearchResultToDatum(gearMap),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GearDetailPage(datum: gear)),
    );
  }

  void _navigateToSportDetail(Map<String, dynamic> sport) {
    final sportObj = Sport(
      id: sport['id'] ?? 0,
      name: sport['name'] ?? '',
      category: sport['category'] ?? 'Unknown',
      difficulty: sport['difficulty'] ?? 'Unknown',
      description: sport['description'] ?? '',
      history: sport['history'] ?? '',
      rules: List<String>.from(sport['rules'] ?? []),
      techniques: List<String>.from(sport['techniques'] ?? []),
      benefits: List<String>.from(sport['benefits'] ?? []),
      popularCountries: List<String>.from(sport['popular_countries'] ?? []),
      tags: List<String>.from(sport['tags'] ?? []),
      image: sport['image'] ?? '',
      isSaved: sport['is_saved'] ?? false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SportDetailPage(sport: sportObj)),
    );
  }

  Datum _convertSearchResultToDatum(Map<String, dynamic> gearMap) {
    return Datum(
      id: gearMap['id']?.toString() ?? '',
      sportId: '',
      sportName: gearMap['sport'] is Map ? (gearMap['sport']['name'] ?? '') : '',
      name: gearMap['name']?.toString() ?? '',
      function: gearMap['function']?.toString() ?? '',
      description: gearMap['description']?.toString() ?? '',
      level: Level.UNKNOWN, 
      levelDisplay: gearMap['level']?.toString() ?? '',
      priceRange: gearMap['price_range']?.toString() ?? '',
      recommendedBrands: [],
      materials: [],
      careTips: '',
      ecommerceLink: '',
      tags: [],
      image: gearMap['image']?.toString() ?? '',
      owner: null,
    );
  }
}