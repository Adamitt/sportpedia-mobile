import 'package:flutter/material.dart';
// TODO: Impor drawer yang sudah dibuat sebelumnya
// import 'package:sportpedia_mobile/sportforum/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportpedia_mobile/sportforum/screens/forum_entry_list.dart';

class ForumFormPage extends StatefulWidget {
    const ForumFormPage({super.key});

    @override
    State<ForumFormPage> createState() => ForumFormPageState();
}

class ForumFormPageState extends State<ForumFormPage> {
    
    final _formKey = GlobalKey<FormState>();
    // default forum
    String _title = "";
    String _content = "";
    String _sport = 'calisthenics'; // default slug value for dropdown
    List<String> _tags = [];
    String _tagsTemp = "";

    final Map<String, String> _sportsCategory = {
      'Bulu Tangkis': 'bulu-tangkis',
      'Yoga': 'yoga',
      'Tenis': 'tenis',
      'Renang': 'renang',
      'Panahan': 'panahan',
      'Lari': 'lari',
      'Basket': 'basket',
      'Futsal': 'futsal',
      'Bersepeda': 'bersepeda',
      'Tenis Meja': 'tenis-meja',
      'Voli': 'voli',
      'Panjat Tebing': 'panjat-tebing',
      'Muay Thai': 'muay-thai',
      'Golf': 'golf',
      'Selancar': 'selancar',
      'Pencak Silat': 'pencak-silat',
      'Baseball': 'baseball',
      'Skateboard': 'skateboard',
      'Calisthenics': 'calisthenics',
      'Wall Climbing': 'wall-climbing',
    };

    bool isUrl(String input) {
    try {
      final uri = Uri.parse(input);
      return uri.isAbsolute;
    } catch (e) {
      return false; // Parsing failed, not a valid URI
    }
  }


    @override
    Widget build(BuildContext context) {
        final request = context.watch<CookieRequest>();

        // Helper for consistent input styling
        InputDecoration inputDecoration(String label, String hint) {
          return InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB), // Gray 50
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)), // Gray 200
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2), // Blue 800
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            labelStyle: const TextStyle(color: Color(0xFF4B5563)),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Create New Post',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                const Text(
                  'Share your passion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start a discussion about your favorite sport.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
                const SizedBox(height: 32),

                // === Judul Forum ===
                TextFormField(
                  decoration: inputDecoration("Post Title", "Enter a catchy title..."),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Title can't be empty!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // === Forum Content ===
                TextFormField(
                  maxLines: 8,
                  decoration: inputDecoration("Content", "Share your thoughts, tips or questions...").copyWith(
                    alignLabelWithHint: true,
                  ),
                  style: const TextStyle(color: Color(0xFF374151)),
                  onChanged: (String? value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Post content can't be empty!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // === Sport Category ===
                DropdownButtonFormField<String>(
                  decoration: inputDecoration("Sport Category", ""),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                  dropdownColor: Colors.white,
                  initialValue: _sport,
                  items: _sportsCategory.entries
                      .map((entry) => DropdownMenuItem(
                            value: entry.value,
                            child: Text(entry.key),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sport = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // === Forum Tags ===
                TextFormField(
                  decoration: inputDecoration("Tags (Optional)", "e.g., technique, equipment (comma separated)"),
                  onChanged: (String? value) {
                    setState(() {
                      _tagsTemp = value ?? "";
                      _tags = _tagsTemp
                              .split(',')
                              .map((tag) => tag.trim())
                              .where((tag) => tag.isNotEmpty).toList();
                    });
                  },
                ),
                const SizedBox(height: 40),

                // === Actions: Cancel & Create ===
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: const Color(0xFF374151),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final response = await request.postJson(
                              "http://localhost:8000/forum/create-forum-flutter/",
                              jsonEncode({
                                "title": _title,
                                "content": _content,
                                "sport": _sport,
                                "sportSlug": _sport,
                                "tags": _tags,
                              }),
                            );
                            if (context.mounted) {
                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Post successfully created!")),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForumEntryListPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Something went wrong, please try again.")),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          "Create Post",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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
}