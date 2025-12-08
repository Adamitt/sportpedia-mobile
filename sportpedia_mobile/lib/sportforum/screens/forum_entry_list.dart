import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
// import 'package:sportpedia_mobile/widgets/left_drawer.dart';
// import 'package:sportpedia_mobile/screens/forum_detail.dart';
import 'package:sportpedia_mobile/sportforum/widgets/forum_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/sportforum/screens/forum_detail.dart';
import 'package:sportpedia_mobile/sportforum/screens/forum_edit_form.dart';

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

  Future<List<ForumEntry>> fetchForum(pbp.CookieRequest request) async {
    // TODO: Replace the URL with your app's URL and don't forget to add a trailing slash (/)!
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000
    
    final response = await request.get('http://localhost:8000/forum/json/');
    
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
        title: const Text('Forum Entry List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedSportSlug?.isEmpty == true
                      ? null
                      : _selectedSportSlug,
                  hint: const Text('All Sports'),
                  items: _sportsCategory.entries
                      .map(
                        (entry) => DropdownMenuItem<String?>(
                          value: entry.value.isEmpty ? null : entry.value,
                          child: Text(entry.key),
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
                        : 'No products available.',
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
                  onLike: () async {
                    try {
                      await request.post(
                        'http://localhost:8000/forum/post/${snapshot.data![index].id}/like',
                        {},
                      );
                    } finally {
                      setState(() {});
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
                      await request.post(
                        'http://localhost:8000/forum/post/${snapshot.data![index].id}/delete',
                        {},
                      );
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
    );
  }
}

