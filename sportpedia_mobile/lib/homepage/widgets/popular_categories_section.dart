import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import '../models/popular_category.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

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
      final items = await HomepageApiService.getPopularCategories(limit: 3);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.whatsHotBackgroundGradient,
      ),
      padding: EdgeInsets.symmetric(
        // chevinka: Responsive untuk Android - kurangi padding untuk mobile
        vertical: MediaQuery.of(context).size.width > 1024 ? 48 : 32,
        horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : (MediaQuery.of(context).size.width > 600 ? 24 : 16),
      ),
      margin: const EdgeInsets.only(top: 60),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dekorasi whatshot1.png - di belakang konten
          Positioned(
            left: -200,
            top: -120,
            child: IgnorePointer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gambar asset
                  Opacity(
                    opacity: 0.6,
                    child: SizedBox(
                      width: 700,
                      height: 380,
                      child: Image.asset(
                        'assets/images/whatshot1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  // Grafis merah tipis di sebelah kanan gambar (tidak menimpa)
                  // Posisi di sebelah kanan setelah gambar asset selesai (offset 60px ke kanan)
                  Transform.translate(
                    offset: const Offset(60, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Garis merah vertikal tipis
                        Container(
                          width: 2,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.accentRed.withValues(alpha: 0.1),
                                AppColors.accentRed.withValues(alpha: 0.4),
                                AppColors.accentRedDark.withValues(alpha: 0.6),
                                AppColors.accentRed.withValues(alpha: 0.4),
                                AppColors.accentRed.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Garis merah horizontal tipis
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.accentRed.withValues(alpha: 0.2),
                                AppColors.accentRed.withValues(alpha: 0.5),
                                AppColors.accentRedDark.withValues(alpha: 0.7),
                                AppColors.accentRed.withValues(alpha: 0.5),
                                AppColors.accentRed.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              // chevinka: Responsive untuk Android - sesuaikan left padding untuk mobile
              left: MediaQuery.of(context).size.width > 1024 ? 400 : (MediaQuery.of(context).size.width > 600 ? 200 : 0),
              right: MediaQuery.of(context).size.width > 1024 ? 48 : (MediaQuery.of(context).size.width > 600 ? 16 : 8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                if (_isLoading)
                  const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading popular categories',
                            style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadItems,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Belum ada data What\'s Hot',
                        style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 1024 ? 0 : 8,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // chevinka: Responsive untuk Android - 1 kolom di mobile kecil
                        crossAxisCount: MediaQuery.of(context).size.width > 1024 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                        crossAxisSpacing: MediaQuery.of(context).size.width > 1024 ? 24 : (MediaQuery.of(context).size.width > 600 ? 16 : 12),
                        mainAxisSpacing: MediaQuery.of(context).size.width > 1024 ? 24 : (MediaQuery.of(context).size.width > 600 ? 16 : 12),
                        // chevinka: childAspectRatio disesuaikan untuk Android
                        childAspectRatio: MediaQuery.of(context).size.width > 1024 ? 0.7 : (MediaQuery.of(context).size.width > 600 ? 0.75 : 0.9),
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _buildHotCard(item);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotCard(PopularCategory item) {
    final isLibrary = item.category == 'Library';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to detail page
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // chevinka: Fix overflow dengan min size
                children: [
                  if (isLibrary) ...[
                    // Badge dengan styling sesuai Django
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFDECEC),
                            Color(0xFFFFD5D5),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFFF4CACA), width: 1),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B2C2C).withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Trending • Library',
                        style: GoogleFonts.poppins( // chevinka: Gunakan Poppins seperti angie
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color(0xFF9B2C2C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Text mode container dengan shimmer background
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFF5F5),
                              Color(0xFFFFE8E8),
                              Color(0xFFFFD8D8),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.accentRed.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible( // chevinka: Fix overflow dengan Flexible
                                child: Text(
                                  item.title,
                                  style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    height: 1.25,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.excerpt != null && item.excerpt!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Flexible( // chevinka: Fix overflow dengan Flexible
                                  child: Text(
                                    item.excerpt!,
                                    style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                                      fontSize: 12,
                                      color: const Color(0xFF4B5563),
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Container(
                        height: 224, // 14rem = 224px
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: item.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  item.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.image),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.image,
                                    color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Trending • ${item.category}',
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Button dengan gradient merah sesuai Django
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentRed,
                            AppColors.accentRedDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentRed.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'Read more',
                        style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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
}

