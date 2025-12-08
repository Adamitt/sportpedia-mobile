import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';
import '../models/activity_history.dart';
import '../services/profile_service.dart';
import 'activity_history_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<ActivityHistory> _recentActivities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = context.read<CookieRequest>();

      final results = await Future.wait([
        ProfileService.getProfile(request),
        ProfileService.getActivityHistory(request, limit: 10),
      ]);

      if (!mounted) return;

      setState(() {
        _profile = results[0] as UserProfile?;
        _recentActivities = results[1] as List<ActivityHistory>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data profil';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final request = context.read<CookieRequest>();
      await request.logout('http://localhost:8000/accounts/api/logout/');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _clearActivityHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 12),
            Text('Hapus Riwayat'),
          ],
        ),
        content: const Text(
          'Anda yakin ingin menghapus SEMUA riwayat aktivitas? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final request = context.read<CookieRequest>();
      final result = await ProfileService.clearActivityHistory(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Riwayat dihapus'),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
        _loadProfileData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfileData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorWidget()
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: _buildProfileContent(),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProfileData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header Profil
          _buildProfileHeader(),

          const SizedBox(height: 16),

          // Informasi Dasar
          _buildInfoSection(),

          const SizedBox(height: 16),

          // Riwayat Aktivitas
          _buildActivitySection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
            ),

            const SizedBox(height: 16),

            // Username
            Text(
              _profile?.username ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              _profile?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          _profile?.username.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              const Row(
                children: [
                  Text('🧭', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Informasi Dasar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Olahraga Favorit
              _buildInfoRow(
                'Olahraga Favorit',
                _profile?.profile.olahragaFavorit.isNotEmpty == true
                    ? _profile!.profile.olahragaFavorit
                    : 'Belum diatur',
              ),

              const SizedBox(height: 12),

              // Preferensi
              _buildInfoRow(
                'Preferensi',
                _profile?.profile.preferensi.isNotEmpty == true
                    ? _profile!.profile.preferensi
                    : 'Belum ada preferensi',
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  // Pengaturan Akun
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsScreen(),
                          ),
                        ).then((_) => _loadProfileData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Text('⚙️', style: TextStyle(fontSize: 16)),
                      label: const Text('Pengaturan'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Logout
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      icon: const Text('🚪', style: TextStyle(fontSize: 16)),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🕓', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'Riwayat Aktivitas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),

                  // Clear All Button
                  if (_recentActivities.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearActivityHistory,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        backgroundColor: Colors.red[50],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text(
                        'Hapus Semua',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Activity List
              if (_recentActivities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada aktivitas yang tercatat.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentActivities.length > 5
                      ? 5
                      : _recentActivities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final activity = _recentActivities[index];
                    return _buildActivityCard(activity);
                  },
                ),

              // View All Button
              if (_recentActivities.length > 5) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActivityHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua Aktivitas →'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityHistory activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            activity.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          // Timestamp
          Text(
            activity.formattedDate,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
