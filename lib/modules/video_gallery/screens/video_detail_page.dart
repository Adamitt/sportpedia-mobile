import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/video.dart';
import '../models/comment.dart';
import '../services/video_service.dart';
import '../../../accounts/screens/login.dart';

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

  final TextEditingController _commentController = TextEditingController();
  int? _selectedRating;
  bool _isSubmitting = false;
  final Set<int> _helpfulComments =
      {}; // Track comments that have been marked as helpful

  // Color scheme - Match Django
  static const Color primaryBlue = Color(0xFF1C3264);
  static const Color accentYellow = Color(0xFFFFDD78);
  static const Color bgGray = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Helper function untuk mendapatkan gradient difficulty (soft gradient)
  static LinearGradient _getDifficultyGradient(String difficulty) {
    switch (difficulty) {
      case 'Pemula':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Soft green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Menengah':
        return const LinearGradient(
          colors: [
            Color(0xFFFFC107),
            Color(0xFFFFD54F)
          ], // Soft yellow gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Lanjutan':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // Soft blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [accentYellow, accentYellow.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  void initState() {
    super.initState();
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

  Future<void> _handleHelpful(int commentId) async {
    // Check if already marked as helpful
    if (_helpfulComments.contains(commentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar ini sudah ditandai sebagai helpful'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final request = Provider.of<CookieRequest>(context, listen: false);

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Silakan login terlebih dahulu untuk menandai komentar sebagai helpful'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await VideoService.markCommentHelpful(
        request: request,
        commentId: commentId,
      );

      setState(() {
        _helpfulComments.add(commentId);
      });

      // Refresh comments to get updated count
      _refreshComments();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Komentar ditandai sebagai helpful 👍'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Gagal menandai komentar: ${e.toString().replaceAll('Exception: ', '')}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleReply(Comment comment) async {
    final request = Provider.of<CookieRequest>(context, listen: false);

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Silakan login terlebih dahulu untuk membalas komentar'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final replyController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Reply to ${comment.user}'),
          content: TextField(
            controller: replyController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tulis balasan Anda...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (replyController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Balasan tidak boleh kosong'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      setDialogState(() {
                        isSubmitting = true;
                      });

                      try {
                        await VideoService.submitReply(
                          request: request,
                          commentId: comment.id,
                          text: replyController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          _refreshComments();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Balasan berhasil dikirim'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSubmitting = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Gagal mengirim balasan: ${e.toString().replaceAll('Exception: ', '')}'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );

    replyController.dispose();
  }

  Future<void> _submitComment() async {
    // Get fresh CookieRequest instance
    final request = Provider.of<CookieRequest>(context, listen: false);

    if (!request.loggedIn) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );

      // After login, wait a bit for session to be established, then get fresh CookieRequest
      await Future.delayed(const Duration(milliseconds: 100));
      final updatedRequest = Provider.of<CookieRequest>(context, listen: false);

      if (result != true || !updatedRequest.loggedIn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Silakan login terlebih dahulu untuk menambahkan komentar')),
          );
        }
        return;
      }

      // If login successful, continue with comment submission
      // (will be handled by the code below)
    }

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
      // Get fresh CookieRequest before submitting
      final currentRequest = Provider.of<CookieRequest>(context, listen: false);

      // Debug: print login status
      print(
          '[DEBUG] Submitting comment - loggedIn: ${currentRequest.loggedIn}');

      if (!currentRequest.loggedIn) {
        throw Exception('Anda harus login terlebih dahulu');
      }

      await VideoService.submitComment(
        request: currentRequest,
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
    } catch (e, stackTrace) {
      print('[DEBUG] _submitComment - Exception: $e');
      print('[DEBUG] _submitComment - StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal menambah komentar: ${e.toString().replaceAll('Exception: ', '')}'),
            duration: const Duration(seconds: 5),
          ),
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
    // Get fresh CookieRequest instance
    final request = Provider.of<CookieRequest>(context, listen: false);

    if (!request.loggedIn) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );

      // After login, get fresh CookieRequest again
      final updatedRequest = Provider.of<CookieRequest>(context, listen: false);
      if (result != true || !updatedRequest.loggedIn) {
        return;
      }
    }

    try {
      // Get fresh CookieRequest before submitting
      final currentRequest = Provider.of<CookieRequest>(context, listen: false);

      if (!currentRequest.loggedIn) {
        throw Exception('Anda harus login terlebih dahulu');
      }

      await VideoService.submitRating(
        request: currentRequest,
        videoId: widget.videoId,
        rating: rating,
      );

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
          SnackBar(
            content: Text(
                'Gagal menambah rating: ${e.toString().replaceAll('Exception: ', '')}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

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
      backgroundColor: bgGray,
      appBar: AppBar(
        backgroundColor: cardWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Video Detail',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: FutureBuilder<Video>(
        future: _videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                        _videoFuture =
                            VideoService.fetchVideoDetail(widget.videoId);
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final video = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Video Player - Full Width, YouTube Style
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      image: video.thumbnail.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(video.thumbnail),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Dark overlay
                        Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        // Play Button - Centered
                        Center(
                          child: _AnimatedPlayButton(
                            onTap: () => _openVideoUrl(video.url),
                            primaryBlue: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title - YouTube Style
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontFamily: 'Roboto',
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stats & Actions Row - YouTube Style
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Stats
                          Expanded(
                            child: Wrap(
                              spacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${video.views} views',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  'Dec 9, 2025', // Placeholder - bisa ditambahkan ke model jika diperlukan
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      video.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Divider(color: Colors.grey[300], height: 1),
                      const SizedBox(height: 16),

                      // Channel/Uploader Info - YouTube Style
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF1E40AF),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Channel Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                Text(
                                  '${video.views} subscribers',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Divider(color: Colors.grey[300], height: 1),
                      const SizedBox(height: 16),

                      // Description Card - YouTube Style
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    video.sportName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: _getDifficultyGradient(
                                        video.difficulty),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getDifficultyGradient(
                                                video.difficulty)
                                            .colors
                                            .first
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    video.difficulty,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      video.duration,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Description Text
                            Text(
                              video.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: textPrimary,
                                height: 1.5,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description Card - 3D Effect
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardWhite,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            // 3D Shadow
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              video.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: textSecondary,
                                height: 1.6,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Rating Section Card - 3D Effect
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardWhite,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            // 3D Shadow
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Beri Rating',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final rating = index + 1;
                                return _AnimatedStarButton(
                                  rating: rating,
                                  isSelected: _selectedRating != null &&
                                      rating <= _selectedRating!,
                                  onTap: () {
                                    setState(() {
                                      _selectedRating = rating;
                                    });
                                    _submitRating(rating);
                                  },
                                  accentYellow: accentYellow,
                                  size: 40,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Comments Section - YouTube Style
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Comment Count Header
                          FutureBuilder<List<Comment>>(
                            future: _commentsFuture,
                            builder: (context, snapshot) {
                              final commentCount = snapshot.data?.length ?? 0;
                              return Text(
                                '$commentCount Comments',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                  fontFamily: 'Roboto',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Comment Input - YouTube Style
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1E40AF),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'U',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Input Field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _commentController,
                                      maxLines: null,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Add a comment...',
                                        hintStyle: TextStyle(
                                          color: textSecondary,
                                          fontSize: 14,
                                          fontFamily: 'Roboto',
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey[500]!,
                                            width: 1,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.only(bottom: 8),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Rating & Submit Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Rating Stars
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (index) {
                                            final rating = index + 1;
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedRating = rating;
                                                });
                                              },
                                              child: Icon(
                                                _selectedRating != null &&
                                                        rating <=
                                                            _selectedRating!
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 18,
                                                color:
                                                    _selectedRating != null &&
                                                            rating <=
                                                                _selectedRating!
                                                        ? accentYellow
                                                        : Colors.grey[400],
                                              ),
                                            );
                                          }),
                                        ),
                                        // Action Buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                _commentController.clear();
                                                setState(() {
                                                  _selectedRating = null;
                                                });
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: textSecondary,
                                                  fontFamily: 'Roboto',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: _isSubmitting
                                                  ? null
                                                  : _submitComment,
                                              style: TextButton.styleFrom(
                                                backgroundColor: primaryBlue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                              child: _isSubmitting
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Text(
                                                      'Comment',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Comments List
                          FutureBuilder<List<Comment>>(
                            future: _commentsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                    child: Text(
                                      'Gagal memuat komentar: ${snapshot.error}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final comments = snapshot.data ?? [];

                              if (comments.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.comment_outlined,
                                            size: 48, color: textSecondary),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No comments yet. Be the first to comment!',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey[200],
                                ),
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return _buildCommentCard(comment);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  Widget _buildStatItem(IconData icon, String value, String label,
      {Color? iconColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? textSecondary,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                fontFamily: 'Roboto',
              ),
            ),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontFamily: 'Roboto',
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar - YouTube Style (Smaller)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1E40AF),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comment.user[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment Content - YouTube Style
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username, Time, Rating
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      comment.user,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      comment.createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    if (comment.rating != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: accentYellow,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${comment.rating}/5',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Comment Text
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: textPrimary,
                    height: 1.4,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                // Action Buttons - YouTube Style
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _helpfulComments.contains(comment.id)
                          ? null
                          : () => _handleHelpful(comment.id),
                      icon: Icon(
                        _helpfulComments.contains(comment.id)
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 16,
                        color: _helpfulComments.contains(comment.id)
                            ? primaryBlue
                            : textSecondary,
                      ),
                      label: Text(
                        '${comment.helpfulCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _helpfulComments.contains(comment.id)
                              ? primaryBlue
                              : textSecondary,
                          fontFamily: 'Roboto',
                          fontWeight: _helpfulComments.contains(comment.id)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _handleReply(comment),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                // Replies Section
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vertical line indicator
                        Container(
                          width: 2,
                          height: 8,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        // Replies list
                        ...comment.replies
                            .map((reply) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Smaller avatar for replies
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF60A5FA),
                                              Color(0xFF3B82F6),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            reply.user[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  reply.user,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: textPrimary,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                                Text(
                                                  reply.createdAt,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: textSecondary,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              reply.text,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: textPrimary,
                                                height: 1.4,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Play Button Widget
class _AnimatedPlayButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color primaryBlue;

  const _AnimatedPlayButton({
    required this.onTap,
    required this.primaryBlue,
  });

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isPressed ? Colors.grey[100] : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.2 : 0.3),
                blurRadius: _isPressed ? 15 : 20,
                offset: Offset(0, _isPressed ? 5 : 10),
              ),
            ],
          ),
          child: CustomPaint(
            size: const Size(50, 50),
            painter: _PlayIconPainter(widget.primaryBlue),
          ),
        ),
      ),
    );
  }
}

// Animated Button Widget with 3D Effect
class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool useGradient;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    required this.foregroundColor,
    this.useGradient = false,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 8.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: widget.onPressed == null
          ? null
          : () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: widget.useGradient
                    ? LinearGradient(
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.useGradient
                    ? null
                    : widget.onPressed == null
                        ? widget.backgroundColor.withOpacity(0.5)
                        : _isPressed
                            ? widget.backgroundColor.withOpacity(0.85)
                            : widget.backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  // 3D Shadow Effect
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.4),
                    blurRadius: _elevationAnimation.value * 2,
                    offset: Offset(0, _elevationAnimation.value),
                    spreadRadius: _isPressed ? -2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.foregroundColor,
                  fontFamily: 'Roboto',
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter for Play Icon Triangle
class _PlayIconPainter extends CustomPainter {
  final Color color;

  _PlayIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw triangle pointing right
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Star Button Widget
class _AnimatedStarButton extends StatefulWidget {
  final int rating;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentYellow;
  final double size;

  const _AnimatedStarButton({
    required this.rating,
    required this.isSelected,
    required this.onTap,
    required this.accentYellow,
    this.size = 24,
  });

  @override
  State<_AnimatedStarButton> createState() => _AnimatedStarButtonState();
}

class _AnimatedStarButtonState extends State<_AnimatedStarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward().then((_) => _controller.reverse());
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.9 : _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                widget.isSelected ? Icons.star : Icons.star_border,
                color: widget.accentYellow,
                size: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}
