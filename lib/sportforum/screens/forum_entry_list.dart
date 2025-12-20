import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
// import 'package:sportpedia_mobile/widgets/left_drawer.dart';
// import 'package:sportpedia_mobile/screens/forum_detail.dart';
import 'package:sportpedia_mobile/sportforum/widgets/forum_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/sportforum/screens/forum_detail.dart';
import 'package:sportpedia_mobile/sportforum/screens/forum_edit_form.dart';
import 'package:sportpedia_mobile/sportforum/screens/forumlist_form.dart';
import 'package:sportpedia_mobile/sportforum/widgets/forum_action_button.dart';
import 'package:sportpedia_mobile/sportforum/services/forum_service.dart';
import 'package:sportpedia_mobile/config/api_config.dart';

const Map<String, String> _sportsCategory = {
  'All Sports': '',
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

class ForumEntryListPage extends StatefulWidget {
  const ForumEntryListPage({super.key, this.showOnlyMine = false});

  final bool showOnlyMine;

  @override
  State<ForumEntryListPage> createState() => ForumEntryListPageState();
}

class ForumEntryListPageState extends State<ForumEntryListPage> {
  String? _selectedSportSlug;
  final Map<String, bool> _liked = {};

  Future<List<ForumEntry>> fetchForum(pbp.CookieRequest request) async {
    // Menggunakan ApiConfig.baseUrl untuk konsistensi
    final response = await request.get('${ApiConfig.baseUrl}/forum/json/');
    
    // Decode response to json format
    var data = response;
    
    // Convert json data to ForumEntry objects
    List<ForumEntry> listForum = [];
    for (var d in data) {
      if (d != null) {
        listForum.add(ForumEntry.fromJson(d));
      }
    }
    // Optionally filter to only current user's items
    if (widget.showOnlyMine) {
      final jd = request.jsonData;
      final String? currentUsername = jd['username']?.toString();

      if (currentUsername != null) {
        final String usernameLower = currentUsername.toLowerCase();
        listForum = listForum
            .where((p) => p.author.toLowerCase() == usernameLower)
            .toList();
      }
    }

    if (_selectedSportSlug != null && _selectedSportSlug!.isNotEmpty) {
      listForum = listForum
          .where((forum) => forum.sportSlug == _selectedSportSlug)
          .toList();
    }
    return listForum;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<pbp.CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sport Forum',
          style: TextStyle(color: Colors.white),
          ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white, // back button & actions
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  dropdownColor: const Color(0xFF1E3A8A),
                  value: _selectedSportSlug?.isEmpty == true
                      ? null
                      : _selectedSportSlug,
                  hint: const Text('All Sports'),
                  items: _sportsCategory.entries
                      .map(
                        (entry) => DropdownMenuItem<String?>(
                          value: entry.value.isEmpty ? null : entry.value,
                          child: Text(entry.key, style: TextStyle(color: Colors.white,)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSportSlug = value ?? '';
                    });
                  },
                ),
            ),
          ),
        ],
      ),
      // drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchForum(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: Colors.grey,
                  ),

                  Text(
                    'No Posts Found',
                    style: TextStyle(
                      fontSize: 20, 
                      color: Color.fromRGBO(55, 65, 81, 1), 
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  SizedBox(height: 8),
                  
                  Text(
                    'Try selecting a different sport category or check back later',
                    style: TextStyle(
                      fontSize: 14, 
                      color: Color.fromRGBO(107, 114, 128, 1), 
                      ),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    widget.showOnlyMine
                        ? 'You have no Forums yet.'
                        : 'No forum available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }
              final String? currentUsername =
                  request.jsonData['username']?.toString();
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => ForumEntryCard(
                  forum: snapshot.data![index],
                  currentUsername: currentUsername,
                  userHasLiked: _liked[snapshot.data![index].id] ?? false,
                  onLike: () async {
                    try {
                      final item = snapshot.data![index] as ForumEntry;
                      final bool currentlyLiked = _liked[item.id] ?? false;
                      // Optimistically update UI count
                      setState(() {
                        _liked[item.id] = !currentlyLiked;
                        item.likes += currentlyLiked ? -1 : 1;
                      });
                      await ForumService.toggleLike(request, item.id);
                    } finally {
                      // After server responds, you could re-fetch if needed
                      // setState(() {});
                    }
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForumEditPage(
                          forum: snapshot.data![index],
                          request: request,
                        ),
                      ),
                    );
                  },
                  onDelete: () async {
                    try {
                      await ForumService.deletePost(request, snapshot.data![index].id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deleted')), 
                      );
                      setState(() {});
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Delete failed: $e')),
                      );
                    }
                  },
                  onTap: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumDetailPage(
                          forum: snapshot.data![index],
                          request: request,
                        ),
                      ),
                    );

                  },
                ),
              );
            }
          }
        },
      ),
      floatingActionButton: ForumActionButton(
        tooltip: 'Create Post',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForumFormPage()),
          );
        },
      ),
    );
  }
}

