import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/sport.dart';

class SportFormPage extends StatefulWidget {
  final Sport? sport;
  const SportFormPage({super.key, this.sport});

  @override
  State<SportFormPage> createState() => _SportFormPageState();
}

class _SportFormPageState extends State<SportFormPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  static const String baseUrl = 'http://localhost:8000';

  String _name = "";
  String? _category;
  String? _difficulty;
  String _description = "";
  String _history = "";
  String _rulesStr = "";
  String _techniquesStr = "";
  String _benefitsStr = "";

  final List<String> _categoryOptions = ["Indoor", "Outdoor"];
  final List<String> _difficultyOptions = ["Pemula", "Menengah", "Lanjutan"];

  late AnimationController _headerController;
  late AnimationController _formController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _headerController.forward();
    _formController.forward();

    if (widget.sport != null) {
      _name = widget.sport!.name;
      _category = widget.sport!.category;
      _difficulty = widget.sport!.difficulty;
      _description = widget.sport!.description;
      _history = widget.sport!.history;
      _rulesStr = widget.sport!.rules.join(", ");
      _techniquesStr = widget.sport!.techniques.join(", ");
      _benefitsStr = widget.sport!.benefits.join(", ");
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.sport != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatedAppBar(isEdit),
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _formController,
                child: _buildFormContent(request, isEdit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar(bool isEdit) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      stretch: true,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
        title: FadeTransition(
          opacity: _headerAnimation,
          child: Text(
            isEdit ? "Edit Olahraga" : "Tambah Olahraga",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Animated circles
            Positioned(
              top: -80,
              right: -80,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Icon
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit_rounded : Icons.add_circle_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(CookieRequest request, bool isEdit) {
    return Container(
      transform: Matrix4.translationValues(0.0, -30.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Decorative line
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildAnimatedSection(
                  "Informasi Dasar",
                  Icons.info_outline_rounded,
                  0,
                  [
                    _buildTextField(
                      label: "Nama Olahraga",
                      initialValue: _name,
                      onChanged: (v) => _name = v,
                      icon: Icons.sports_rounded,
                      hint: "Contoh: Sepak Bola",
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            "Kategori",
                            _category,
                            _categoryOptions,
                            Icons.location_on_rounded,
                            (v) => setState(() => _category = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            "Kesulitan",
                            _difficulty,
                            _difficultyOptions,
                            Icons.bar_chart_rounded,
                            (v) => setState(() => _difficulty = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Deskripsi Singkat",
                      initialValue: _description,
                      onChanged: (v) => _description = v,
                      maxLines: 3,
                      icon: Icons.description_rounded,
                      hint: "Jelaskan singkat tentang olahraga ini...",
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                _buildAnimatedSection(
                  "Detail Lengkap",
                  Icons.list_alt_rounded,
                  200,
                  [
                    _buildTextField(
                      label: "Sejarah",
                      initialValue: _history,
                      onChanged: (v) => _history = v,
                      maxLines: 3,
                      icon: Icons.history_edu_rounded,
                      hint: "Ceritakan sejarah olahraga ini...",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Aturan Dasar",
                      initialValue: _rulesStr,
                      onChanged: (v) => _rulesStr = v,
                      icon: Icons.gavel_rounded,
                      hint: "Pisahkan dengan koma (,)",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Teknik Dasar",
                      initialValue: _techniquesStr,
                      onChanged: (v) => _techniquesStr = v,
                      icon: Icons.accessibility_new_rounded,
                      hint: "Pisahkan dengan koma (,)",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Manfaat",
                      initialValue: _benefitsStr,
                      onChanged: (v) => _benefitsStr = v,
                      icon: Icons.health_and_safety_rounded,
                      hint: "Pisahkan dengan koma (,)",
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final body = jsonEncode({
                              "name": _name,
                              "category": _category,
                              "difficulty": _difficulty,
                              "description": _description,
                              "history": _history,
                              "rules": _rulesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                              "techniques": _techniquesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                              "benefits": _benefitsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                            });

                            String url = "$baseUrl/sportlibrary/api/create-sport-flutter/";
                            if (isEdit) {
                              url = "$baseUrl/sportlibrary/api/edit-sport-flutter/${widget.sport!.id}/";
                            }

                            try {
                              final response = await request.postJson(url, body);
                              if (context.mounted) {
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(isEdit ? "Berhasil mengupdate!" : "Berhasil menambahkan!"),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Gagal: ${response['message']}"),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                isEdit ? "UPDATE OLAHRAGA" : "SIMPAN OLAHRAGA",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(String title, IconData icon, int delay, List<Widget> children) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E3A8A).withOpacity(0.03),
              const Color(0xFF3B82F6).withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
    IconData? icon,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: (val) => val!.isEmpty ? "$label harus diisi" : null,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: icon != null
              ? Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E3A8A).withOpacity(0.1),
                        const Color(0xFF3B82F6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Pilih $label" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E3A8A).withOpacity(0.1),
                  const Color(0xFF3B82F6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF1E3A8A)),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}