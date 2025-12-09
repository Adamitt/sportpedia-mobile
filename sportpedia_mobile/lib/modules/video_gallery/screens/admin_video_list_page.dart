import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/video.dart';
import '../services/video_service.dart';
import 'video_form_page.dart';
import 'video_detail_page.dart';

class AdminVideoListPage extends StatefulWidget {
  const AdminVideoListPage({super.key});

  @override
  State<AdminVideoListPage> createState() => _AdminVideoListPageState();
}

class _AdminVideoListPageState extends State<AdminVideoListPage> {
  late Future<List<Video>> _videosFuture;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _videosFuture = VideoService.fetchVideos();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _refreshVideos();
    });
  }

  void _refreshVideos() {
    setState(() {
      final searchQuery = _searchController.text.trim();
      _videosFuture = VideoService.fetchVideos(
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );
    });
  }

  Future<void> _deleteVideo(int videoId, String title) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Video'),
        content: Text('Apakah Anda yakin ingin menghapus video "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await VideoService.deleteVideo(request: request, videoId: videoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video berhasil dihapus')),
        );
        _refreshVideos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin - Manage Videos',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF1C3264),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoFormPage(),
                ),
              );
              if (result == true) {
                _refreshVideos();
              }
            },
            tooltip: 'Tambah Video',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari video...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _refreshVideos();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                // Search is handled by _onSearchChanged listener with debounce
              },
            ),
          ),
          // Video list
          Expanded(
            child: FutureBuilder<List<Video>>(
              future: _videosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshVideos,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada video'),
                  );
                }

                final videos = snapshot.data!;
                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            video.thumbnail,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.video_library),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          video.title,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${video.sportName} • ${video.difficulty}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${video.views} views • ⭐ ${video.rating.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoFormPage(video: video),
                                  ),
                                );
                                if (result == true) {
                                  _refreshVideos();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _deleteVideo(video.id, video.title),
                            ),
                          ],
                        ),
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}

