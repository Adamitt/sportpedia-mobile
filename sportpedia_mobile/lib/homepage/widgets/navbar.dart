import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../../profile_app/screens/profile_screen.dart';

// chevinka: Conditional import for web - hanya untuk web platform
// Tidak perlu untuk Android, sudah dihapus untuk avoid error

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
            // chevinka: Responsive untuk Android - kurangi padding untuk mobile
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : (MediaQuery.of(context).size.width > 600 ? 24 : 16),
              vertical: MediaQuery.of(context).size.width > 1024 ? 16 : 12,
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
                            // chevinka: Responsive logo size untuk Android
                            width: MediaQuery.of(context).size.width > 1024 ? 56 : (MediaQuery.of(context).size.width > 600 ? 48 : 40),
                            height: MediaQuery.of(context).size.width > 1024 ? 56 : (MediaQuery.of(context).size.width > 600 ? 48 : 40),
                            errorBuilder: (context, error, stackTrace) {
                              final logoSize = MediaQuery.of(context).size.width > 1024 ? 56.0 : (MediaQuery.of(context).size.width > 600 ? 48.0 : 40.0);
                              return Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'SP',
                                    style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: logoSize * 0.36, // Responsive font size
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width > 1024 ? 12 : (MediaQuery.of(context).size.width > 600 ? 10 : 8)),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins( // chevinka: Gunakan Poppins, responsive untuk Android
                                fontSize: MediaQuery.of(context).size.width > 1024 ? 24 : (MediaQuery.of(context).size.width > 600 ? 20 : 18),
                                fontWeight: FontWeight.w900,
                              ),
                              children: [
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
                            // chevinka: Responsive search bar width untuk Android
                            width: MediaQuery.of(context).size.width > 1024 ? 300 : (MediaQuery.of(context).size.width > 600 ? 250 : 200),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari olahraga, perlengkapan, atau video...',
                                hintStyle: GoogleFonts.poppins(color: AppColors.textGrey), // chevinka: Gunakan Poppins, sesuaikan color palette
                                prefixIcon: Icon(Icons.search, color: AppColors.textGrey), // chevinka: Sesuaikan color palette
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(color: AppColors.textLight), // chevinka: Sesuaikan color palette
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(color: AppColors.textLight), // chevinka: Sesuaikan color palette
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
                                  // chevinka: Untuk Android, logout cukup menggunakan CookieRequest, tidak perlu manual clear cookie
                                  await request.logout("http://localhost:8000/landingpage/api/logout/");
                                  
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Logged out successfully')),
                                    );
                                  }
                                },
                                child: Text(
                                  'Logout',
                                  style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
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
                                child: Text(
                                  'Log in',
                                  style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
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
                                child: Text(
                                  'Sign up',
                                  style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
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
            // chevinka: Responsive untuk Android
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : (MediaQuery.of(context).size.width > 600 ? 24 : 12),
              vertical: MediaQuery.of(context).size.width > 1024 ? 12 : 8,
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
        } else if (route == '/videos/') {
          // Navigate ke Video Gallery
          Navigator.pushNamed(context, '/videos');
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
            style: GoogleFonts.poppins( // chevinka: Gunakan Poppins, sesuaikan color palette
              color: AppColors.textDark, // chevinka: Pakai textDark dari color palette
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width > 1024 ? 16 : (MediaQuery.of(context).size.width > 600 ? 14 : 12), // chevinka: Responsive font size
            ),
          ),
      ),
    );
  }
}