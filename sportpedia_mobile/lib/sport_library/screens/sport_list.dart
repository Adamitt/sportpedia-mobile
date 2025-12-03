import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportpedia_mobile/sport_library/models/sport.dart';
import 'package:sportpedia_mobile/sport_library/screens/sport_detail.dart';
import 'package:sportpedia_mobile/sport_library/screens/sport_form.dart';

class SportListPage extends StatefulWidget {
  const SportListPage({super.key});

  @override
  State<SportListPage> createState() => _SportListPageState();
}

class _SportListPageState extends State<SportListPage> {
  Future<List<Sport>> fetchSports(CookieRequest request) async {
    // Pastikan URL sesuai dengan Django runserver kamu (biasanya 127.0.0.1:8000 atau 10.0.2.2:8000 untuk Emulator Android)
    // Gunakan http://10.0.2.2:8000/api/show-sports-json/ jika pakai Emulator Android
    final response = await request.get('http://127.0.0.1:8000/api/show-sports-json/');
    
    List<Sport> listSport = [];
    for (var d in response) {
      if (d != null) {
        listSport.add(Sport.fromJson(d));
      }
    }
    return listSport;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    bool isAdmin = true; // Hardcode dulu untuk testing

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pustaka Olahraga'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SportFormPage()),
          );
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Olahraga',
        child: const Icon(Icons.add),
      ) : null,
      body: FutureBuilder(
        future: fetchSports(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "Belum ada data olahraga.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final sport = snapshot.data![index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        child: Text(sport.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text(sport.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${sport.category} • ${sport.difficulty}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SportDetailPage(sport: sport),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}