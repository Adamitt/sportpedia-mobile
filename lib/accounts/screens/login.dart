import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Deteksi Web/Mobile
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Warna Tema
  final Color _primaryDark = const Color(0xFF1C3264);
  final Color _primaryMid = const Color(0xFF2A4B97);
  final Color _primaryRed = const Color(0xFF992626);
  final Color _textGrey = const Color(0xFF6C7278);

  // --- PERBAIKAN: Base URL Otomatis ---
  final String baseUrl = kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // --- LOGIC LOGIN YANG DIPERBAIKI ---
  Future<void> _handleLogin(CookieRequest request) async {
    setState(() => _isLoading = true);

    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _isLoading = false);
      _showSnackBar('Username dan password harus diisi', isError: true);
      return;
    }

    try {
      // PERBAIKAN: Endpoint disesuaikan dengan urls.py (/accounts/api/login/)
      final response = await request.login(
        "$baseUrl/accounts/api/login/", 
        {'username': username, 'password': password},
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (request.loggedIn) {
          String message = response['message'] ?? 'Login berhasil';
          String uname = response['username'] ?? username;
          bool isStaff = response['is_staff'] ?? false;
          bool isSuperuser = response['is_superuser'] ?? false;
          bool isAdmin = isStaff || isSuperuser;

          Navigator.pushReplacementNamed(
            context,
            '/',
            arguments: {'isAdmin': isAdmin, 'username': uname},
          );

          _showSnackBar('Selamat datang, $uname! 🎉', isError: false);
        } else {
          _showSnackBar(response['message'] ?? 'Login gagal.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Pesan error lebih jelas
        _showSnackBar('Gagal terhubung ke server. Cek koneksi.', isError: true);
        debugPrint("Login Error: $e");
      }
    }
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.1, -0.3),
            end: const Alignment(1.0, 0.5),
            colors: [_primaryDark, _primaryMid, _primaryRed],
          ),
        ),
        child: Stack(
          children: [
            _buildDecorativeCircle(top: -50, right: -50, size: 200, opacity: 0.05),
            _buildDecorativeCircle(top: 100, left: -80, size: 160, opacity: 0.03),
            
            Positioned(
              top: screenHeight * 0.10,
              left: 28, right: 28,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat datang\nkembali! 👋', style: GoogleFonts.poppins(color: Colors.white, fontSize: screenWidth > 360 ? 28 : 24, height: 1.3, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('Lanjutkan perjalanan olahragamu.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: screenHeight * 0.68,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 36),
                          _buildToggleButton(context),
                          const SizedBox(height: 36),
                          _buildInputLabel('Username'), const SizedBox(height: 10),
                          _buildTextField(controller: _usernameController, hint: 'Masukkan username', icon: Icons.person_outline),
                          const SizedBox(height: 24),
                          _buildInputLabel('Password'), const SizedBox(height: 10),
                          _buildTextField(controller: _passwordController, hint: 'Masukkan password', icon: Icons.lock_outline, isPassword: true),
                          const SizedBox(height: 20),
                          _buildOptionsRow(),
                          const SizedBox(height: 36),
                          _buildLoginButton(request),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle({double? top, double? left, double? right, double? bottom, required double size, required double opacity}) {
    return Positioned(top: top, left: left, right: right, bottom: bottom, child: FadeTransition(opacity: _fadeAnimation, child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)))));
  }

  Widget _buildToggleButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(50)),
      child: Row(children: [
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))]), child: Center(child: Text('Log In', style: GoogleFonts.poppins(color: const Color(0xFF1C3264), fontWeight: FontWeight.w600))))),
        Expanded(child: GestureDetector(onTap: () => Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const RegisterPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c))), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), color: Colors.transparent, child: Center(child: Text('Sign Up', style: GoogleFonts.poppins(color: _textGrey.withOpacity(0.7), fontWeight: FontWeight.w500)))))),
      ]),
    );
  }

  Widget _buildInputLabel(String text) => Text(text, style: GoogleFonts.poppins(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w600));

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextField(
        controller: controller, obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Colors.white, prefixIcon: Icon(icon, color: _textGrey.withOpacity(0.6)),
          suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _textGrey.withOpacity(0.6)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _primaryDark, width: 2)),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(onTap: () => setState(() => _rememberMe = !_rememberMe), child: Row(children: [
        AnimatedContainer(duration: const Duration(milliseconds: 200), width: 20, height: 20, decoration: BoxDecoration(color: _rememberMe ? _primaryDark : Colors.transparent, borderRadius: BorderRadius.circular(5), border: Border.all(color: _rememberMe ? _primaryDark : _textGrey.withOpacity(0.4), width: 2)), child: _rememberMe ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
        const SizedBox(width: 8), Text('Remember me', style: GoogleFonts.poppins(color: _textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
      Text('Lupa Password?', style: GoogleFonts.poppins(color: _primaryDark, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildLoginButton(CookieRequest request) {
    return Container(
      height: 56, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: [_primaryDark, _primaryMid]), boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ElevatedButton(onPressed: _isLoading ? null : () => _handleLogin(request), style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text('Log In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
  }
}