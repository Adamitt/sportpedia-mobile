import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportpedia_mobile/sport_library/models/sport.dart';
import 'package:sportpedia_mobile/sport_library/screens/sport_list.dart';

class SportFormPage extends StatefulWidget {
  final Sport? sport;
  const SportFormPage({super.key, this.sport});

  @override
  State<SportFormPage> createState() => _SportFormPageState();
}

class _SportFormPageState extends State<SportFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = "";
  String _category = "";
  String _difficulty = "";
  String _description = "";
  String _history = "";
  String _rulesStr = "";
  String _techniquesStr = "";
  String _benefitsStr = "";

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
      appBar: AppBar(
        title: Text(isEdit ? "Edit Olahraga" : "Tambah Olahraga"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: "Nama Olahraga",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) => setState(() => _name = value!),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: "Kategori (Indoor/Outdoor)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _difficulty,
                decoration: const InputDecoration(
                  labelText: "Tingkat Kesulitan",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _difficulty = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Singkat",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                onChanged: (value) => setState(() => _description = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _history,
                decoration: const InputDecoration(
                  labelText: "Sejarah",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                onChanged: (value) => setState(() => _history = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _rulesStr,
                decoration: const InputDecoration(
                  labelText: "Aturan (pisahkan dengan koma)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _rulesStr = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _techniquesStr,
                decoration: const InputDecoration(
                  labelText: "Teknik (pisahkan dengan koma)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _techniquesStr = value!),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final body = jsonEncode({
                        "name": _name,
                        "category": _category,
                        "difficulty": _difficulty,
                        "description": _description,
                        "history": _history,
                        "rules": _rulesStr.split(',').map((e) => e.trim()).toList(),
                        "techniques": _techniquesStr.split(',').map((e) => e.trim()).toList(),
                        "benefits": _benefitsStr.split(',').map((e) => e.trim()).toList(),
                      });
            
                      // Sesuaikan URL ini
                      String url = "http://127.0.0.1:8000/api/create-sport-flutter/";
                      if (isEdit) {
                          url = "http://127.0.0.1:8000/api/edit-sport-flutter/${widget.sport!.id}/";
                      }
            
                      final response = await request.postJson(url, body);
            
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menyimpan!")));
                          // Kembali ke halaman list dan hapus stack sebelumnya agar list ter-refresh
                          Navigator.pushAndRemoveUntil(
                            context, 
                            MaterialPageRoute(builder: (context) => const SportListPage()), 
                            (route) => false
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan.")));
                        }
                      }
                    }
                  },
                  child: const Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}