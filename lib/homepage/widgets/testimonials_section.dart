import 'package:flutter/material.dart';
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Load testimonials after frame is built so context is available
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
      // Get CookieRequest from context to send cookies
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
          // Reload testimonials setelah berhasil add
          _loadTestimonials();
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Testimonial testimonial) {
    final request = context.read<CookieRequest>();
    
    // Double check: pastikan user sudah login
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu untuk mengedit testimonial'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Double check: pastikan ini adalah testimonial milik user
    if (!testimonial.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda hanya dapat mengedit testimonial milik Anda sendiri'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AddTestimonialDialog(
        testimonial: testimonial,
        request: request,
        onSuccess: (updatedTestimonial) {
          // Reload testimonials setelah berhasil edit
          _loadTestimonials();
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Testimonial testimonial) async {
    final request = context.read<CookieRequest>();
    
    // Double check: pastikan user sudah login
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu untuk menghapus testimonial'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Double check: pastikan ini adalah testimonial milik user
    if (!testimonial.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda hanya dapat menghapus testimonial milik Anda sendiri'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Testimonial'),
        content: const Text('Apakah Anda yakin ingin menghapus testimonial ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HomepageApiService.deleteTestimonial(
          id: testimonial.id,
          request: request,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Testimonial berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _loadTestimonials();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus testimonial: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          // Header dengan tombol Add - sesuai Django
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlueDark,
                      const Color(0xFF3b5998),
                      AppColors.primaryBlueDark,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Text(
                  'TESTIMONI',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Andalan banyak orang, bisa jadi andalanmu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              // Tombol Add - hanya show jika sudah login (sesuai Django template)
              Consumer<CookieRequest>(
                builder: (context, request, _) {
                  if (request.loggedIn) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddDialog(context),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('+ share your testimonials!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryBlueDark,
                            side: BorderSide(
                              color: AppColors.primaryBlueDark,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Show pesan "Login untuk membagikan testimonial" jika belum login
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login untuk membagikan testimonial.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filter Chips
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
                _buildFilterChip('gearguide', 'Gear Guide'),
                const SizedBox(width: 8),
                _buildFilterChip('video', 'Video'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Testimonials Frame (sesuai Django)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlueDark.withValues(alpha: 0.08),
                  AppColors.primaryBlueDark.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(76),
              border: Border.all(
                color: AppColors.primaryBlueDark.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlueDark.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                // Testimonials Carousel
                if (_isLoading)
                  const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading testimonials',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadTestimonials,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_testimonials.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    height: 300,
                    child: const Center(
                      child: Text(
                        'Belum ada testimonial',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 480,
                    child: Stack(
                      children: [
                        // Carousel
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: _testimonials.length,
                          itemBuilder: (context, index) {
                            final testimonial = _testimonials[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildTestimonialCard(testimonial),
                            );
                          },
                        ),

                        // Navigation Arrows
                        if (_testimonials.length > 1) ...[
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
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
                                      ? AppColors.primaryBlue
                                      : Colors.grey.shade300,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
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
                                      ? AppColors.primaryBlue
                                      : Colors.grey.shade300,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Page Indicators
                        if (_testimonials.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _testimonials.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == index
                                        ? AppColors.primaryBlue
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlueDark,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF0F9FF),
                  ],
                ),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        transform: Matrix4.identity()
          ..translate(0.0, isActive ? -3.0 : 0.0),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.primaryBlueDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Testimonial testimonial) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlueDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Section: Image + Quote Icon + Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Image Testimonial (jika ada)
                  if (testimonial.imageUrl.isNotEmpty)
                    Center(
                      child: Container(
                        width: 200,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            testimonial.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                    size: 36,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  if (testimonial.imageUrl.isNotEmpty) const SizedBox(height: 16),

                  // Quote Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.format_quote,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text
                  Expanded(
                    child: Text(
                      testimonial.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: testimonial.imageUrl.isNotEmpty ? 4 : 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Section: User Info + Category
            Column(
              children: [
                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // User Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        backgroundImage: testimonial.imageUrl.isNotEmpty
                            ? NetworkImage(testimonial.imageUrl)
                            : null,
                        child: testimonial.imageUrl.isEmpty
                            ? Text(
                                testimonial.user[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlueDark,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User Name & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testimonial.user,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlueDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  testimonial.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryBlueDark,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                testimonial.createdAt,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Edit/Delete buttons - hanya muncul jika isOwner DAN user sudah login
            Consumer<CookieRequest>(
              builder: (context, request, _) {
                if (testimonial.isOwner && request.loggedIn) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Edit button
                          ElevatedButton.icon(
                            onPressed: () => _showEditDialog(context, testimonial),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlueDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete button
                          OutlinedButton.icon(
                            onPressed: () => _showDeleteConfirmation(context, testimonial),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

