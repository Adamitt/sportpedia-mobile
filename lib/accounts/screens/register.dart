import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:http/http.dart' as http;
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

  // Warna sesuai Login Page
  final Color _primaryDark = const Color(0xFF1C3264);
  final Color _primaryMid = const Color(0xFF2A4B97);
  final Color _primaryRed = const Color(0xFF992626);
  final Color _textGrey = const Color(0xFF6C7278);

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: -80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            // Header Text
            Positioned(
              top: screenHeight * 0.10,
              left: 28,
              right: 28,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bergabunglah\nbersama kami! 🚀',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenWidth > 360 ? 28 : 24,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Buat akun dan mulai perjalanan\nkesehatanmu hari ini.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White Card Container
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 36),

                            // Toggle Login / Sign Up
                            _buildToggleButton(context),

                            const SizedBox(height: 32),

                            // Username Field
                            _buildInputLabel('Username'),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _usernameController,
                              hint: 'Masukkan username',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username harus diisi';
                                }
                                if (value.length < 3) {
                                  return 'Username minimal 3 karakter';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Email Field
                            _buildInputLabel('Email'),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Masukkan email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email harus diisi';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            _buildInputLabel('Password'),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Masukkan password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password harus diisi';
                                }
                                if (value.length < 8) {
                                  return 'Password minimal 8 karakter';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Confirm Password Field
                            _buildInputLabel('Konfirmasi Password'),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hint: 'Masukkan ulang password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: _obscureConfirmPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi password harus diisi';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password tidak cocok';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Terms & Conditions
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToTerms = !_agreeToTerms;
                                });
                              },
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _agreeToTerms ? _primaryDark : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: _agreeToTerms
                                            ? _primaryDark
                                            : _textGrey.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: _agreeToTerms
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.poppins(
                                          color: _textGrey,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Saya setuju dengan '),
                                          TextSpan(
                                            text: 'Syarat & Ketentuan',
                                            style: GoogleFonts.poppins(
                                              color: _primaryDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Register Button
                            _buildRegisterButton(),

                            const SizedBox(height: 20),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah punya akun? ',
                                  style: GoogleFonts.poppins(
                                    color: _textGrey,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Masuk',
                                    style: GoogleFonts.poppins(
                                      color: _primaryDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
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

  Widget _buildToggleButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: Colors.transparent,
                child: Center(
                  child: Text(
                    'Log In',
                    style: GoogleFonts.poppins(
                      color: _textGrey.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: _primaryDark.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1C3264),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: _textGrey,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: _textGrey.withOpacity(0.6), size: 22),
          suffixIcon: isPassword && onToggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _textGrey.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _primaryDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _agreeToTerms
            ? LinearGradient(
                colors: [_primaryDark, _primaryMid],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: _agreeToTerms ? null : Colors.grey[300],
        boxShadow: _agreeToTerms
            ? [
                BoxShadow(
                  color: _primaryDark.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !_agreeToTerms) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Daftar Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _agreeToTerms ? Colors.white : Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showSnackBar('Anda harus menyetujui Syarat & Ketentuan', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ganti URL sesuai environment Anda (localhost/10.0.2.2)
      final response = await http.post(
        Uri.parse('http://localhost:8000/accounts/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password1': _passwordController.text,
          'password2': _confirmPasswordController.text,
        }),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSnackBar('Registrasi berhasil! Silakan login 🎉', isError: false);

          // Delay sebentar sebelum navigasi biar snackbar keliatan
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LoginPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        } else {
          String errorMessage = responseData['message'] ?? 'Registrasi gagal';
          _showSnackBar(errorMessage, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}