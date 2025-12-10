import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../theme/app_colors.dart';
import '../../profile_app/services/profile_service.dart'; // chevinka: Import untuk fetch username

// chevinka: Ubah ke StatefulWidget untuk fetch username jika null
class GreetingSection extends StatefulWidget {
  final String? username; // chevinka: Username dari HomePage

  const GreetingSection({super.key, this.username});

  @override
  State<GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  String? _fetchedUsername; // chevinka: Username yang di-fetch dari API
  bool _isLoadingUsername = false;

  @override
  void initState() {
    super.initState();
    // chevinka: Fetch username akan dipanggil di build method via Consumer
  }

  // chevinka: Load username dari API jika widget.username null dan user logged in
  Future<void> _loadUsernameIfNeeded(CookieRequest? request) async {
    if (request == null) return;
    if (widget.username == null && request.loggedIn && !_isLoadingUsername && _fetchedUsername == null) {
      setState(() {
        _isLoadingUsername = true;
      });
      
      try {
        final profile = await ProfileService.getProfile(request);
        if (mounted && profile != null) {
          setState(() {
            _fetchedUsername = profile.username;
            _isLoadingUsername = false;
          });
        } else if (mounted) {
          setState(() {
            _isLoadingUsername = false;
          });
        }
      } catch (e) {
        // Ignore error, tetap tampilkan "Hello, User!" atau "Hello, Are you new here?"
        if (mounted) {
          setState(() {
            _isLoadingUsername = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // chevinka: Cek login status dari CookieRequest
    return Consumer<CookieRequest>(
      builder: (context, request, _) {
        final isLoggedIn = request.loggedIn;
        
        // chevinka: Fetch username jika belum ada dan user logged in
        if (widget.username == null && isLoggedIn && _fetchedUsername == null && !_isLoadingUsername) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadUsernameIfNeeded(request);
          });
        }
        
        // chevinka: Prioritaskan widget.username, lalu _fetchedUsername, lalu 'User' jika logged in
        final displayName = widget.username ?? _fetchedUsername ?? (isLoggedIn ? 'User' : null);
        
        // chevinka: Pesan greeting berdasarkan login status
        final greetingText = isLoggedIn && displayName != null
            ? 'Hello, $displayName!'
            : 'Hello, Are you new here?';

        return Container(
          // chevinka: Responsive untuk Android - diperkecil
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 16,
            vertical: MediaQuery.of(context).size.width > 1024 ? 32 : (MediaQuery.of(context).size.width > 600 ? 20 : 16),
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) {
                // Gradient dengan animasi shimmer effect
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentRedDark,
                    AppColors.accentRed,
                    AppColors.accentRedDark,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 3),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.linear,
                builder: (context, value, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment(-1.0 + value * 2, 0),
                        end: Alignment(1.0 + value * 2, 0),
                        colors: [
                          AppColors.accentRedDark,
                          AppColors.accentRed,
                          AppColors.accentRedDark,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      greetingText,
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
                        fontSize: MediaQuery.of(context).size.width > 1024 ? 26 : (MediaQuery.of(context).size.width > 600 ? 20 : 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

