import 'package:flutter/material.dart';
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
    _loadTestimonials();
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
      final testimonials =
          await HomepageApiService.getTestimonials(category: _categoryFilter);
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
    showDialog(
      context: context,
      builder: (context) => AddTestimonialDialog(
        onSuccess: (testimonial) {
          // Reload testimonials setelah berhasil add
          _loadTestimonials();
        },
      ),
    );
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
              // Tombol Add
              Row(
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
                    height: 400,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryBlueDark.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlueDark.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: testimonial.imageUrl.isNotEmpty
                  ? NetworkImage(testimonial.imageUrl)
                  : null,
              child: testimonial.imageUrl.isEmpty
                  ? Text(
                      testimonial.user[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              testimonial.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Text
            Expanded(
              child: Text(
                testimonial.text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  testimonial.user,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  testimonial.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              testimonial.createdAt,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

