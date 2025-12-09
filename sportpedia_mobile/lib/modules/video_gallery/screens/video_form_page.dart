import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/video.dart';
import '../services/video_service.dart';

class VideoFormPage extends StatefulWidget {
  final Video? video; // If provided, this is edit mode

  const VideoFormPage({super.key, this.video});

  @override
  State<VideoFormPage> createState() => _VideoFormPageState();
}

class _VideoFormPageState extends State<VideoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _instructorController = TextEditingController();
  final _durationController = TextEditingController();
  final _tagsController = TextEditingController();

  int? _selectedSportId;
  String _selectedDifficulty = 'Pemula';
  bool _isLoading = false;
  List<Map<String, dynamic>> _sports = [];

  final List<Map<String, dynamic>> _difficulties = [
    {'value': 'Pemula', 'label': 'Pemula'},
    {'value': 'Menengah', 'label': 'Menengah'},
    {'value': 'Lanjutan', 'label': 'Lanjutan'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.video != null) {
      // Edit mode - populate fields
      _titleController.text = widget.video!.title;
      _descriptionController.text = widget.video!.description;
      _videoUrlController.text = widget.video!.url;
      _thumbnailUrlController.text = widget.video!.thumbnail;
      _durationController.text = widget.video!.duration;
      _selectedDifficulty = widget.video!.difficulty;
    }
    _loadSports().then((_) {
      // After loading sports, try to match sport name to get ID
      if (widget.video != null && _sports.isNotEmpty) {
        final sportName = widget.video!.sportName;
        final matchedSport = _sports.firstWhere(
          (sport) => sport['name'] == sportName,
          orElse: () => <String, dynamic>{},
        );
        if (matchedSport.isNotEmpty) {
          setState(() {
            _selectedSportId = matchedSport['id'] as int?;
          });
        }
      }
    });
  }

  Future<void> _loadSports() async {
    try {
      final sports = await VideoService.fetchSports();
      setState(() {
        _sports = sports;
      });
    } catch (e) {
      // If sports API doesn't exist, use hardcoded list
      setState(() {
        _sports = [
          {'id': 1, 'name': 'Bulu Tangkis'},
          {'id': 2, 'name': 'Renang'},
          {'id': 3, 'name': 'Basket'},
          {'id': 4, 'name': 'Sepak Bola'},
        ];
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori olahraga')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = Provider.of<CookieRequest>(context, listen: false);

    try {
      if (widget.video == null) {
        // Create mode
        await VideoService.createVideo(
          request: request,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          sportId: _selectedSportId!,
          difficulty: _selectedDifficulty,
          videoUrl: _videoUrlController.text.trim(),
          thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty
              ? null
              : _thumbnailUrlController.text.trim(),
          instructor: _instructorController.text.trim().isEmpty
              ? null
              : _instructorController.text.trim(),
          duration: _durationController.text.trim().isEmpty
              ? null
              : _durationController.text.trim(),
          tags: _tagsController.text.trim().isEmpty
              ? null
              : _tagsController.text.trim().split(',').map((e) => e.trim()).toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video berhasil ditambahkan')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Update mode
        await VideoService.updateVideo(
          request: request,
          videoId: widget.video!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          sportId: _selectedSportId,
          difficulty: _selectedDifficulty,
          videoUrl: _videoUrlController.text.trim(),
          thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty
              ? null
              : _thumbnailUrlController.text.trim(),
          instructor: _instructorController.text.trim().isEmpty
              ? null
              : _instructorController.text.trim(),
          duration: _durationController.text.trim().isEmpty
              ? null
              : _durationController.text.trim(),
          tags: _tagsController.text.trim().isEmpty
              ? null
              : _tagsController.text.trim().split(',').map((e) => e.trim()).toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video berhasil diperbarui')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.video == null ? 'Tambah Video' : 'Edit Video',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF1C3264),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Video *',
                hintText: 'Masukkan judul video',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul harus diisi';
                }
                if (value.trim().length < 5) {
                  return 'Judul minimal 5 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi *',
                hintText: 'Masukkan deskripsi video',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                if (value.trim().length < 20) {
                  return 'Deskripsi minimal 20 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Sport
            DropdownButtonFormField<int>(
              value: _selectedSportId,
              decoration: const InputDecoration(
                labelText: 'Kategori Olahraga *',
                border: OutlineInputBorder(),
              ),
              items: _sports.map((sport) {
                return DropdownMenuItem<int>(
                  value: sport['id'] as int,
                  child: Text(sport['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSportId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Pilih kategori olahraga';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Tingkat Kesulitan *',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((diff) {
                return DropdownMenuItem<String>(
                  value: diff['value'] as String,
                  child: Text(diff['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Video URL
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Video (YouTube) *',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URL video harus diisi';
                }
                if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                  return 'URL harus dari YouTube';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Thumbnail URL
            TextFormField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Thumbnail (Opsional)',
                hintText: 'Akan diisi otomatis dari YouTube jika kosong',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Instructor
            TextFormField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instruktur (Opsional)',
                hintText: 'Nama instruktur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Durasi (Opsional)',
                hintText: 'Format: MM:SS (contoh: 05:30)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (Opsional)',
                hintText: 'Pisahkan dengan koma (contoh: teknik, dasar, tutorial)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C3264),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.video == null ? 'Tambah Video' : 'Simpan Perubahan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}

