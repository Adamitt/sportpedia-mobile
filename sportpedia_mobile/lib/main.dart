import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accounts/screens/login.dart';
import 'accounts/screens/register.dart';
import 'profile_app/screens/profile_screen.dart';
import 'profile_app/screens/activity_history_screen.dart';
import 'profile_app/screens/account_settings_screen.dart';
import 'admin_sportpedia/screens/admin_dashboard_screen.dart';
import 'admin_sportpedia/screens/manage_admin_screen.dart';
import 'screens/gearguide_page.dart';
import 'homepage/screens/home_screen.dart';
import 'homepage/screens/search_results_page.dart'; // chevinka: route search results
import 'modules/video_gallery/screens/video_gallery_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Warna Utama Aplikasi (Sesuai Design System)
  static const Color primaryDark = Color(0xFF1C3264);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'SportPedia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryDark, // Menggunakan Biru Gelap
            primary: primaryDark,
            brightness: Brightness.light,
          ),
          // Set default text theme pakai Poppins
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
          // Mengatur warna scaffold default biar gak putih polos banget
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),

        initialRoute: '/login',

        onGenerateRoute: (settings) {
          // Route default '/' dengan argumen
          if (settings.name == '/') {
            final args = settings.arguments as Map<String, dynamic>?;

            return MaterialPageRoute(
              builder: (context) => HomePage(
                isAdmin: args?['isAdmin'] ?? false,
                username: args?['username'] ?? '',
              ),
            );
          }

          // Route switch case
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());

            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterPage());

            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());

            case '/activity-history':
              return MaterialPageRoute(
                builder: (_) => const ActivityHistoryScreen(),
              );

            case '/settings':
              return MaterialPageRoute(
                builder: (_) => const AccountSettingsScreen(),
              );

            case '/admin':
              return MaterialPageRoute(
                builder: (_) => const AdminDashboardScreen(),
              );

            case '/manage-admin':
              return MaterialPageRoute(
                builder: (_) => const ManageAdminScreen(),
              );

            case '/gearguide':
              return MaterialPageRoute(
                builder: (_) => const GearGuidePage(),
              );
            
            case '/videos':
              return MaterialPageRoute(
                builder: (_) => const VideoGalleryPage(),
              );

            // LOGIC SEARCH (Dari kode pertama)
            case '/search':
              final arguments = settings.arguments;
              if (arguments is String) {
                return MaterialPageRoute(
                  builder: (_) => SearchResultsPage(query: arguments),
                );
              }
              return MaterialPageRoute(
                builder: (_) => const SearchResultsPage(query: ''),
              );

            default:
              return MaterialPageRoute(builder: (_) => const LoginPage());
          }
        },
      ),
    );
  }
}

// ============================================================
// HOME PAGE - Modern Bottom Nav with Brand Colors
// ============================================================
class HomePage extends StatefulWidget {
  final bool isAdmin;
  final String username;

  const HomePage({
    super.key,
    this.isAdmin = false,
    this.username = '',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Design System Colors (Sesuai Login Page)
  static const Color primaryDark = Color(0xFF1C3264); // Biru Gelap
  static const Color primaryMid = Color(0xFF2A4B97);  // Biru Tengah
  static const Color primaryRed = Color(0xFF992626);  // Merah
  static const Color textGrey = Color(0xFF6C7278);

  // List Halaman untuk Bottom Navigation
  List<Widget> get _pages {
    final basePages = <Widget>[
      // Tab 0: Beranda (Menggunakan HomepageHomeScreen dari import)
      const HomepageHomeScreen(),
      
      // Tab 1: Gear Guide
      const GearGuidePage(),
      
      // Tab 2: Video Gallery (Menggunakan VideoGalleryPage dari import)
      const VideoGalleryPage(),
      
      // Tab 3: Forum (Masih Placeholder)
      const PlaceholderPage(
        title: 'Forum',
        icon: Icons.forum_rounded,
        // Gradient Merah Dominan
        gradient: LinearGradient(
          colors: [primaryRed, Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      
      // Tab 4: Profil
      const ProfileScreen(),
    ];

    if (widget.isAdmin) {
      basePages.add(const AdminDashboardScreen());
    }

    return basePages;
  }

  // Data Icon & Label untuk Bottom Navigation
  List<_NavItemData> get _navItems {
    final baseItems = <_NavItemData>[
      _NavItemData(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Beranda',
      ),
      _NavItemData(
        icon: Icons.sports_soccer_outlined,
        selectedIcon: Icons.sports_soccer_rounded,
        label: 'Gear',
      ),
      _NavItemData(
        icon: Icons.video_library_outlined,
        selectedIcon: Icons.video_library_rounded,
        label: 'Video',
      ),
      _NavItemData(
        icon: Icons.forum_outlined,
        selectedIcon: Icons.forum_rounded,
        label: 'Forum',
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Profil',
      ),
    ];

    if (widget.isAdmin) {
      baseItems.add(
        _NavItemData(
          icon: Icons.admin_panel_settings_outlined,
          selectedIcon: Icons.admin_panel_settings_rounded,
          label: 'Admin',
        ),
      );
    }

    return baseItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Menampilkan Halaman sesuai index yang dipilih
          _pages[_selectedIndex],
          
          // Modern Bottom Nav (Floating di bawah)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildModernBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: primaryDark, // Background Nav Bar Biru Gelap
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navItems.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 10 : 8),
                decoration: BoxDecoration(
                  // Indikator aktif warna Merah biar kontras dengan background Biru
                  color: isSelected ? primaryRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  // Icon putih
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// ============================================================
// PLACEHOLDER PAGE - Digunakan jika halaman belum siap
// ============================================================
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Custom Header Container
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => gradient.createShader(bounds),
                      child: Icon(
                        icon,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Coming Soon',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C3264), // Biru Gelap
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Halaman $title sedang dalam pengembangan.\nNantikan update selanjutnya! 🚀',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6C7278), // Abu-abu
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}