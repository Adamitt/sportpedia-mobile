import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../../profile_app/screens/profile_screen.dart';

class HomeNavBar extends StatefulWidget {
  const HomeNavBar({super.key});

  @override
  State<HomeNavBar> createState() => _HomeNavBarState();
}

class _HomeNavBarState extends State<HomeNavBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final results = await HomepageApiService.search(query: query);
      
      // TODO: Navigate to search results page atau show results
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Found ${results['gear_results']?.length ?? 0} gears and ${results['sport_results']?.length ?? 0} sports',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        // TODO: Navigate to search results page dengan data results
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row Atas: Logo + Menu + Search + Profile
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 24,
              vertical: 16,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    // Logo
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo1.png',
                            width: 56,
                            height: 56,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'SPORT',
                                  style: TextStyle(
                                    color: AppColors.primaryBlueDark,
                                  ),
                                ),
                                TextSpan(
                                  text: 'PEDIA',
                                  style: TextStyle(
                                    color: AppColors.accentRedDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spacer untuk push search ke tengah
                    const Spacer(),

                    // Search Bar (hidden on mobile) - sesuai logic Django
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 768) {
                          return SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari olahraga, perlengkapan, atau video...',
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onSubmitted: (query) {
                                // Navigate to gearguide dengan search query
                                if (query.trim().isNotEmpty) {
                                  Navigator.pushNamed(
                                    context,
                                    '/gearguide',
                                    arguments: {'searchQuery': query},
                                  );
                                } else {
                                  _performSearch(query);
                                }
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(width: 16),

                    // Profile Section / Auth Buttons
                    Consumer<CookieRequest>(
                      builder: (context, request, _) {
                        if (request.loggedIn) {
                          // Show profile button jika sudah login
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.person),
                                color: AppColors.primaryBlueDark,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Logout
                                  await request.logout("http://localhost:8000/landingpage/api/logout/");
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Logged out successfully')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: AppColors.primaryBlueDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Show login/signup buttons jika belum login
                          return Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: AppColors.primaryBlueDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlueDark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ),

          // Row Bawah: Menu Navigasi
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 24,
              vertical: 12,
            ),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Menu Links - centered
                      _buildBottomNavLink(context, 'Sports Library', '/sportlibrary/'),
                      const SizedBox(width: 40),
                      _buildBottomNavLink(context, 'Community', '/community/'),
                      const SizedBox(width: 40),
                      _buildBottomNavLink(context, 'Gear Guide', '/gearguide/'),
                      const SizedBox(width: 40),
                      _buildBottomNavLink(context, 'Video Gallery', '/videos/'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavLink(BuildContext context, String label, String route) {
    // TODO: Check if current route matches to set active state
    return InkWell(
      onTap: () {
        if (route == '/gearguide/') {
          Navigator.pushNamed(context, '/gearguide');
        } else {
          // Untuk route lain, show coming soon
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label page coming soon'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(
              color: Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}