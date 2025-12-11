import 'package:flutter/material.dart';
import '../widgets/hero_section.dart';
import '../widgets/popular_categories_section.dart';
import '../widgets/quick_navigation_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/greeting_section.dart';
import '../widgets/simple_header.dart'; // chevinka: Header sederhana dengan search expand

class HomepageHomeScreen extends StatefulWidget {
  final String? username; // chevinka: Username untuk greeting section

  const HomepageHomeScreen({super.key, this.username});

  @override
  State<HomepageHomeScreen> createState() => _HomepageHomeScreenState();
}

class _HomepageHomeScreenState extends State<HomepageHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _quickNavKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // chevinka: Simple header dengan search button (navbar dari temen sudah di bottom nav)
            SliverToBoxAdapter(
              child: const SimpleHeader(),
            ),

          // Greeting Section - chevinka: Pass username untuk greeting dinamis
          SliverToBoxAdapter(
            child: GreetingSection(username: widget.username),
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: HeroSection(
              onGetStarted: () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent * 0.6,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),

          // Popular Categories (What's Hot)
          const SliverToBoxAdapter(
            child: PopularCategoriesSection(),
          ),

          // Quick Navigation
          SliverToBoxAdapter(
            key: _quickNavKey,
            child: const QuickNavigationSection(),
          ),

          // Testimonials
          const SliverToBoxAdapter(
            child: TestimonialsSection(),
          ),

          // Bottom padding untuk bottom navbar
          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // Ditambah untuk bottom navbar
          ),
        ],
      ),
    );
  }
}
