// ===============================
// LOGIN PAGE (Sporty Bold UI)
// with FIXED LOGIN LOGIC
// ===============================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'register.dart';

// ===============================
//  COLOR PALETTE
// ===============================
const Color primaryDark = Color(0xFF1C3264);
const Color primaryMid = Color(0xFF2A4B97);
const Color primaryRed = Color(0xFF992626);

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  // Animations
  late AnimationController fadeCtrl;
  late AnimationController slideCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  final String baseUrl =
      kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000";

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
    slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: slideCtrl, curve: Curves.easeOut));

    fadeCtrl.forward();
    slideCtrl.forward();
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    slideCtrl.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // ===============================
  // FIXED LOGIN LOGIC (from your old version)
  // ===============================

  Future<void> _handleLogin(CookieRequest req) async {
    setState(() => _isLoading = true);

    String user = _username.text.trim();
    String pass = _password.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => _isLoading = false);
      _showSnack("Username dan password harus diisi", true);
      return;
    }

    try {
      final response = await req.login(
        "$baseUrl/accounts/api/login/",
        {"username": user, "password": pass},
      );

      setState(() => _isLoading = false);

      if (req.loggedIn) {
        String username = response["username"] ?? user;
        bool isStaff = response["is_staff"] ?? false;
        bool isSuperuser = response["is_superuser"] ?? false;
        bool isAdmin = isStaff || isSuperuser;

        Navigator.pushReplacementNamed(
          context,
          "/",
          arguments: {"username": username, "isAdmin": isAdmin},
        );

        _showSnack("Selamat datang, $username! 🎉", false);
      } else {
        _showSnack(response["message"] ?? "Login gagal", true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack("Gagal terhubung ke server.", true);
    }
  }

  void _showSnack(String msg, bool err) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: err ? Colors.red : Colors.green,
        content: Text(msg, style: GoogleFonts.poppins()),
      ),
    );
  }

  // ===============================
  //  UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    final req = context.watch<CookieRequest>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _backgroundGradient(),
          _hero(size),
          _card(size, req),
        ],
      ),
    );
  }

  Widget _backgroundGradient() {
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

  Widget _hero(Size size) {
    return SizedBox(
      height: size.height * 0.30,
      child: Stack(
        children: [
          Positioned(
            left: 28,
            bottom: size.height * 0.12,
            child: FadeTransition(
              opacity: fadeAnim,
              child: Text(
                "Selamat datang\nkembali 👋",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // LOGIN CARD
  // ===============================
  Widget _card(Size size, CookieRequest req) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: slideAnim,
        child: Container(
          height: size.height * 0.70,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title("Sign In"),
                const SizedBox(height: 30),
                _label("Username"),
                _inputField(_username, "Masukkan username", Icons.person),
                const SizedBox(height: 22),
                _label("Password"),
                _inputField(_password, "Masukkan password", Icons.lock,
                    isPassword: true),
                const SizedBox(height: 36),
                _loginButton(req),
                const SizedBox(height: 22),
                _registerLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shared UI Elements...

  Widget _title(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.w700, color: primaryDark)),
        Container(
          width: 52,
          height: 3,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: primaryRed,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _inputField(TextEditingController c, String hint, IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: c,
              obscureText: isPassword ? _obscure : false,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle:
                    GoogleFonts.poppins(color: Colors.grey.withOpacity(0.65)),
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                _obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
        ],
      ),
    );
  }

  Widget _loginButton(CookieRequest req) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleLogin(req),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Log In",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _registerLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterView()),
        ),
        child: RichText(
          text: TextSpan(
            text: "Belum punya akun? ",
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: "Daftar",
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