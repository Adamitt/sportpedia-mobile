import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/popular_category.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
// Import untuk navigate ke detail
import '../../sport_library/screens/sport_detail.dart';
import '../../sport_library/models/sport.dart';
import '../../screens/gear_detail_page.dart';
import '../../models/gear_list.dart';
import '../../services/gearguide_service.dart';

class PopularCategoriesSection extends StatefulWidget {
  const PopularCategoriesSection({super.key});

  @override
  State<PopularCategoriesSection> createState() =>
      _PopularCategoriesSectionState();
}

class _PopularCategoriesSectionState extends State<PopularCategoriesSection> {
  List<PopularCategory> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ambil data asli dari server
      var items = await HomepageApiService.getPopularCategories(limit: 3);

      // --- TRIK CHEAT (AGAR SELALU TAMPIL 3 ITEM) ---
      // Jika data kurang dari 3, duplikat data yang ada.
      if (items.isNotEmpty && items.length < 3) {
        while (items.length < 3) {
          items.add(items[0]); // Copy item pertama sampai jumlahnya 3
        }
      }
      // -------------------------------------------

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // chevinka: Extract Sport ID dari URL Django (int)
  int? _extractSportIdFromUrl(String url) {
    try {
      // URL format: /sportlibrary/<sport_id>/
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.length >= 2 && segments[0] == 'sportlibrary') {
        final idStr = segments[1];
        return int.tryParse(idStr);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // chevinka: Extract Gear ID dari URL Django (String)
  String? _extractGearIdFromUrl(String url) {
    try {
      // URL format: /gearguide/details/<gear_id>/ atau /gearguide/<gear_id>/
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.length >= 2 && segments[0] == 'gearguide') {
        if (segments[1] == 'details' && segments.length >= 3) {
          // Format: /gearguide/details/<gear_id>/
          return segments[2];
        } else {
          // Format: /gearguide/<gear_id>/
          return segments[1];
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // chevinka: Navigate ke Sport Detail Page
  Future<void> _navigateToSportDetail(int sportId) async {
    try {
      final request = context.read<CookieRequest>();
      final baseUrl = 'https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id';

      // Fetch semua sports dan cari yang sesuai ID
      final response =
          await request.get('$baseUrl/sportlibrary/api/show-sports-json/');
      List<Sport> sports = [];
      for (var d in response) {
        if (d != null) {
          sports.add(Sport.fromJson(d));
        }
      }

      final sport = sports.firstWhere(
        (s) => s.id == sportId,
        orElse: () => throw Exception('Sport tidak ditemukan'),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SportDetailPage(sport: sport, isAdmin: false),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka detail: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // chevinka: Navigate ke Gear Detail Page
  Future<void> _navigateToGearDetail(String gearId) async {
    try {
      // Fetch semua gears dan cari yang sesuai ID
      final gears = await GearGuideService.fetchGears();

      final gear = gears.firstWhere(
        (g) => g.id == gearId,
        orElse: () => throw Exception('Gear tidak ditemukan'),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GearDetailPage(datum: gear),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka detail: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // chevinka: Handle tap pada item
  void _handleItemTap(PopularCategory item) {
    if (item.category == 'Library') {
      final sportId = _extractSportIdFromUrl(item.url);
      if (sportId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka detail sport'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _navigateToSportDetail(sportId);
    } else if (item.category == 'Gear' || item.category == 'GearGuide') {
      final gearId = _extractGearIdFromUrl(item.url);
      if (gearId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka detail gear'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _navigateToGearDetail(gearId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Container(
      decoration: BoxDecoration(
        // Background gradient halus (Merah muda ke Putih)
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF0F0),
            Colors.white,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 40 : 24,
        horizontal: isDesktop ? 48 : 16,
      ),
      // Pilih layout berdasarkan ukuran layar
      child: isDesktop
          ? _buildDesktopLayout() // Layout Kiri-Kanan (Desktop)
          : _buildMobileLayout(), // Layout Atas-Bawah (Mobile)
    );
  }

  // ===========================================================================
  // [FIX UTAMA] LAYOUT MOBILE (Vertikal: Gambar ATAS, Grid BAWAH)
  // ===========================================================================
  Widget _buildMobileLayout() {
    // Menggunakan Column menjamin elemen di bawah tidak menutupi elemen di atas
    return Column(
      children: [
        // 1. AREA GAMBAR ASSET (Ditaruh paling atas)
        SizedBox(
          height: 240, // Beri tinggi yang cukup untuk gambar
          width: double.infinity,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Dekorasi lingkaran merah di belakang gambar
              Positioned(
                bottom: 0,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA02E2E).withOpacity(0.6),
                        const Color(0xFFD65A5A).withOpacity(0.3),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              // Gambar Utama (Petenis & Api)
              // Ditaruh dalam Padding biar ga terlalu mepet atas
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Image.asset(
                  'assets/images/whatshot1.png',
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),

        // Jarak pemisah antara gambar dan grid kartu
        const SizedBox(height: 24),

        // 2. GRID KARTU (Pasti di bawah gambar)
        _buildContentGrid(isMobile: true),
      ],
    );
  }

  // ===========================================================================
  // LAYOUT DESKTOP (Horizontal: Kiri Gambar, Kanan Grid)
  // ===========================================================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bagian Kiri: Asset Gambar
        Expanded(
          flex: 5, // Porsi lebar 5/12
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              // Dekorasi lingkaran besar
              Positioned(
                left: -80,
                child: Container(
                  width: 550,
                  height: 550,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA02E2E).withOpacity(0.08),
                  ),
                ),
              ),
              // Gambar
              Image.asset(
                'assets/images/whatshot1.png',
                height: 480,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),

        // Bagian Kanan: Grid Kartu
        Expanded(
          flex: 7, // Porsi lebar 7/12
          child: Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildContentGrid(isMobile: false),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET GRID PINTAR (Menggunakan WRAP)
  // ===========================================================================
  Widget _buildContentGrid({required bool isMobile}) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFF9B2C2C))),
      );
    }

    if (_items.isEmpty) {
      return Center(child: Text('Belum ada data'));
    }

    // Menggunakan WRAP + Alignment Center
    // Ini yang bikin kalau ada 3 item, item terakhir otomatis di tengah bawah.
    return Wrap(
      spacing: 16, // Jarak horizontal antar kartu
      runSpacing: 16, // Jarak vertikal antar baris
      alignment:
          WrapAlignment.center, // KUNCI: Membuat item ganjil jadi di tengah
      children: _items.map((item) {
        // Hitung lebar kartu
        // Mobile: (Lebar Layar / 2) - Margin -> Supaya muat 2 kolom
        // Desktop: Fixed width 220
        final cardWidth =
            isMobile ? (MediaQuery.of(context).size.width / 2) - 24 : 220.0;

        return SizedBox(
          width: cardWidth,
          child: _buildHotCard(item, isMobile),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // WIDGET KARTU (Item What's Hot)
  // ===========================================================================
  Widget _buildHotCard(PopularCategory item, bool isMobile) {
    final isLibrary = item.category == 'Library';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF4CACA), // Border merah muda tipis
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B2C2C)
                .withOpacity(0.08), // Bayangan merah halus
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER KARTU (Badge & Konten) ---
            if (isLibrary) ...[
              // Badge Library
              _buildBadge(
                text: 'TRENDING • LIBRARY',
                bgColor: const Color(0xFFFFF0F0),
                textColor: const Color(0xFF9B2C2C),
              ),
              const SizedBox(height: 10),
              // Kotak Judul Library
              Container(
                width: double.infinity,
                height: 90, // Tinggi fix biar rapi sejajar
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF5F5), Color(0xFFFFEBEB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Badge Non-Library
              _buildBadge(
                text: 'TRENDING • ${item.category.toUpperCase()}',
                bgColor: const Color(0xFFFFF0F0),
                textColor: const Color(0xFF9B2C2C),
              ),
              const SizedBox(height: 10),
              // Gambar
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.image.isNotEmpty
                      ? Image.network(item.image, fit: BoxFit.cover)
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              // Judul
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // --- TOMBOL READ MORE (MERAH) ---
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () => _handleItemTap(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B2C2C), // Merah Sportpedia
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Read more',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
      {required String text,
      required Color bgColor,
      required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 9, // Font kecil agar muat di mobile
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
