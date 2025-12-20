import 'package:flutter/material.dart';
// TODO: Impor drawer yang sudah dibuat sebelumnya
// import 'package:sportpedia_mobile/sportforum/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportpedia_mobile/sportforum/screens/forum_entry_list.dart';
import 'package:sportpedia_mobile/config/api_config.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                'Forum Form',
              ),
            ),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),

          // // TODO: Tambahkan drawer yang sudah dibuat di sini
          // drawer: LeftDrawer(),

          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                // === Judul Forum ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Enter a catchy title...",
                      labelText: "Post Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _title = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Title cant be empty!";
                      }
                      return null;
                    },
                  ),
                ),

                // === Forum Content ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Share your thoughts, tips or questions",
                      labelText: "Post Content",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _content = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Post content cant be empty!";
                      }
                      return null;
                    },
                  ),
                ),

                // === Sport Category ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Sport Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
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
                ),

                // === Forum Tags ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "e.g., technique, equipment, training",
                      labelText: "Tags (optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
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
                ),

                // === Actions: Cancel & Create ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.indigo),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final response = await request.postJson(
                              "${ApiConfig.baseUrl}/forum/create-forum-flutter/",
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              ),
            ),
          ),
        );
    }
}