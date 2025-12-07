import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fotoProfilController = TextEditingController();
  final _olahragaFavoritController = TextEditingController();
  final _preferensiController = TextEditingController();

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fotoProfilController.dispose();
    _olahragaFavoritController.dispose();
    _preferensiController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      final profile = await ProfileService.getProfile(request);

      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _emailController.text = profile.email;
          _fotoProfilController.text = profile.profile.fotoProfil;
          _olahragaFavoritController.text = profile.profile.olahragaFavorit;
          _preferensiController.text = profile.profile.preferensi;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Gagal memuat data: $e', isError: true);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = context.read<CookieRequest>();

      // Update profile data
      final profileResult = await ProfileService.updateProfile(request, {
        'olahraga_favorit': _olahragaFavoritController.text.trim(),
        'preferensi': _preferensiController.text.trim(),
        'foto_profil': _fotoProfilController.text.trim(),
      });

      // Update email if changed
      if (_emailController.text.trim() != _profile?.email) {
        // Note: Email change might require password verification
        // For now, we'll handle it in profile update
      }

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        // Show dialog to enter old password
        final oldPassword = await _showOldPasswordDialog();
        if (oldPassword != null && oldPassword.isNotEmpty) {
          final passwordResult = await ProfileService.updatePassword(
            request,
            oldPassword: oldPassword,
            newPassword: _passwordController.text,
            confirmPassword: _passwordController.text,
          );

          if (!passwordResult['success']) {
            if (mounted) {
              _showSnackBar(passwordResult['message'], isError: true);
            }
            setState(() => _isSaving = false);
            return;
          }
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);

        if (profileResult['success']) {
          _showSnackBar('Perubahan berhasil disimpan!', isError: false);
          Navigator.pop(context);
        } else {
          _showSnackBar(profileResult['message'], isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    }
  }

  Future<String?> _showOldPasswordDialog() async {
    final controller = TextEditingController();
    bool obscure = true;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Verifikasi Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan password lama untuk mengubah password'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Main Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Section
                            _buildHeaderSection(),

                            // Form Section
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pengaturan Akun
                                  _buildAccountSettings(),

                                  const SizedBox(height: 24),

                                  // Pengaturan Profil
                                  _buildProfileSettings(),

                                  const SizedBox(height: 32),

                                  // Submit Button
                                  _buildSubmitButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Back Link
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Kembali ke Profil'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  _profile?.profileImage != null &&
                      _profile!.profileImage!.isNotEmpty
                  ? Image.network(
                      _profile!.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarText(),
                    )
                  : _buildAvatarText(),
            ),
          ),

          const SizedBox(height: 16),

          // Username
          Text(
            _profile?.username ?? 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            _profile?.email ?? '',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarText() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          _profile?.username.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: const Text(
            'Pengaturan Akun',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Email Field
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Masukkan email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email harus diisi';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password Field
        _buildTextField(
          controller: _passwordController,
          label: 'Password Baru (Opsional)',
          hint: 'Biarkan kosong jika tidak ingin mengubah',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey[500],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            'Gunakan password yang kuat untuk keamanan akun Anda.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: const Text(
            'Pengaturan Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Foto Profil URL
        _buildTextField(
          controller: _fotoProfilController,
          label: 'Foto Profil',
          hint: 'https://contoh.com/foto.jpg',
          icon: Icons.image_outlined,
          keyboardType: TextInputType.url,
        ),

        if (_profile?.profileImage != null &&
            _profile!.profileImage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Text(
                  'Gambar saat ini: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Expanded(
                  child: Text(
                    _profile!.profileImage!.length > 30
                        ? '${_profile!.profileImage!.substring(0, 30)}...'
                        : _profile!.profileImage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A8A),
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Olahraga Favorit
        _buildTextField(
          controller: _olahragaFavoritController,
          label: 'Olahraga Favorit',
          hint: 'cth: Badminton, Lari',
          icon: Icons.sports_soccer_outlined,
        ),

        const SizedBox(height: 16),

        // Preferensi
        _buildTextField(
          controller: _preferensiController,
          label: 'Preferensi Olahraga',
          hint: 'cth: Suka olahraga outdoor, lebih suka latihan kardio',
          icon: Icons.tune_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: maxLines > 1
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(icon, size: 20, color: Colors.grey[500]),
                  ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: maxLines > 1 ? 16 : 12,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF1E3A8A).withOpacity(0.4),
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('💾', style: TextStyle(fontSize: 18)),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
