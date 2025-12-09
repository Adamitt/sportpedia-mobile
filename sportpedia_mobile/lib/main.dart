import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'homepage/screens/home_screen.dart';
import 'homepage/screens/search_results_page.dart';
import 'accounts/screens/login.dart';
import 'accounts/screens/register.dart';
import 'screens/gearguide_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Sportpedia Mobile',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const HomepageHomeScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          // TAMBAHAN: Route search results page (mirip Django search page)
          '/search': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            if (arguments is String) {
              return SearchResultsPage(query: arguments);
            }
            return const SearchResultsPage(query: '');
          },
          '/gearguide': (context) => const GearGuidePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
