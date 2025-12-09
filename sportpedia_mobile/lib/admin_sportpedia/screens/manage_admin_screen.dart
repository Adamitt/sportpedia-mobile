import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ManageAdminScreen extends StatefulWidget {
  const ManageAdminScreen({super.key});

  @override
  State<ManageAdminScreen> createState() => _ManageAdminScreenState();
}

class _ManageAdminScreenState extends State<ManageAdminScreen> {
  List<Map<String, dynamic>> _admins = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        'http://localhost:8000/admin_sportpedia/api/admins/',
      );

      if (mounted) {
        if (response['status'] == true) {
          setState(() {
            _admins = List<Map<String, dynamic>>.from(response['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Gagal memuat data';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Admin'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _loadAdmins,
                  child: _admins.isEmpty
                      ? _buildEmptyWidget()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _admins.length,
                          itemBuilder: (context, index) {
                            return _buildAdminCard(_admins[index]);
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAdminDialog(),
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label:
            const Text('Tambah Admin', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadAdmins();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan admin baru dengan tombol di bawah',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> admin) {
    final bool isCurrentUser = admin['is_current_user'] ?? false;
    final bool isSuperuser = admin['is_superuser'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSuperuser
                          ? [Colors.purple, Colors.deepPurple]
                          : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (admin['username'] as String? ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            admin['username'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Anda',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin['email'] ?? 'No email',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSuperuser ? Colors.purple[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSuperuser ? 'Super Admin' : 'Staff',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          isSuperuser ? Colors.purple[700] : Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Last login
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Last login: ${_formatDate(admin['last_login'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            if (!isCurrentUser) ...[
              const Divider(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditAdminDialog(admin),
                    icon: Icon(Icons.edit, size: 18, color: Colors.blue[600]),
                    label: Text(
                      'Edit',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(admin),
                    icon: Icon(Icons.delete, size: 18, color: Colors.red[600]),
                    label: Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddAdminDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isStaff = true;
    bool isSuperuser = false;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text('Tambah Admin Baru'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Staff'),
                  subtitle: const Text('Akses ke admin panel'),
                  value: isStaff,
                  onChanged: (value) {
                    setDialogState(() {
                      isStaff = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Super Admin'),
                  subtitle: const Text('Akses penuh ke semua fitur'),
                  value: isSuperuser,
                  onChanged: (value) {
                    setDialogState(() {
                      isSuperuser = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username dan password harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _addAdmin(
                  username: usernameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  isStaff: isStaff,
                  isSuperuser: isSuperuser,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final usernameController = TextEditingController(text: admin['username']);
    final emailController = TextEditingController(text: admin['email'] ?? '');
    final passwordController = TextEditingController();
    bool isStaff = admin['is_staff'] ?? true;
    bool isSuperuser = admin['is_superuser'] ?? false;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text('Edit Admin'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password Baru (opsional)',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Kosongkan jika tidak ingin mengubah',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Staff'),
                  subtitle: const Text('Akses ke admin panel'),
                  value: isStaff,
                  onChanged: (value) {
                    setDialogState(() {
                      isStaff = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Super Admin'),
                  subtitle: const Text('Akses penuh ke semua fitur'),
                  value: isSuperuser,
                  onChanged: (value) {
                    setDialogState(() {
                      isSuperuser = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _editAdmin(
                  adminId: admin['id'],
                  username: usernameController.text,
                  email: emailController.text,
                  password: passwordController.text.isNotEmpty
                      ? passwordController.text
                      : null,
                  isStaff: isStaff,
                  isSuperuser: isSuperuser,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Admin'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus admin "${admin['username']}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAdmin(admin['id'], admin['username']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAdmin({
    required String username,
    required String email,
    required String password,
    required bool isStaff,
    required bool isSuperuser,
  }) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        'http://localhost:8000/admin_sportpedia/api/admins/add/',
        jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'is_staff': isStaff,
          'is_superuser': isSuperuser,
        }),
      );

      if (mounted) {
        if (response['status'] == true) {
          _showSnackBar(
            response['message'] ?? 'Admin berhasil ditambahkan!',
            isError: false,
          );
          _loadAdmins();
        } else {
          _showSnackBar(
            response['message'] ?? 'Gagal menambahkan admin',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    }
  }

  Future<void> _editAdmin({
    required int adminId,
    required String username,
    required String email,
    String? password,
    required bool isStaff,
    required bool isSuperuser,
  }) async {
    final request = context.read<CookieRequest>();

    try {
      final Map<String, dynamic> data = {
        'username': username,
        'email': email,
        'is_staff': isStaff,
        'is_superuser': isSuperuser,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await request.postJson(
        'http://localhost:8000/admin_sportpedia/api/admins/edit/$adminId/',
        jsonEncode(data),
      );

      if (mounted) {
        if (response['status'] == true) {
          _showSnackBar(
            response['message'] ?? 'Admin berhasil diperbarui!',
            isError: false,
          );
          _loadAdmins();
        } else {
          _showSnackBar(
            response['message'] ?? 'Gagal memperbarui admin',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    }
  }

  Future<void> _deleteAdmin(int adminId, String username) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        'http://localhost:8000/admin_sportpedia/api/admins/delete/$adminId/',
        jsonEncode({}),
      );

      if (mounted) {
        if (response['status'] == true) {
          _showSnackBar(
            response['message'] ?? 'Admin berhasil dihapus!',
            isError: false,
          );
          _loadAdmins();
        } else {
          _showSnackBar(
            response['message'] ?? 'Gagal menghapus admin',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Belum pernah login';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

