import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
// TAMBAHAN: Import untuk navigate ke detail gear
import '../../screens/gear_detail_page.dart';
import '../../models/gear_list.dart';
import '../../services/gearguide_service.dart';

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
  List<Datum> _allGears = []; // TAMBAHAN: Cache semua gears untuk convert search result ke Datum

  @override
  void initState() {
    super.initState();
    _loadAllGears(); // TAMBAHAN: Load semua gears untuk convert search result
    _performSearch();
  }

  // TAMBAHAN: Load semua gears dari gearguide API untuk convert search result ke Datum
  Future<void> _loadAllGears() async {
    try {
      final gears = await GearGuideService.fetchGears();
      setState(() {
        _allGears = gears;
      });
    } catch (e) {
      // Ignore error, hanya untuk cache
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Search Header
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
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 100),
              child: Column(
                children: [
                  Text(
                    'Hasil pencarian untuk:',
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.of(context).size.width > 768 ? 40 : 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      widget.query,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menemukan konten terbaik untukmu',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results Content
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error searching',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _performSearch,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gear Results Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.precision_manufacturing,
                            title: 'Gear',
                            count: _gearResults.length,
                          ),
                          const SizedBox(height: 32),
                          if (_gearResults.isEmpty)
                            _buildEmptyState('Tidak ada gear yang cocok dengan pencarian Anda')
                          else
                            _buildGearGrid(_gearResults),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Sport Results Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.sports_soccer,
                            title: 'Sports',
                            count: _sportResults.length,
                          ),
                          const SizedBox(height: 32),
                          if (_sportResults.isEmpty)
                            _buildEmptyState('Tidak ada olahraga yang cocok dengan pencarian Anda')
                          else
                            _buildSportGrid(_sportResults),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title, required int count}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 28),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlueDark,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count items',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGearGrid(List<dynamic> gears) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1024 ? 3 : 
                       MediaQuery.of(context).size.width > 600 ? 2 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.75,
      ),
      itemCount: gears.length,
      itemBuilder: (context, index) {
        final gear = gears[index];
        return _buildGearCard(gear);
      },
    );
  }

  Widget _buildGearCard(Map<String, dynamic> gear) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TAMBAHAN: Navigate ke detail gear dengan mencari gear dari cache
          _navigateToGearDetail(gear);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: gear['image'] != null && gear['image'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          gear['image'].toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.sports, size: 64, color: Colors.grey.shade400),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(Icons.sports, size: 64, color: Colors.grey.shade400),
                      ),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚡ ${gear['sport']?['name'] ?? 'Unknown'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlueDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gear['name'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlueDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gear['price_range'] ?? 'Hubungi untuk harga',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportGrid(List<dynamic> sports) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1024 ? 3 : 
                       MediaQuery.of(context).size.width > 600 ? 2 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.2,
      ),
      itemCount: sports.length,
      itemBuilder: (context, index) {
        final sport = sports[index];
        return _buildSportCard(sport);
      },
    );
  }

  Widget _buildSportCard(Map<String, dynamic> sport) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TAMBAHAN: Sport library belum tersedia di Flutter, tampilkan pesan
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detail olahraga "${sport['name'] ?? ''}" belum tersedia di aplikasi mobile'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '📚 Library',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentRedDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                sport['name'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlueDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  sport['description'] ?? sport['history'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Pelajari Lebih Lanjut',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryBlue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAMBAHAN: Helper untuk navigate ke gear detail dengan convert search result ke Datum
  void _navigateToGearDetail(Map<String, dynamic> gearMap) {
    final gearId = gearMap['id']?.toString();
    if (gearId == null || gearId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gear ID tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cari gear dari cache _allGears berdasarkan ID
    final gear = _allGears.firstWhere(
      (g) => g.id == gearId,
      orElse: () => _convertSearchResultToDatum(gearMap), // Fallback: convert search result
    );

    // Navigate ke detail gear
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GearDetailPage(datum: gear),
      ),
    );
  }

  // TAMBAHAN: Helper untuk convert search result (Map) ke Datum object
  Datum _convertSearchResultToDatum(Map<String, dynamic> gearMap) {
    // Map level dari string ke Level enum
    final levelStr = (gearMap['level']?.toString().toLowerCase() ?? '');
    Level level;
    if (levelStr.contains('pemula') || levelStr.contains('beginner')) {
      level = Level.BEGINNER;
    } else if (levelStr.contains('menengah') || levelStr.contains('intermediate')) {
      level = Level.INTERMEDIATE;
    } else if (levelStr.contains('profesional') || levelStr.contains('advanced') || levelStr.contains('lanjutan')) {
      level = Level.ADVANCED;
    } else {
      level = Level.UNKNOWN;
    }

    // Extract sport info
    final sportMap = gearMap['sport'];
    final sportName = sportMap is Map ? (sportMap['name']?.toString() ?? '') : '';
    final sportId = ''; // Tidak ada di search result, kosongkan saja

    return Datum(
      id: gearMap['id']?.toString() ?? '',
      sportId: sportId,
      sportName: sportName,
      name: gearMap['name']?.toString() ?? '',
      function: gearMap['function']?.toString() ?? '',
      description: gearMap['description']?.toString() ?? '',
      level: level,
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

