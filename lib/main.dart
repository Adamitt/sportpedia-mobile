import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Dari Kode 1
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportpedia_mobile/sport_library/screens/sport_list.dart';

// --- IMPORT DARI KODE 1 (Fitur Homepage, Search, Video, GearGuide) ---
import 'homepage/screens/home_screen.dart';
import 'homepage/screens/search_results_page.dart';
import 'screens/gearguide_page.dart';
import 'modules/video_gallery/screens/video_gallery_page.dart';

// --- IMPORT DARI KODE 2 (Accounts, Profile, Admin, Sport Library) ---
import 'accounts/screens/login.dart';
import 'accounts/screens/register.dart';

import 'profile_app/screens/profile_screen.dart';
import 'profile_app/screens/activity_history_screen.dart';
import 'profile_app/screens/account_settings_screen.dart';

import 'admin_sportpedia/screens/admin_dashboard_screen.dart';
import 'admin_sportpedia/screens/manage_admin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'SportPedia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Menggabungkan Warna Kode 2 dengan Font Kode 1
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(), // Font Poppins
        ),
        // Menggunakan routing logic dari Kode 2 karena lebih robust untuk arguments
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          // 1. Handle route '/' (Home dengan Arguments isAdmin & username)
          if (settings.name == '/') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => HomePage(
                isAdmin: args?['isAdmin'] ?? false,
                username: args?['username'] ?? '',
              ),
            );
          }

          // 2. Handle route '/search' (Search dengan query string) dari Kode 1
          if (settings.name == '/search') {
            final args = settings.arguments;
            String query = '';
            if (args is String) {
              query = args;
            }
            return MaterialPageRoute(
              builder: (context) => SearchResultsPage(query: query),
            );
          }

          // 3. Default Routes
          switch (settings.name) {
            // Auth
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginView());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterView());

            // Features Code 1
            case '/gearguide':
              return MaterialPageRoute(builder: (_) => const GearGuidePage());
            case '/videos':
              return MaterialPageRoute(
                  builder: (_) => const VideoGalleryPage());
            case '/sportlibrary':
              return MaterialPageRoute(
                  builder: (_) => const SportListPage(isAdmin: false));

            // Features Code 2 (Profile & Admin)
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/activity-history':
              return MaterialPageRoute(
                  builder: (_) => const ActivityHistoryScreen());
            case '/settings':
              return MaterialPageRoute(
                  builder: (_) => const AccountSettingsScreen());
            case '/admin':
              return MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen());
            case '/manage-admin':
              return MaterialPageRoute(
                  builder: (_) => const ManageAdminScreen());

            default:
              return MaterialPageRoute(builder: (_) => const LoginView());
          }
        },
      ),
    );
  }
}

// ============================================================
// MAIN HOME PAGE (Wrapper dengan Bottom Navigation Bar)
// ============================================================
class HomePage extends StatefulWidget {
  final bool isAdmin;
  final String username;

  const HomePage({super.key, this.isAdmin = false, this.username = ''});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Getter untuk list halaman agar dinamis berdasarkan isAdmin
  List<Widget> get _pages {
    final basePages = <Widget>[
      // Tab 0: Homepage (Dari Kode 1)
      HomepageHomeScreen(username: widget.username),

      // Tab 1: Sport Library (Dari Kode 2)
      SportListPage(isAdmin: widget.isAdmin),

      // Tab 2: Video Gallery (Dari Kode 1 - Menggantikan Placeholder)
      const VideoGalleryPage(),

      // Tab 3: Gear Guide (Dari Kode 1)
      const GearGuidePage(),

      // Tab 4: Forum (Modul orang lain - placeholder)
      _ForumPlaceholderPage(),

      // Tab 5: Profile (Dari Kode 2)
      const ProfileScreen(),
    ];

    // Tab 5 (Opsional): Admin Dashboard jika user adalah admin
    if (widget.isAdmin) {
      basePages.add(const AdminDashboardScreen());
    }

    return basePages;
  }

  // Getter untuk list icon navigasi
  List<NavigationDestination> get _destinations {
    final baseDestinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.sports_soccer_outlined),
        selectedIcon: Icon(Icons.sports_soccer),
        label: 'Olahraga',
      ),
      const NavigationDestination(
        icon: Icon(Icons.video_library_outlined),
        selectedIcon: Icon(Icons.video_library),
        label: 'Video',
      ),
      const NavigationDestination(
        // Menggunakan Icon Gear/Map untuk GearGuide
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        label: 'Gear', // Dipendekkan untuk menghindari overflow
      ),
      const NavigationDestination(
        icon: Icon(Icons.forum_outlined),
        selectedIcon: Icon(Icons.forum),
        label: 'Forum',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    if (widget.isAdmin) {
      baseDestinations.add(
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }

    return baseDestinations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak perlu AppBar di sini jika setiap Page sudah punya AppBar sendiri
      // Tapi body akan berganti sesuai tab yang dipilih
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _destinations,
          backgroundColor: Colors.white,
          elevation: 3,
          indicatorColor: Colors.blue.withValues(alpha: 0.2),
          height: 70, // Tambahkan height untuk spacing yang lebih baik
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

// ============================================================
// FORUM PLACEHOLDER PAGE (Modul orang lain)
// ============================================================
class _ForumPlaceholderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menggunakan asset community.png yang sama dengan explore features
            Image.asset(
              'assets/images/community.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.forum,
                  size: 80,
                  color: Colors.grey.shade400,
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Forum',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
