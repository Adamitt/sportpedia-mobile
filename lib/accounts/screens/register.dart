import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import '../../config/api_config.dart';

// ===============================
// COLOR PALETTE
// ===============================
const Color primaryDark = Color(0xFF1C3264);
const Color primaryMid = Color(0xFF2A4B97);
const Color primaryRed = Color(0xFF992626);

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _hide1 = true;
  bool _hide2 = true;
  bool _loading = false;

  late AnimationController fadeCtrl;
  late AnimationController slideCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  static const String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();

    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: slideCtrl, curve: Curves.easeOutCubic),
    );

    fadeCtrl.forward();
    slideCtrl.forward();
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    slideCtrl.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // ===============================
  // SUBMIT HANDLER
  // ===============================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Gunakan CookieRequest dari provider untuk konsistensi dengan Flutter Web
      final request = context.read<CookieRequest>();
      final url = "$baseUrl/accounts/api/register/";
      print("Request ke: $url"); // Debugging log

      final response = await request.postJson(
        url,
        jsonEncode({
          "username": _username.text.trim(),
          "email": _email.text.trim(),
          "password1": _password.text,
          "password2": _confirm.text,
        }),
      );

      setState(() => _loading = false);

      // --- LOGIKA MENANGANI RESPON SERVER ---
      print("Response: $response");

      // Cek response dari server
      if (response['status'] == true || response['status'] == 'success') {
        _snack("Registrasi berhasil! Silakan login.", false);

        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.pushReplacement(context, FadeRoute(const LoginView()));
      } else {
        // Handle error dari server
        String errorMessage = "Registrasi gagal.";

        if (response['message'] != null) {
          errorMessage = response['message'];
        } else if (response['username'] != null) {
          final usernameError = response['username'];
          errorMessage = "Username: ${usernameError is List ? usernameError[0] : usernameError}";
        } else if (response['email'] != null) {
          final emailError = response['email'];
          errorMessage = "Email: ${emailError is List ? emailError[0] : emailError}";
        } else if (response['password1'] != null) {
          final passError = response['password1'];
          errorMessage = "Password: ${passError is List ? passError[0] : passError}";
        } else if (response['non_field_errors'] != null) {
          final error = response['non_field_errors'];
          errorMessage = error is List ? error[0] : error;
        }

        _snack(errorMessage, true);
      }
    } catch (e) {
      setState(() => _loading = false);
      print("Exception: $e");
      _snack("Terjadi kesalahan: $e", true);
    }
  }

  void _snack(String msg, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _background(),
          FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: _formCard(size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.1, -0.3),
          end: Alignment(1.0, 0.5),
          colors: [primaryDark, primaryMid, primaryRed],
        ),
      ),
    );
  }

  // ===============================
  // MAIN WHITE CARD
  // ===============================
  Widget _formCard(Size size) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * 0.82,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: _formFields(),
      ),
    );
  }

  // ===============================
  // FORM COMPONENTS
  // ===============================
  Widget _formFields() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(),
            const SizedBox(height: 26),
            // _illustration(),
            const SizedBox(height: 26),
            _label("Username"),
            _input(
              controller: _username,
              icon: Icons.person,
              hint: "Masukkan username",
              validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 20),
            _label("Email"),
            _input(
              controller: _email,
              icon: Icons.email,
              hint: "Masukkan email",
              keyboard: TextInputType.emailAddress,
              validator: (v) =>
                  (v != null && v.contains("@")) ? null : "Email tidak valid",
            ),
            const SizedBox(height: 20),
            _label("Password"),
            _input(
              controller: _password,
              icon: Icons.lock,
              hint: "Masukkan password",
              isPassword: true,
              obscure: _hide1,
              onToggle: () => setState(() => _hide1 = !_hide1),
            ),
            const SizedBox(height: 20),
            _label("Konfirmasi Password"),
            _input(
              controller: _confirm,
              icon: Icons.lock,
              hint: "Konfirmasi password",
              isPassword: true,
              obscure: _hide2,
              onToggle: () => setState(() => _hide2 = !_hide2),
              validator: (v) =>
                  v == _password.text ? null : "Password tidak cocok",
            ),
            const SizedBox(height: 32),
            _submitBtn(),
            const SizedBox(height: 20),
            _loginLink(),
          ],
        ),
      ),
    );
  }

  // ===============================
  // TITLE + UNDERLINE MERAH
  // ===============================
  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Sign Up",
            style: GoogleFonts.poppins(
                color: primaryDark, fontSize: 22, fontWeight: FontWeight.w700)),
        Container(
          width: 52,
          height: 3,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: primaryRed,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  // ===============================
  // MINI ILUSTRASI (sporty, clean, tanpa asset file)
// ===============================
  // Widget _illustration() {
  //   return Center(
  //     child: Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: primaryDark.withOpacity(0.10),
  //         shape: BoxShape.circle,
  //       ),
  //       child: Icon(
  //         Icons.sports_soccer,
  //         size: 42,
  //         color: primaryDark,
  //       ),
  //     ),
  //   );
  // }

  // ===============================
  // LABEL
  // ===============================
  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // ===============================
  // INPUT FIELD
  // ===============================
  Widget _input({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              keyboardType: keyboard,
              validator: validator,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    GoogleFonts.poppins(color: Colors.grey.withOpacity(0.65)),
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: onToggle,
            ),
        ],
      ),
    );
  }

  // ===============================
  // BUTTON
  // ===============================
  Widget _submitBtn() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Daftar",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ===============================
  // LOGIN LINK
  // ===============================
  Widget _loginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
        ),
        child: RichText(
          text: TextSpan(
            text: "Sudah punya akun? ",
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: "Masuk",
                style: GoogleFonts.poppins(
                  color: primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================
// PAGE TRANSITION
// ===============================
class FadeRoute extends PageRouteBuilder {
  FadeRoute(Widget page)
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        );
}
