
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
import 'package:sportpedia_mobile/sportforum/screens/forum_entry_list.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    labelText: 'Post Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _title = v),
                  validator: (v) => (v == null || v.isEmpty) ? 'Title cannot be empty' : null,
                ),
                const SizedBox(height: 12),

                // Content
                TextFormField(
                  initialValue: _content,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Post Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _content = v),
                  validator: (v) => (v == null || v.isEmpty) ? 'Content cannot be empty' : null,
                ),
                const SizedBox(height: 12),

                // Sport
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sport Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _sportSlug,
                  items: _sportsCategory.entries
                      .map((e) => DropdownMenuItem<String>(value: e.value, child: Text(e.key)))
                      .toList(),
                  onChanged: (v) => setState(() => _sportSlug = v ?? _sportSlug),
                ),
                const SizedBox(height: 12),

                // Tags
                TextFormField(
                  initialValue: _tagsInput,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _tagsInput = v;
                      _tags = v.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Actions: Cancel & Update
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.indigo),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final url = 'http://localhost:8000/forum/post/${widget.forum.id}/edit';
                        final payload = {
                          'sport': _sportSlug,
                          'title': _title,
                          'content': _content,
                          'tags': _tags.join(', '),
                        };
                        try {
                          await widget.request.post(url, payload);
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
                      child: const Text('Update Post', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
