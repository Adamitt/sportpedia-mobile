import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // Deteksi Web/Mobile
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // --- LOGIC REGISTER YANG DIPERBAIKI ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showSnackBar('Anda harus menyetujui Syarat & Ketentuan', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PERBAIKAN: Endpoint disesuaikan dengan urls.py (/accounts/api/register/)
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/api/register/'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password1': _passwordController.text,
          'password2': _confirmPasswordController.text,
        }),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSnackBar('Registrasi berhasil! Silakan login 🎉', isError: false);
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)));
          }
        } else {
          _showSnackBar(responseData['message'] ?? 'Registrasi gagal', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Gagal terhubung ke server.', isError: true);
      }
    }
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(begin: const Alignment(-0.1, -0.3), end: const Alignment(1.0, 0.5), colors: [_primaryDark, _primaryMid, _primaryRed])),
        child: Stack(
          children: [
            _buildDecorativeCircle(top: -50, right: -50, size: 200, opacity: 0.05),
            _buildDecorativeCircle(top: 80, left: -80, size: 160, opacity: 0.03),
            
            Positioned(top: MediaQuery.of(context).padding.top + 16, left: 20, child: FadeTransition(opacity: _fadeAnimation, child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context))))),

            Positioned(top: screenHeight * 0.10, left: 28, right: 28, child: FadeTransition(opacity: _fadeAnimation, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bergabunglah\nbersama kami! 🚀', style: GoogleFonts.poppins(color: Colors.white, fontSize: screenWidth > 360 ? 28 : 24, height: 1.3, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Buat akun barumu sekarang.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            ]))),

            Align(alignment: Alignment.bottomCenter, child: SlideTransition(position: _slideAnimation, child: Container(height: screenHeight * 0.70, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28.0), child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 36),
              _buildToggleButton(context),
              const SizedBox(height: 32),
              _buildInputLabel('Username'), const SizedBox(height: 10),
              _buildTextField(controller: _usernameController, hint: 'Masukkan username', icon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : (v.length < 3 ? 'Min 3 karakter' : null)),
              const SizedBox(height: 20),
              _buildInputLabel('Email'), const SizedBox(height: 10),
              _buildTextField(controller: _emailController, hint: 'Masukkan email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : (!v.contains('@') ? 'Email tidak valid' : null)),
              const SizedBox(height: 20),
              _buildInputLabel('Password'), const SizedBox(height: 10),
              _buildTextField(controller: _passwordController, hint: 'Masukkan password', icon: Icons.lock_outline, isPassword: true, obscureText: _obscurePassword, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : (v.length < 8 ? 'Min 8 karakter' : null)),
              const SizedBox(height: 20),
              _buildInputLabel('Konfirmasi Password'), const SizedBox(height: 10),
              _buildTextField(controller: _confirmPasswordController, hint: 'Ulangi password', icon: Icons.lock_outline, isPassword: true, obscureText: _obscureConfirmPassword, onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), validator: (v) => (v != _passwordController.text) ? 'Password tidak sama' : null),
              const SizedBox(height: 20),
              _buildTermsCheckbox(),
              const SizedBox(height: 32),
              _buildRegisterButton(),
              const SizedBox(height: 20),
            ]))))))),
          ],
        ),
      ),
    );
  }

  // --- Widget Helper (Sama seperti Login tapi disesuaikan) ---
  Widget _buildDecorativeCircle({double? top, double? left, double? right, double? bottom, required double size, required double opacity}) {
    return Positioned(top: top, left: left, right: right, bottom: bottom, child: FadeTransition(opacity: _fadeAnimation, child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)))));
  }

  Widget _buildToggleButton(BuildContext context) {
    return Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(50)), child: Row(children: [
      Expanded(child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), color: Colors.transparent, child: Center(child: Text('Log In', style: GoogleFonts.poppins(color: _textGrey.withOpacity(0.7), fontWeight: FontWeight.w500)))))),
      Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))]), child: Center(child: Text('Sign Up', style: GoogleFonts.poppins(color: const Color(0xFF1C3264), fontWeight: FontWeight.w600))))),
    ]));
  }

  Widget _buildInputLabel(String text) => Text(text, style: GoogleFonts.poppins(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w600));

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]), child: TextFormField(controller: controller, obscureText: isPassword ? obscureText : false, keyboardType: keyboardType, validator: validator, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, prefixIcon: Icon(icon, color: _textGrey.withOpacity(0.6)), suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _textGrey.withOpacity(0.6)), onPressed: onToggleVisibility) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _primaryDark, width: 2)))));
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(onTap: () => setState(() => _agreeToTerms = !_agreeToTerms), child: Row(children: [
      AnimatedContainer(duration: const Duration(milliseconds: 200), width: 24, height: 24, decoration: BoxDecoration(color: _agreeToTerms ? _primaryDark : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: _agreeToTerms ? _primaryDark : _textGrey.withOpacity(0.4), width: 2)), child: _agreeToTerms ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
      const SizedBox(width: 12),
      Text('Saya setuju dengan S&K', style: GoogleFonts.poppins(color: _textGrey, fontSize: 13)),
    ]));
  }

  Widget _buildRegisterButton() {
    return Container(height: 56, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: _agreeToTerms ? LinearGradient(colors: [_primaryDark, _primaryMid]) : null, color: _agreeToTerms ? null : Colors.grey[300]), child: ElevatedButton(onPressed: (_isLoading || !_agreeToTerms) ? null : _handleRegister, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Daftar Sekarang', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _agreeToTerms ? Colors.white : Colors.grey[500]))));
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
  }
}
