import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/popular_category.dart';
import '../services/api_service.dart';
// chevinka: Import untuk navigate ke gear detail
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
  List<Datum> _allGears = []; // chevinka: Cache semua gears untuk navigate

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadAllGears(); // chevinka: Load semua gears untuk navigate
  }

  // chevinka: Load semua gears untuk navigate ke detail
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


  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data asli dari server
      var items = await HomepageApiService.getPopularCategories(limit: 3);

      // --- TRIK CHEAT (HANYA UNTUK TESTING) ---
      // Kalau data kurang dari 3, kita duplikat item yang ada biar jadi 3.
      // Supaya kamu bisa lihat layout segitiga-nya bekerja.
      if (items.isNotEmpty && items.length < 3) {
        while (items.length < 3) {
          // Duplikat item pertama dan tambahkan ke list
          items.add(items[0]); 
        }
      }
      // ----------------------------------------

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Error handling bisa ditambahkan jika diperlukan
      print('Error loading popular categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF0F0), // Merah muda pudar di atas
            Colors.white,            // Putih di bawah
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 40 : 24,
        horizontal: isDesktop ? 48 : 16,
      ),
      // Memilih layout berdasarkan ukuran layar
      child: isDesktop 
          ? _buildDesktopLayout() // Layout Desktop (Kiri-Kanan)
          : _buildMobileLayout(), // Layout Mobile (Atas-Bawah)
    );
  }

  // --- LAYOUT MOBILE (Vertikal: Gambar Atas, Grid Bawah) ---
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // 1. Gambar Asset (Ditaruh sendiri di atas supaya TIDAK KETUTUP)
        SizedBox(
          height: 220, 
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dekorasi lingkaran di belakang gambar
              Positioned(
                bottom: 0,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA02E2E).withOpacity(0.8),
                        const Color(0xFFD65A5A).withOpacity(0.6),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              // Gambar Utama (Petenis)
              Image.asset(
                'assets/images/whatshot1.png',
                height: 210, // Sedikit lebih kecil dari containernya
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20), // Jarak antara Gambar dan Kartu

        // 2. Grid Item (Otomatis Segitiga kalau 3 item)
        _buildContentGrid(isMobile: true),
      ],
    );
  }

  // --- LAYOUT DESKTOP (Horizontal: Kiri Gambar, Kanan Grid) ---
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bagian Kiri: Asset Gambar
        Expanded(
          flex: 4,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -50,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA02E2E).withOpacity(0.1),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/whatshot1.png',
                height: 450,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        
        // Bagian Kanan: Grid
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildContentGrid(isMobile: false),
          ),
        ),
      ],
    );
  }

  // Widget Grid Pintar (Pakai WRAP)
  Widget _buildContentGrid({required bool isMobile}) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF9B2C2C))),
      );
    }
    
    if (_items.isEmpty) {
      return Center(child: Text('Belum ada data'));
    }

    // Wrap akan otomatis memindahkan item ke-3 ke tengah bawah (Segitiga)
    return Wrap(
      spacing: 16,      // Jarak antar kartu (kiri-kanan)
      runSpacing: 16,   // Jarak antar baris (atas-bawah)
      alignment: WrapAlignment.center, // KUNCI: Membuat item ganjil jadi di tengah
      children: _items.map((item) {
        // Hitung lebar kartu
        // Mobile: (Lebar Layar / 2) - Margin -> Supaya muat 2 kolom
        // Desktop: Fixed width 220
        final cardWidth = isMobile 
            ? (MediaQuery.of(context).size.width / 2) - 24 
            : 220.0;

        return SizedBox(
          width: cardWidth,
          child: _buildHotCard(item, isMobile),
        );
      }).toList(),
    );
  }

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
            color: const Color(0xFF9B2C2C).withOpacity(0.08), // Bayangan merah halus
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
            // --- HEADER KARTU ---
            if (isLibrary) ...[
               _buildBadge(
                text: 'TRENDING • LIBRARY',
                bgColor: const Color(0xFFFFF0F0),
                textColor: const Color(0xFF9B2C2C),
              ),
              const SizedBox(height: 10),
              // Kotak Judul Library
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 60,
                  maxHeight: 100, // chevinka: Flexible height untuk muat excerpt
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF5F5), Color(0xFFFFEBEB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    // chevinka: Tampilkan excerpt jika ada
                    if (item.excerpt != null && item.excerpt!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.excerpt!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Gambar Non-Library
              _buildBadge(
                text: 'TRENDING • ${item.category.toUpperCase()}',
                bgColor: const Color(0xFFFFF0F0),
                textColor: const Color(0xFF9B2C2C),
              ),
              const SizedBox(height: 10),
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
              // chevinka: Tampilkan excerpt jika ada
              if (item.excerpt != null && item.excerpt!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.excerpt!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ],

            const SizedBox(height: 12), // chevinka: Kurangi spacing karena sudah ada excerpt

            // --- TOMBOL READ MORE (MERAH) ---
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  // chevinka: Navigate berdasarkan category
                  _handleReadMore(item);
                },
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

  Widget _buildBadge({required String text, required Color bgColor, required Color textColor}) {
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

  // chevinka: Handle navigasi ketika tombol Read More diklik
  void _handleReadMore(PopularCategory item) {
    if (item.category == 'Library') {
      // Library (sport) belum tersedia di Flutter mobile
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detail "${item.title}" belum tersedia di aplikasi mobile'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Untuk gear, coba parse URL atau cari berdasarkan title
    // URL format biasanya: /gearguide/gear/{id}/ atau serupa
    if (item.url.isNotEmpty) {
      // Coba extract ID dari URL
      final uriMatch = RegExp(r'gear[/-]?(\d+)', caseSensitive: false).firstMatch(item.url);
      if (uriMatch != null) {
        final gearId = uriMatch.group(1);
        if (gearId != null) {
          _navigateToGearDetail(gearId);
          return;
        }
      }
    }

    // Fallback: Cari gear berdasarkan title
    final matchingGear = _allGears.firstWhere(
      (gear) => gear.name.toLowerCase().contains(item.title.toLowerCase()) ||
                 item.title.toLowerCase().contains(gear.name.toLowerCase()),
      orElse: () => _allGears.first, // Fallback ke gear pertama jika tidak ditemukan
    );

    if (matchingGear.id.isNotEmpty) {
      _navigateToGearDetail(matchingGear.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detail "${item.title}" tidak ditemukan'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // chevinka: Navigate ke gear detail page
  void _navigateToGearDetail(String gearId) {
    final gear = _allGears.firstWhere(
      (g) => g.id == gearId,
      orElse: () => _allGears.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GearDetailPage(datum: gear),
      ),
    );
  }
}