
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
import 'package:sportpedia_mobile/sportforum/screens/forum_entry_list.dart';
import 'package:sportpedia_mobile/sportforum/services/forum_service.dart';

class ForumEditPage extends StatefulWidget {
  const ForumEditPage({super.key, required this.forum, required this.request});

  final ForumEntry forum;
  final pbp.CookieRequest request;

  @override
  State<ForumEditPage> createState() => _ForumEditPageState();
}

class _ForumEditPageState extends State<ForumEditPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title = widget.forum.title;
  late String _content = widget.forum.content;
  late String _sportSlug = widget.forum.sportSlug;
  late List<String> _tags = widget.forum.tags;
  String _tagsInput = '';

  final Map<String, String> _sportsCategory = const {
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

  @override
  void initState() {
    super.initState();
    _tagsInput = _tags.join(', ');
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Edit Post', style: TextStyle(fontWeight: FontWeight.bold)),
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
            children: [
              const Text(
                'Edit your post',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Make changes to your discussion thread.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Title
              TextFormField(
                initialValue: _title,
                decoration: inputDecoration("Post Title", "Enter a catchy title..."),
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                onChanged: (v) => setState(() => _title = v),
                validator: (v) => (v == null || v.isEmpty) ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 20),

              // Content
              TextFormField(
                initialValue: _content,
                maxLines: 8,
                decoration: inputDecoration("Post Content", "Share your thoughts...").copyWith(
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(color: Color(0xFF374151)),
                onChanged: (v) => setState(() => _content = v),
                validator: (v) => (v == null || v.isEmpty) ? 'Content cannot be empty' : null,
              ),
              const SizedBox(height: 20),

              // Sport
              DropdownButtonFormField<String>(
                decoration: inputDecoration("Sport Category", ""),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                dropdownColor: Colors.white,
                value: _sportSlug,
                items: _sportsCategory.entries
                    .map((e) => DropdownMenuItem<String>(value: e.value, child: Text(e.key)))
                    .toList(),
                onChanged: (v) => setState(() => _sportSlug = v ?? _sportSlug),
              ),
              const SizedBox(height: 20),

              // Tags
              TextFormField(
                initialValue: _tagsInput,
                decoration: inputDecoration("Tags (Optional)", "e.g., technique, equipment (comma separated)"),
                onChanged: (v) {
                  setState(() {
                    _tagsInput = v;
                    _tags = v.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                  });
                },
              ),

              const SizedBox(height: 40),

              // Actions: Cancel & Update
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                        if (!_formKey.currentState!.validate()) return;
                        final payload = {
                          'sport': _sportSlug,
                          'title': _title,
                          'content': _content,
                          'tags': _tags.join(', '),
                        };
                        try {
                          await ForumService.updatePost(widget.request, widget.forum.id, payload);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post updated successfully!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const ForumEntryListPage()),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Update failed: $e')),
                          );
                        }
                      },
                      child: const Text('Update Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
