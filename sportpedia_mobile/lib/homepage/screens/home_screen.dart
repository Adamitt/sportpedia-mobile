import 'package:flutter/material.dart';
import '../models/testimonial.dart';
import '../models/popular_category.dart';
import '../services/api_service.dart';

class HomepageHomeScreen extends StatefulWidget {
  const HomepageHomeScreen({super.key});

  @override
  State<HomepageHomeScreen> createState() => _HomepageHomeScreenState();
}

class _HomepageHomeScreenState extends State<HomepageHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sportpedia API Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PopularCategoriesTab(),
          TestimonialsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Popular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Testimonials',
          ),
        ],
      ),
    );
  }
}

// ============================================
// POPULAR CATEGORIES TAB
// ============================================

class PopularCategoriesTab extends StatefulWidget {
  const PopularCategoriesTab({super.key});

  @override
  State<PopularCategoriesTab> createState() => _PopularCategoriesTabState();
}

class _PopularCategoriesTabState extends State<PopularCategoriesTab> {
  List<PopularCategory> _items = [];
  bool _isLoading = false;
  String? _error;
  int _limit = 3;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await HomepageApiService.getPopularCategories(limit: _limit);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Limit',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: _limit.toString())
                    ..selection = TextSelection.collapsed(
                        offset: _limit.toString().length),
                  onChanged: (value) {
                    _limit = int.tryParse(value) ?? 3;
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loadItems,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_items.isEmpty)
          const Expanded(
            child: Center(child: Text('No popular categories found')),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: item.image.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(item.image),
                            onBackgroundImageError: (_, __) {},
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.category),
                          ),
                    title: Text(item.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${item.category}'),
                        Text('Views: ${item.views}'),
                        if (item.excerpt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              item.excerpt!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ============================================
// TESTIMONIALS TAB
// ============================================

class TestimonialsTab extends StatefulWidget {
  const TestimonialsTab({super.key});

  @override
  State<TestimonialsTab> createState() => _TestimonialsTabState();
}

class _TestimonialsTabState extends State<TestimonialsTab> {
  List<Testimonial> _testimonials = [];
  bool _isLoading = false;
  String? _error;
  String _categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final testimonials = await HomepageApiService.getTestimonials(
        category: _categoryFilter,
      );
      setState(() {
        _testimonials = testimonials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedCategory = 'library';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Testimonial'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Text *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'library', child: Text('Library')),
                    DropdownMenuItem(
                        value: 'community', child: Text('Community')),
                    DropdownMenuItem(
                        value: 'gearguide', child: Text('Gear Guide')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await HomepageApiService.createTestimonial(
                    text: textController.text.trim(),
                    title: titleController.text.trim().isEmpty
                        ? null
                        : titleController.text.trim(),
                    category: selectedCategory,
                    imageUrl: imageUrlController.text.trim().isEmpty
                        ? null
                        : imageUrlController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadTestimonials();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Testimonial created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Testimonial testimonial) async {
    final titleController = TextEditingController(text: testimonial.title);
    final textController = TextEditingController(text: testimonial.text);
    final imageUrlController =
        TextEditingController(text: testimonial.imageUrl);
    String selectedCategory = testimonial.category;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Testimonial'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Text',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'library', child: Text('Library')),
                    DropdownMenuItem(
                        value: 'community', child: Text('Community')),
                    DropdownMenuItem(
                        value: 'gearguide', child: Text('Gear Guide')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await HomepageApiService.updateTestimonial(
                    id: testimonial.id,
                    title: titleController.text.trim(),
                    text: textController.text.trim(),
                    category: selectedCategory,
                    imageUrl: imageUrlController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadTestimonials();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Testimonial updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTestimonial(Testimonial testimonial) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Testimonial'),
        content: Text('Are you sure you want to delete "${testimonial.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await HomepageApiService.deleteTestimonial(testimonial.id);
        _loadTestimonials();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Testimonial deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _categoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Category Filter',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'library', child: Text('Library')),
                    DropdownMenuItem(
                        value: 'community', child: Text('Community')),
                    DropdownMenuItem(
                        value: 'gearguide', child: Text('Gear Guide')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _categoryFilter = value;
                      });
                      _loadTestimonials();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loadTestimonials,
                child: const Text('Refresh'),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: _showCreateDialog,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadTestimonials,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_testimonials.isEmpty)
          const Expanded(
            child: Center(child: Text('No testimonials found')),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _testimonials.length,
              itemBuilder: (context, index) {
                final testimonial = _testimonials[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: testimonial.imageUrl.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(testimonial.imageUrl),
                            onBackgroundImageError: (_, __) {},
                          )
                        : CircleAvatar(
                            child: Text(testimonial.user[0].toUpperCase()),
                          ),
                    title: Text(testimonial.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(testimonial.text),
                        const SizedBox(height: 4),
                        Text(
                          'By: ${testimonial.user} • ${testimonial.category} • ${testimonial.createdAt}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: testimonial.isOwner
                        ? PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(testimonial);
                              } else if (value == 'delete') {
                                _deleteTestimonial(testimonial);
                              }
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

