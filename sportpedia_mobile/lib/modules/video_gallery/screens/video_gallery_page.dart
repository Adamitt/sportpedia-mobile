import 'package:flutter/material.dart';

import '../models/video.dart';
import '../services/video_service.dart';
import 'video_detail_page.dart';

class VideoGalleryPage extends StatefulWidget {
  const VideoGalleryPage({super.key});

  @override
  State<VideoGalleryPage> createState() => _VideoGalleryPageState();
}

class _VideoGalleryPageState extends State<VideoGalleryPage> {
  late Future<List<Video>> _videosFuture;
  
  // Filter state
  int? _selectedSportId;
  String? _selectedDifficulty;
  
  // Daftar sport & difficulty untuk dropdown
  final List<Map<String, dynamic>> _sports = [
    {'id': null, 'name': 'Semua Olahraga'},
    {'id': 1, 'name': 'Bulu Tangkis'},
    {'id': 2, 'name': 'Yoga'},
    {'id': 3, 'name': 'Tenis'},
    {'id': 4, 'name': 'Renang'},
    {'id': 5, 'name': 'Panahan'},
    {'id': 6, 'name': 'Lari'},
    {'id': 7, 'name': 'Basket'},
    {'id': 8, 'name': 'Futsal'},
    {'id': 9, 'name': 'Bersepeda'},
    {'id': 10, 'name': 'Tenis Meja'},
  ];
  
  final List<Map<String, String?>> _difficulties = [
    {'value': null, 'label': 'Semua Level'},
    {'value': 'Pemula', 'label': 'Pemula'},
    {'value': 'Menengah', 'label': 'Menengah'},
    {'value': 'Lanjutan', 'label': 'Lanjutan'},
  ];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }
  
  void _loadVideos() {
    setState(() {
      _videosFuture = VideoService.fetchVideos(
        sportId: _selectedSportId,
        difficulty: _selectedDifficulty,
      );
    });
  }
  
  void _applyFilter() {
    _loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SportPedia - Galeri Video'),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedSportId,
                        decoration: const InputDecoration(
                          labelText: 'Olahraga',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _sports.map((sport) {
                          return DropdownMenuItem<int?>(
                            value: sport['id'] as int?,
                            child: Text(sport['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSportId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Level',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _difficulties.map((diff) {
                          return DropdownMenuItem<String?>(
                            value: diff['value'],
                            child: Text(diff['label'] ?? 'Semua Level'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _applyFilter,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Video List
          Expanded(
            child: FutureBuilder<List<Video>>(
              future: _videosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat video:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final videos = snapshot.data ?? [];

                if (videos.isEmpty) {
                  return const Center(
                    child: Text('Belum ada video yang tersedia.'),
                  );
                }

                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            video.thumbnail,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Container(
                              width: 80,
                              height: 60,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        title: Text(video.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text(video.sportName),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(video.difficulty),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 8),
                                Text('${video.duration} • ⭐ ${video.rating}'),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoDetailPage(videoId: video.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


