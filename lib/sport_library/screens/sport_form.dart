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

class _SportFormPageState extends State<SportFormPage> {
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

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.sport != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Olahraga" : "Tambah Olahraga"),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Informasi Dasar", Icons.info_outline),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: "Nama Olahraga",
                initialValue: _name,
                onChanged: (v) => _name = v,
                icon: Icons.sports,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown("Kategori", _category, _categoryOptions, (v) => setState(() => _category = v)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown("Kesulitan", _difficulty, _difficultyOptions, (v) => setState(() => _difficulty = v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: "Deskripsi Singkat",
                initialValue: _description,
                onChanged: (v) => _description = v,
                maxLines: 3,
                icon: Icons.description,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("Detail Lengkap", Icons.list_alt),
              const SizedBox(height: 16),

              _buildTextField(label: "Sejarah", initialValue: _history, onChanged: (v) => _history = v, maxLines: 3),
              const SizedBox(height: 12),
              _buildTextField(label: "Aturan (pisahkan koma)", initialValue: _rulesStr, onChanged: (v) => _rulesStr = v),
              const SizedBox(height: 12),
              _buildTextField(label: "Teknik (pisahkan koma)", initialValue: _techniquesStr, onChanged: (v) => _techniquesStr = v),
              const SizedBox(height: 12),
              _buildTextField(label: "Manfaat (pisahkan koma)", initialValue: _benefitsStr, onChanged: (v) => _benefitsStr = v),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    // ... (Logic Simpan Tetap Sama, tidak diubah) ...
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menyimpan!")));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal: ${response['message']}"))
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      }
                    }
                  },
                  child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String initialValue, required Function(String) onChanged, int maxLines = 1, IconData? icon}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (val) => val!.isEmpty ? "Harus diisi" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2)),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Pilih satu" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2)),
      ),
    );
  }
}