import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      margin: const EdgeInsets.only(top: 60),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dekorasi whatshot1.png - di belakang konten
          Positioned(
            left: -160,
            top: -120,
            child: IgnorePointer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gambar asset
                  Opacity(
                    opacity: 0.8,
                    child: SizedBox(
                      width: 860.649,
                      height: 460,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header - sesuai Django, tidak ada tombol add (read-only dari ViewCounter)
              const SizedBox(height: 20),

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
                          style: TextStyle(color: Colors.red.shade700),
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
                  child: const Center(
                    child: Text(
                      'Belum ada data What\'s Hot',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
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
                        style: TextStyle(
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
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                  height: 1.25,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.excerpt != null && item.excerpt!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  item.excerpt!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4B5563),
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
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
                      style: TextStyle(
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
                      style: const TextStyle(
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
                      child: const Text(
                        'Read more',
                        style: TextStyle(
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

