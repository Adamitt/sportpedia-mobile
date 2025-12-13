import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/api_service.dart';
import '../models/testimonial.dart';

class AddTestimonialDialog extends StatefulWidget {
  final Function(Testimonial)? onSuccess;
  final Testimonial? testimonial; // Optional: jika ada, berarti mode edit
  final CookieRequest? request; // Optional: untuk edit/delete

  const AddTestimonialDialog({super.key, this.onSuccess, this.testimonial, this.request});

  @override
  State<AddTestimonialDialog> createState() => _AddTestimonialDialogState();
}

class _AddTestimonialDialogState extends State<AddTestimonialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedCategory = 'library';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, prefill form dengan data testimonial
    if (widget.testimonial != null) {
      _textController.text = widget.testimonial!.text;
      _selectedCategory = widget.testimonial!.category;
      _imageUrlController.text = widget.testimonial!.imageUrl;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Testimonial testimonial;
      
      if (widget.testimonial != null) {
        // Mode edit - butuh CookieRequest
        if (widget.request == null) {
          throw Exception('Request required for editing testimonial');
        }
        testimonial = await HomepageApiService.updateTestimonial(
          id: widget.testimonial!.id,
          request: widget.request!,
          text: _textController.text.trim(),
          category: _selectedCategory,
          imageUrl: _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
        );
      } else {
        // Mode add - butuh CookieRequest
        if (widget.request == null) {
          throw Exception('Request required for creating testimonial');
        }
        testimonial = await HomepageApiService.createTestimonial(
          request: widget.request!,
          text: _textController.text.trim(),
          category: _selectedCategory,
          imageUrl: _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onSuccess != null) {
          widget.onSuccess!(testimonial);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.testimonial != null 
                ? 'Testimonial berhasil diperbarui!' 
                : 'Testimonial berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.testimonial != null ? 'Edit Testimonial' : 'Tambah Testimonial',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Text (tidak ada field judul sesuai Django template)
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Testimonial *',
                          hintText: 'Tulis testimonial Anda...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Testimonial wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'library', child: Text('Library')),
                          DropdownMenuItem(value: 'community', child: Text('Community')),
                          DropdownMenuItem(value: 'gearguide', child: Text('Gear Guide')),
                          DropdownMenuItem(value: 'video', child: Text('Video')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar (opsional)',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

