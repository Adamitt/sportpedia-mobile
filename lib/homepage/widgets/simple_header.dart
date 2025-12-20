import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../theme/app_colors.dart';
import '../../profile_app/services/profile_service.dart'; // chevinka: Import untuk fetch username

// chevinka: Simple header dengan search button yang expand on tap
class SimpleHeader extends StatefulWidget {
  const SimpleHeader({super.key});

  @override
  State<SimpleHeader> createState() => _SimpleHeaderState();
}

class _SimpleHeaderState extends State<SimpleHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    
    // chevinka: Debug log
    print('[DEBUG] Performing search with query: $trimmedQuery');
    
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchExpanded = false;
      _searchController.clear();
    });
    
    // chevinka: Add delay untuk ensure state updated
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/search',
          arguments: trimmedQuery,
        ).then((_) {
          // Reset search bar setelah kembali
          if (mounted) {
            _searchController.clear();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 1024 ? 24 : 16,
        vertical: MediaQuery.of(context).size.width > 1024 ? 16 : 12,
      ),
      child: Row(
        children: [
          // Logo - chevinka: Expanded untuk avoid overflow
          if (!_isSearchExpanded)
            Expanded(
              child: InkWell(
                onTap: () async {
                  // chevinka: Fetch username dan isAdmin sebelum navigate untuk pass ke homepage
                  final navigator = Navigator.of(context);
                  final request = Provider.of<CookieRequest>(context, listen: false);
                  String? username;
                  bool isAdmin = false;
                  
                  if (request.loggedIn) {
                    try {
                      final profile = await ProfileService.getProfile(request);
                      if (profile != null) {
                        username = profile.username;
                        // isAdmin = isStaff || isSuperuser (sesuai logic di login.dart)
                        isAdmin = profile.isStaff || profile.isSuperuser;
                      }
                    } catch (e) {
                      // Ignore error, tetap navigate
                    }
                  }
                  
                  // Pastikan widget masih mounted sebelum navigate
                  if (!mounted) return;
                  
                  navigator.pushReplacementNamed(
                    '/',
                    arguments: username != null 
                        ? {'username': username, 'isAdmin': isAdmin}
                        : null,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo1.png',
                      width: MediaQuery.of(context).size.width > 1024 ? 40 : 32,
                      height: MediaQuery.of(context).size.width > 1024 ? 40 : 32,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: MediaQuery.of(context).size.width > 1024 ? 40 : 32,
                          height: MediaQuery.of(context).size.width > 1024 ? 40 : 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'SP',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width > 1024 ? 16 : 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width > 1024 ? 20 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                          children: [
                            TextSpan(
                              text: 'SPORT',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryBlueDark,
                              ),
                            ),
                            TextSpan(
                              text: 'PEDIA',
                              style: GoogleFonts.poppins(
                                color: AppColors.accentRedDark,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              onTap: () {
                setState(() {
                  _isSearchExpanded = false;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textGrey,
                size: 24,
              ),
            ),
          SizedBox(width: _isSearchExpanded ? 12 : 8),
          // Search Button / Expanded Search Bar - chevinka: Expanded untuk avoid overflow
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: MediaQuery.of(context).size.width > 1024 ? 40 : 36,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // chevinka: Untuk Android, pastikan TextField bisa di-tap
                    if (!_isSearchExpanded) {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                      // Request focus setelah state update
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          _searchFocusNode.requestFocus();
                        }
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    enabled: true, // chevinka: Pastikan TextField enabled di Android
                    readOnly: !_isSearchExpanded, // chevinka: Read-only ketika belum expanded untuk better touch handling
                    autocorrect: false, // chevinka: Disable autocorrect agar tidak typo "ypga" jadi "yoga"
                    enableSuggestions: false, // chevinka: Disable suggestions
                    textCapitalization: TextCapitalization.none, // chevinka: No auto capitalization
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                      suffixIcon: _isSearchExpanded
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: AppColors.textGrey,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSearchExpanded = false;
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    onTap: () {
                      if (!_isSearchExpanded) {
                        setState(() {
                          _isSearchExpanded = true;
                        });
                        // Request focus setelah state update
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            _searchFocusNode.requestFocus();
                          }
                        });
                      }
                    },
                    onSubmitted: _performSearch,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
