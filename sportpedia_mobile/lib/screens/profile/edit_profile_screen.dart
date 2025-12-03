// Screen untuk Edit Profil
// Menerapkan berbagai jenis input widgets dan event handling

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../models/user_profile.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ============================================================
  // CONTROLLERS UNTUK INPUT WIDGETS
  // ============================================================
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _olahragaFavoritController;
  late TextEditingController _preferensiController;
  late TextEditingController _fotoProfilController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controllers dengan data existing
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _olahragaFavoritController = TextEditingController(
      text: widget.profile.profile.olahragaFavorit,
    );
    _preferensiController = TextEditingController(
      text: widget.profile.profile.preferensi,
    );
    _fotoProfilController = TextEditingController(
      text: widget.profile.profile.fotoProfil,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _olahragaFavoritController.dispose();
    _preferensiController.dispose();
    _fotoProfilController.dispose();
    super.dispose();
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  // Handler untuk submit form
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();

      // Data yang akan dikirim ke server Django
      final profileData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'olahraga_favorit': _olahragaFavoritController.text,
        'preferensi': _preferensiController.text,
        'foto_profil': _fotoProfilController.text,
      };

      // ============================================================
      // PEMANGGILAN ASYNC KE WEB SERVICE DJANGO
      // ============================================================
      final result = await ProfileService.updateProfile(request, profileData);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memperbarui profil'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Save button di AppBar
          TextButton(
            onPressed: _isLoading ? null : _onSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ============================================================
            // LAYOUT WIDGET - Profile Picture Section
            // ============================================================
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundImage:
                        widget.profile.profileImage != null &&
                            widget.profile.profileImage!.isNotEmpty
                        ? NetworkImage(widget.profile.profileImage!)
                        : null,
                    child:
                        widget.profile.profileImage == null ||
                            widget.profile.profileImage!.isEmpty
                        ? Text(
                            widget.profile.username
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Show dialog to enter URL
                        _showPhotoUrlDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ============================================================
            // INPUT WIDGETS - Text Fields
            // ============================================================

            // Nama Depan
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Nama Depan',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Nama Belakang
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Nama Belakang',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // ============================================================
            // INPUT WIDGET - Olahraga Favorit
            // ============================================================
            TextFormField(
              controller: _olahragaFavoritController,
              decoration: InputDecoration(
                labelText: 'Olahraga Favorit',
                hintText: 'Contoh: Sepak Bola, Basket, Badminton',
                prefixIcon: const Icon(Icons.sports_soccer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // INPUT WIDGET - TextFormField dengan multiline (Preferensi/Bio)
            // ============================================================
            TextFormField(
              controller: _preferensiController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Preferensi / Bio',
                hintText: 'Ceritakan tentang preferensi olahraga Anda...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.info_outline),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // INPUT WIDGET - URL Foto Profil
            // ============================================================
            TextFormField(
              controller: _fotoProfilController,
              decoration: InputDecoration(
                labelText: 'URL Foto Profil',
                hintText: 'https://example.com/photo.jpg',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 32),

            // ============================================================
            // BUTTON - Submit
            // ============================================================
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showPhotoUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL Foto Profil'),
        content: TextField(
          controller: _fotoProfilController,
          decoration: const InputDecoration(
            hintText: 'Masukkan URL foto profil',
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Refresh UI
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
