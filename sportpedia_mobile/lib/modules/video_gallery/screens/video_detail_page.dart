import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/video.dart';
import '../models/comment.dart';
import '../services/video_service.dart';

/// Halaman detail video yang menampilkan informasi lengkap dari satu video.
/// 
/// Menerapkan:
/// - Event handling: navigasi dari list ke detail
/// - Pemanggilan asinkronus ke web service Django: VideoService.fetchVideoDetail()
/// - Pengolahan data response JSON: Video.fromJson()
/// - Menampilkan hasil: UI detail lengkap
class VideoDetailPage extends StatefulWidget {
  final int videoId;

  const VideoDetailPage({
    super.key,
    required this.videoId,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late Future<Video> _videoFuture;
  late Future<List<Comment>> _commentsFuture;
  
  // State untuk form komentar & rating
  final TextEditingController _commentController = TextEditingController();
  int? _selectedRating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pemanggilan asinkronus ke web service Django
    _videoFuture = VideoService.fetchVideoDetail(widget.videoId);
    _commentsFuture = VideoService.fetchComments(widget.videoId);
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  void _refreshComments() {
    setState(() {
      _commentsFuture = VideoService.fetchComments(widget.videoId);
    });
  }
  
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      await VideoService.submitComment(
        videoId: widget.videoId,
        text: _commentController.text.trim(),
        rating: _selectedRating,
      );
      
      _commentController.clear();
      _selectedRating = null;
      _refreshComments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah komentar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  Future<void> _submitRating(int rating) async {
    try {
      await VideoService.submitRating(
        videoId: widget.videoId,
        rating: rating,
      );
      
      // Refresh video untuk update rating
      setState(() {
        _videoFuture = VideoService.fetchVideoDetail(widget.videoId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah rating: $e')),
        );
      }
    }
  }

  /// Event handling: membuka video YouTube di browser
  Future<void> _openVideoUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka link video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Video'),
      ),
      body: FutureBuilder<Video>(
        future: _videoFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat detail video:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _videoFuture = VideoService.fetchVideoDetail(widget.videoId);
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Success state: menampilkan hasil pengolahan JSON
          final video = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 64),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        video.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Metadata: Sport, Difficulty, Duration
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.sports, size: 18),
                            label: Text(video.sportName),
                          ),
                          Chip(
                            avatar: const Icon(Icons.trending_up, size: 18),
                            label: Text(video.difficulty),
                          ),
                          Chip(
                            avatar: const Icon(Icons.timer, size: 18),
                            label: Text(video.duration),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating & Views
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${video.rating}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              const Icon(Icons.visibility, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${video.views} views',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        video.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // Button: Buka Video YouTube
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openVideoUrl(video.url),
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Tonton di YouTube'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Rating Section
                      Text(
                        'Beri Rating',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          return IconButton(
                            icon: Icon(
                              _selectedRating != null && rating <= _selectedRating!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedRating = rating;
                              });
                              _submitRating(rating);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      
                      // Comments Section
                      Text(
                        'Komentar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Form Tambah Komentar
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.send),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Rating: '),
                          ...List.generate(5, (index) {
                            final rating = index + 1;
                            return IconButton(
                              icon: Icon(
                                _selectedRating != null && rating <= _selectedRating!
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedRating = rating;
                                });
                              },
                            );
                          }),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitComment,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Kirim'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // List Komentar
                      FutureBuilder<List<Comment>>(
                        future: _commentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Gagal memuat komentar: ${snapshot.error}'),
                              ),
                            );
                          }
                          
                          final comments = snapshot.data ?? [];
                          
                          if (comments.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Belum ada komentar'),
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(comment.user[0].toUpperCase()),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(comment.user),
                                      if (comment.rating != null) ...[
                                        const SizedBox(width: 8),
                                        ...List.generate(5, (i) {
                                          return Icon(
                                            i < comment.rating!
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 14,
                                            color: Colors.amber,
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(comment.text),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            comment.createdAt,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (comment.helpfulCount > 0) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.thumb_up,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${comment.helpfulCount}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

