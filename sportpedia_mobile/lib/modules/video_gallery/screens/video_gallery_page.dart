import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/video.dart';
import '../services/video_service.dart';
import 'video_detail_page.dart';
import 'admin_video_list_page.dart';

class VideoGalleryPage extends StatefulWidget {
  const VideoGalleryPage({super.key});

  @override
  State<VideoGalleryPage> createState() => _VideoGalleryPageState();
}

class _VideoGalleryPageState extends State<VideoGalleryPage> {
  late Future<List<Video>> _videosFuture;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Filter state (applied)
  int? _selectedSportId;
  String? _selectedDifficulty;
  String _sortBy = 'popular';
  
  // Temporary filter state (before applying)
  int? _tempSportId;
  String? _tempDifficulty;
  // Note: Sort is applied immediately, no temp state needed
  
  // Admin status
  bool? _isAdmin;
  
  // Color scheme - Professional & Modern
  static const Color primaryBlue = Color(0xFF1C3264);
  static const Color accentYellow = Color(0xFFFFDD78);
  static const Color bgGray = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  
  // Helper function untuk mendapatkan gradient difficulty (soft gradient)
  static LinearGradient _getDifficultyGradient(String difficulty) {
    switch (difficulty) {
      case 'Pemula':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Soft green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Menengah':
        return const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFD54F)], // Soft yellow gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Lanjutan':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // Soft blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [accentYellow, accentYellow.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  // Daftar sport & difficulty untuk dropdown
  final List<Map<String, dynamic>> _sports = [
    {'id': null, 'name': 'Semua Olahraga'},
    {'id': 1, 'name': 'Bulu Tangkis'},
    {'id': 2, 'name': 'Yoga'},
    {'id': 3, 'name': 'Tenis'},
    {'id': 4, 'name': 'Renang'},
    {'id': 5, 'name': 'Panahan'},
    {'id': 6, 'name': 'Lari'},
    {'id': 7, 'name': 'Basket'},
    {'id': 8, 'name': 'Futsal'},
    {'id': 9, 'name': 'Bersepeda'},
    {'id': 10, 'name': 'Tenis Meja'},
  ];
  
  final List<Map<String, String?>> _difficulties = [
    {'value': null, 'label': 'Semua Level'},
    {'value': 'Pemula', 'label': 'Pemula'},
    {'value': 'Menengah', 'label': 'Menengah'},
    {'value': 'Lanjutan', 'label': 'Lanjutan'},
  ];

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _checkAdminStatus();
  }
  
  Future<void> _checkAdminStatus() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    if (!request.loggedIn) {
      setState(() {
        _isAdmin = false;
      });
      return;
    }
    
    try {
      // Base URL khusus untuk modul video gallery
      final baseUrl = kIsWeb 
          ? 'http://localhost:8000' 
          : (Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000');
      
      // Use CookieRequest to get user info (handles cookies automatically)
      final response = await request.get('$baseUrl/accounts/api/user-info/');
      
      if (response is Map<String, dynamic>) {
        if (response['authenticated'] == true) {
          setState(() {
            _isAdmin = (response['is_staff'] == true) || (response['is_superuser'] == true);
          });
        } else {
          setState(() {
            _isAdmin = false;
          });
        }
      } else {
        setState(() {
          _isAdmin = false;
        });
      }
    } catch (e) {
      print('[DEBUG] Error checking admin status: $e');
      setState(() {
        _isAdmin = false;
      });
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadVideos() {
    setState(() {
      _videosFuture = VideoService.fetchVideos(
        sportId: _selectedSportId,
        difficulty: _selectedDifficulty,
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        sort: _sortBy,
      );
    });
  }
  
  void _applyFilter() {
    setState(() {
      _selectedSportId = _tempSportId;
      _selectedDifficulty = _tempDifficulty;
      // Sort is applied immediately when selected, so no need to update here
      // Reset temp values after applying
      _tempSportId = null;
      _tempDifficulty = null;
    });
    _loadVideos();
  }
  
  void _onSearchChanged(String value) {
    // Debounce search - reload after user stops typing for 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim() == value.trim()) {
        _loadVideos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      appBar: null,
      body: Stack(
        children: [
          CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section - Match Django Design (Responsive)
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;
                return Container(
                  height: isMobile ? 280 : 400,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A1628),
                        Color(0xFF0F1F3D),
                        Color(0xFF1C3264),
                        Color(0xFF2D4A7C),
                        Color(0xFF3D5A94),
                        Color(0xFF4A6BA8),
                        Color(0xFF5B7CBC),
                      ],
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=1400&q=80',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: isMobile ? 24 : 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Play Icon - Above title (Match Django) - Single Circle Only
                          Container(
                            width: isMobile ? 60 : 80,
                            height: isMobile ? 60 : 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: Size(isMobile ? 24 : 30, isMobile ? 24 : 30),
                                painter: _PlayIconPainter(primaryBlue),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 20),
                          // Title - VIDEO GALLERY
                          Text(
                            'VIDEO GALLERY',
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: isMobile ? 1.0 : 1.5,
                              fontFamily: 'Roboto',
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isMobile ? 8 : 16),
                          // Subtitle - Match Django
                          Text(
                            'Explore our collection of beginner-friendly sports tutorials',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 16,
                              color: Colors.white,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(height: isMobile ? 20 : 32),
                          // GET STARTED Button with Blue Gradient
                          InkWell(
                            onTap: () {
                              _scrollController.animateTo(
                                isMobile ? 280 : 400,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 24 : 32,
                                vertical: isMobile ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1C3264),
                                    Color(0xFF2D4A7C),
                                    Color(0xFF3D5A94),
                                    Color(0xFF4A6BA8),
                                    Color(0xFF5B7CBC),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: isMobile ? 1.0 : 1.2,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Search & Filter Section - Match Django Design (Responsive)
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;
                return Container(
                  color: bgGray,
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 20,
                    isMobile ? 20 : 32,
                    isMobile ? 16 : 20,
                    isMobile ? 16 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar - Centered, Match Django
                      StatefulBuilder(
                        builder: (context, setStateLocal) {
                          return Container(
                            margin: EdgeInsets.only(bottom: isMobile ? 16 : 24),
                            decoration: BoxDecoration(
                              color: cardWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setStateLocal(() {});
                                _onSearchChanged(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search for videos, sports, or instructors...',
                                hintStyle: TextStyle(
                                  color: textSecondary.withOpacity(0.7),
                                  fontSize: isMobile ? 14 : 15,
                                  fontFamily: 'Roboto',
                                ),
                                prefixIcon: Icon(Icons.search, color: textSecondary, size: isMobile ? 20 : 22),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: textSecondary, size: isMobile ? 18 : 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          setStateLocal(() {});
                                          _loadVideos();
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: cardWhite,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 20,
                                  vertical: isMobile ? 12 : 16,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 15,
                                fontFamily: 'Roboto',
                                color: textPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Filter Section - Responsive: Mobile shows filter button, Desktop shows all dropdowns
                      FutureBuilder<List<Video>>(
                        future: _videosFuture,
                        builder: (context, snapshot) {
                          final videoCount = snapshot.hasData ? snapshot.data!.length : 0;
                          if (isMobile) {
                            // Mobile: Show filter button + count
                            return Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _showMobileFilterSheet(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: cardWhite,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor, width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.tune, color: primaryBlue, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Filters',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '$videoCount videos',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Desktop: Show all dropdowns + apply button + count
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // All Sports Dropdown
                                    Expanded(
                                      child: _buildDropdownFilter(
                                        label: (_tempSportId ?? _selectedSportId) == null 
                                            ? 'All Sports' 
                                            : _sports.firstWhere((s) => s['id'] == (_tempSportId ?? _selectedSportId))['name'] as String,
                                        onTap: () => _showSportFilter(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Difficulty Level Dropdown
                                    Expanded(
                                      child: _buildDropdownFilter(
                                        label: (_tempDifficulty ?? _selectedDifficulty) == null 
                                            ? 'Difficulty Level' 
                                            : _difficulties.firstWhere((d) => d['value'] == (_tempDifficulty ?? _selectedDifficulty))['label'] as String,
                                        onTap: () => _showDifficultyFilter(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Most Popular Dropdown
                                    Expanded(
                                      child: _buildDropdownFilter(
                                        label: _sortBy == 'popular' ? 'Most Popular' :
                                               _sortBy == 'newest' ? 'Newest First' :
                                               _sortBy == 'rating' ? 'Highest Rating' :
                                               'Most Views',
                                        onTap: () => _showSortOptions(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Apply Filters Button with Blue Gradient
                                    InkWell(
                                      onTap: _applyFilter,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF1C3264),
                                              Color(0xFF2D4A7C),
                                              Color(0xFF3D5A94),
                                              Color(0xFF4A6BA8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryBlue.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'Apply Filters',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Video Count - Match Django
                                    Text(
                                      '$videoCount videos',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Video Grid - Professional Layout (Responsive)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width < 768 ? 16 : 20,
              8,
              MediaQuery.of(context).size.width < 768 ? 16 : 20,
              24,
            ),
            sliver: FutureBuilder<List<Video>>(
                  future: _videosFuture,
                  builder: (context, snapshot) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 768;
                    final isTablet = screenWidth >= 768 && screenWidth < 1024;
                    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
                    final childAspectRatio = isMobile ? 1.1 : (isTablet ? 0.85 : 0.75);
                    final spacing = isMobile ? 12.0 : 16.0;
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildSkeletonCard(),
                          childCount: isMobile ? 3 : 6,
                        ),
                      );
                    }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load videos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                      textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textSecondary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final videos = snapshot.data ?? [];

                if (videos.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: bgGray,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.video_library_outlined, size: 64, color: textSecondary),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No videos found',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or search criteria',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 15,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                    // Grid: Responsive columns
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final video = videos[index];
                          return _buildVideoCard(video);
                        },
                        childCount: videos.length,
                      ),
                    );
                  },
                ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
          // Floating Admin Button (only show if logged in as admin)
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<CookieRequest>(
              builder: (context, request, child) {
                // Only show admin button if user is logged in AND is admin
                if (request.loggedIn && _isAdmin == true) {
                  return FloatingActionButton.small(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminVideoListPage(),
                        ),
                      );
                      // Refresh video list when returning from admin page
                      // This ensures list is updated if videos were modified
                      _loadVideos();
                    },
                    backgroundColor: primaryBlue,
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdownFilter({required String label, required VoidCallback onTap}) {
    return Material(
      color: cardWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSportFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Sport',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _sports.map((sport) => ListTile(
                  title: Text(
                    sport['name'] as String,
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  selected: (_tempSportId ?? _selectedSportId) == sport['id'],
                  onTap: () {
                    setState(() {
                      _tempSportId = sport['id'] as int?;
                    });
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDifficultyFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Difficulty',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _difficulties.map((diff) => ListTile(
                  title: Text(
                    diff['label'] ?? 'Semua Level',
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  selected: (_tempDifficulty ?? _selectedDifficulty) == diff['value'],
                  onTap: () {
                    setState(() {
                      _tempDifficulty = diff['value'];
                    });
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: ['popular', 'newest', 'rating', 'views'].map((sort) => ListTile(
                  title: Text(
                    sort == 'popular' ? 'Most Popular' :
                    sort == 'newest' ? 'Newest First' :
                    sort == 'rating' ? 'Highest Rating' :
                    'Most Views',
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  selected: _sortBy == sort,
                  onTap: () {
                    setState(() {
                      _sortBy = sort; // Apply sort immediately
                    });
                    Navigator.pop(context);
                    _loadVideos(); // Reload videos with new sort
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Mobile filter sheet - shows all filters in one bottom sheet
  void _showMobileFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tempSportId = null;
                            _tempDifficulty = null;
                            _sortBy = 'popular';
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sport Filter
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Sport',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        children: _sports.map((sport) {
                          final isSelected = (_tempSportId ?? _selectedSportId) == sport['id'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _tempSportId = sport['id'] as int?;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sport['name'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? primaryBlue : textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check, color: primaryBlue, size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Difficulty Filter
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Difficulty Level',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        children: _difficulties.map((diff) {
                          final isSelected = (_tempDifficulty ?? _selectedDifficulty) == diff['value'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _tempDifficulty = diff['value'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      diff['label'] ?? 'Semua Level',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? primaryBlue : textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check, color: primaryBlue, size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Sort Options
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Sort By',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        children: [
                          {'value': 'popular', 'label': 'Most Popular'},
                          {'value': 'newest', 'label': 'Newest First'},
                          {'value': 'rating', 'label': 'Highest Rating'},
                          {'value': 'views', 'label': 'Most Views'},
                        ].map((sort) {
                          final isSelected = _sortBy == sort['value'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _sortBy = sort['value'] as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sort['label'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? primaryBlue : textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check, color: primaryBlue, size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Apply Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            _applyFilter();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1C3264),
                                  Color(0xFF2D4A7C),
                                  Color(0xFF3D5A94),
                                  Color(0xFF4A6BA8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
  
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: bgGray,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                          ),
                        ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  Container(height: 20, width: double.infinity, color: bgGray),
                  const SizedBox(height: 16),
                            Row(
                              children: [
                      Container(height: 24, width: 80, color: bgGray),
                                const SizedBox(width: 8),
                      Container(height: 24, width: 80, color: bgGray),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 14, width: 60, color: bgGray),
                      Container(height: 14, width: 40, color: bgGray),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVideoCard(Video video) {
    return _Animated3DCard(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoDetailPage(videoId: video.id),
            ),
          );
          // Always refresh video list when returning from detail page
          // This ensures list is updated if video was modified
          _loadVideos();
        },
      child: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardWhite,
              cardWhite.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail - Match Django: aspect-video (16:9)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(
                        color: bgGray,
                        child: Icon(Icons.video_library_outlined, size: 48, color: textSecondary),
                      ),
                    ),
                    // Duration Badge - Match Django style
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              video.duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content - Lebih besar untuk 3 kolom
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title - Lebih besar
                  SizedBox(
                    height: 40,
                    child: Text(
                      video.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        fontFamily: 'Roboto',
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Tags - Lebih besar dan jelas
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          video.sportName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: _getDifficultyGradient(video.difficulty),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getDifficultyGradient(video.difficulty).colors.first.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          video.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Instructor/Coach (if available)
                  if (video.instructor != null && video.instructor!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              video.instructor!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                                fontFamily: 'Roboto',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Tags (if available)
                  if (video.tags != null && video.tags!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: video.tags!.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: bgGray,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  // Stats - Lebih besar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined, size: 14, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${video.views}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: accentYellow),
                          const SizedBox(width: 4),
                          Text(
                            video.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 3D Animated Card Widget with depth effect
  Widget _Animated3DCard({required VoidCallback onTap, required Widget child}) {
    return _Animated3DCardStateful(
      onTap: onTap,
      child: child,
      primaryBlue: primaryBlue,
    );
  }
}

// Stateful 3D Card with animations
class _Animated3DCardStateful extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color primaryBlue;

  const _Animated3DCardStateful({
    required this.onTap,
    required this.child,
    required this.primaryBlue,
  });

  @override
  State<_Animated3DCardStateful> createState() => _Animated3DCardStatefulState();
}

class _Animated3DCardStatefulState extends State<_Animated3DCardStateful>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Deep 3D shadow layers
                  BoxShadow(
                    color: widget.primaryBlue.withOpacity(0.15 * _elevationAnimation.value),
                    blurRadius: 30 * _elevationAnimation.value,
                    offset: Offset(0, 12 * _elevationAnimation.value),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12 * _elevationAnimation.value),
                    blurRadius: 25 * _elevationAnimation.value,
                    offset: Offset(0, 8 * _elevationAnimation.value),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08 * _elevationAnimation.value),
                    blurRadius: 15 * _elevationAnimation.value,
                    offset: Offset(0, 4 * _elevationAnimation.value),
                  ),
                  // Top highlight for 3D effect
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter for Play Icon Triangle
class _PlayIconPainter extends CustomPainter {
  final Color color;
  
  _PlayIconPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    // Draw triangle pointing right
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

