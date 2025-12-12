import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Import screens dari accounts
import 'accounts/screens/login.dart';
import 'accounts/screens/register.dart';

// Import screens dari profile_app
import 'profile_app/screens/profile_screen.dart';
import 'profile_app/screens/activity_history_screen.dart';
import 'profile_app/screens/account_settings_screen.dart';

// Import screens dari admin_sportpedia
import 'admin_sportpedia/screens/admin_dashboard_screen.dart';
import 'admin_sportpedia/screens/manage_admin_screen.dart';


// import screens dari sportforum
import 'sportforum/screens/forum_entry_list.dart';

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          // Route utama ("/") dengan argumen
          if (settings.name == '/') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => HomePage(
                isAdmin: args?['isAdmin'] ?? false,
                username: args?['username'] ?? '',
              ),
            );
          }

          // Route biasa
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterPage());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/forum':
            return MaterialPageRoute(builder: (_) => const ForumEntryListPage());
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
            default:
              return MaterialPageRoute(builder: (_) => const LoginPage());
          }
        },
      ),
    );
  }
}

// ============================================================
// HOME PAGE - Simple Navigation with Admin Support
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

  // Halaman-halaman di bottom nav
  List<Widget> get _pages {
    final basePages = <Widget>[
      const PlaceholderPage(title: 'Beranda', icon: Icons.home),
      const PlaceholderPage(
        title: 'Pustaka Olahraga',
        icon: Icons.sports_soccer,
      ),
      const PlaceholderPage(
        title: 'Galeri Video',
        icon: Icons.video_library,
      ),
      const ForumEntryListPage(),
      const ProfileScreen(), // modul profil
    ];

    // Kalau admin, tambahin halaman admin
    if (widget.isAdmin) {
      basePages.add(const AdminDashboardScreen());
    }

    return basePages;
  }

  // Item-item di bottom nav bar
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER PAGE - Untuk modul teman
// ============================================================
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Halaman ini masih dalam pengembangan.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
