import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/testimonial.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'add_testimonial_dialog.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  List<Testimonial> _testimonials = [];
  bool _isLoading = true;
  String? _error;
  String _categoryFilter = 'all';
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTestimonials();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTestimonials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final testimonials = await HomepageApiService.getTestimonials(
        request: request,
        category: _categoryFilter,
      );
      setState(() {
        _testimonials = testimonials;
        _isLoading = false;
        _currentIndex = 0;
      });
      if (_testimonials.isNotEmpty && _pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _categoryFilter = category;
    });
    _loadTestimonials();
  }

  void _showAddDialog(BuildContext context) {
    final request = context.read<CookieRequest>();
    showDialog(
      context: context,
      builder: (context) => AddTestimonialDialog(
        request: request,
        onSuccess: (testimonial) {
          _loadTestimonials();
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Testimonial testimonial) {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn || !testimonial.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Akses ditolak'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddTestimonialDialog(
        testimonial: testimonial,
        request: request,
        onSuccess: (updatedTestimonial) {
          _loadTestimonials();
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, Testimonial testimonial) async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn || !testimonial.isOwner) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Testimonial'),
        content: const Text('Yakin ingin menghapus?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HomepageApiService.deleteTestimonial(
            id: testimonial.id, request: request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Berhasil dihapus'),
              backgroundColor: Colors.green));
          _loadTestimonials();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.only(
        top: isDesktop ? 40 : 24,
        bottom: isDesktop
            ? 80
            : 60,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          // --- HEADER SECTION ---
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.primaryBlueDark, const Color(0xFF3b5998)],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'TESTIMONI',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kata mereka tentang Sportpedia',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 14 : 12,
              color: AppColors.textGrey,
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Add Testimonial
          Consumer<CookieRequest>(
            builder: (context, request, _) {
              if (request.loggedIn) {
                return ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Bagikan Ceritamu',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlueDark,
                    side:
                        BorderSide(color: AppColors.primaryBlueDark, width: 1.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                );
              }
              return Text(
                'Login untuk berbagi pengalaman.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              );
            },
          ),

          const SizedBox(height: 20),

          // --- FILTER CHIPS ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('library', 'Library'),
                const SizedBox(width: 8),
                _buildFilterChip('community', 'Community'),
                const SizedBox(width: 8),
                _buildFilterChip('gearguide', 'Gear'),
                const SizedBox(width: 8),
                _buildFilterChip('video', 'Video'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- MAIN FRAME & CAROUSEL ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlueDark.withValues(alpha: 0.05),
                  AppColors.primaryBlueDark.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.primaryBlueDark.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                if (_isLoading)
                  const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _loadTestimonials,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: const Text('Coba Lagi',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  )
                else if (_testimonials.isEmpty)
                  const SizedBox(
                    height: 150,
                    child: Center(
                        child: Text('Belum ada testimonial',
                            style: TextStyle(color: Colors.grey))),
                  )
                else
                  // chevinka: Tambah tombol navigasi kiri-kanan untuk testimonials
                  SizedBox(
                    height: isDesktop ? 420 : (isMobile ? 400 : 380),
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: _testimonials.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildTestimonialCard(
                                  _testimonials[index], isMobile),
                            );
                          },
                        ),
                        // Left navigation button
                        if (_testimonials.length > 1)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Opacity(
                                opacity: _currentIndex > 0 ? 1.0 : 0.3,
                                child: IconButton(
                                  onPressed: _currentIndex > 0
                                      ? () {
                                          _pageController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                  icon: Icon(
                                    Icons.chevron_left,
                                    size: 32,
                                    color: _currentIndex > 0
                                        ? AppColors.primaryBlueDark
                                        : Colors.grey.shade300,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    shape: const CircleBorder(),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Right navigation button
                        if (_testimonials.length > 1)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Opacity(
                                opacity: _currentIndex < _testimonials.length - 1 ? 1.0 : 0.3,
                                child: IconButton(
                                  onPressed: _currentIndex < _testimonials.length - 1
                                      ? () {
                                          _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                  icon: Icon(
                                    Icons.chevron_right,
                                    size: 32,
                                    color: _currentIndex < _testimonials.length - 1
                                        ? AppColors.primaryBlueDark
                                        : Colors.grey.shade300,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    shape: const CircleBorder(),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Indikator Titik
                if (!_isLoading && _testimonials.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _testimonials.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentIndex == index ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? AppColors.primaryBlue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category, String label) {
    final isActive = _categoryFilter == category;
    return GestureDetector(
      onTap: () => _onCategoryChanged(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? AppColors.primaryBlue : Colors.grey.shade300),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Testimonial testimonial, bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // [FIX 2] PADDING DIPERKECIL
      child: Padding(
        padding: const EdgeInsets.all(16),
        // [FIX 3] SINGLE CHILD SCROLL VIEW
        // Bungkus semua isi kartu dengan ScrollView
        // Jadi kalau kontennya panjang banget, dia bakal bisa di-scroll, GAK ERROR.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Biar ga maksa full height
            children: [
              // --- GAMBAR ---
              if (testimonial.imageUrl.isNotEmpty)
                Container(
                  // Batasi tinggi gambar maksimal 120px
                  constraints: const BoxConstraints(maxHeight: 120),
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      testimonial.imageUrl,
                      fit: BoxFit.contain, // Contain biar gambar utuh
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

              // --- QUOTE ICON ---
              Icon(Icons.format_quote,
                  color: AppColors.primaryBlue.withOpacity(0.3), size: 24),
              const SizedBox(height: 8),

              // --- TEXT TESTIMONI ---
              Text(
                testimonial.text,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
              const SizedBox(height: 16),

              // --- USER INFO & ACTIONS ---
              Row(
                children: [
                  // Avatar - chevinka: Foto testimonial hanya untuk display, bukan photo profile
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    // chevinka: Tampilkan foto dari testimonial jika ada (hanya untuk display testimonial card)
                    backgroundImage: testimonial.imageUrl.isNotEmpty
                        ? NetworkImage(testimonial.imageUrl)
                        : null,
                    child: testimonial.imageUrl.isEmpty
                        ? Text(testimonial.user[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue))
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Info User
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimonial.user,
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${testimonial.category.toUpperCase()} • ${testimonial.createdAt.split(' ')[0]}',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Action
                  Consumer<CookieRequest>(
                    builder: (context, request, _) {
                      if (testimonial.isOwner && request.loggedIn) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionButton(Icons.edit, Colors.blue,
                                () => _showEditDialog(context, testimonial)),
                            const SizedBox(width: 8),
                            _actionButton(
                                Icons.delete,
                                Colors.red,
                                () => _showDeleteConfirmation(
                                    context, testimonial)),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}