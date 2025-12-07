// lib/screens/gear_form_page.dart
import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/services/gearguide_service.dart';

class GearFormPage extends StatefulWidget {
  const GearFormPage({super.key});

  @override
  State<GearFormPage> createState() => _GearFormPageState();
}

class _GearFormPageState extends State<GearFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String _name = '';
  String _sportId = '';
  String _function = '';
  String _description = '';
  String _image = '';
  String _priceRange = '';
  String _ecommerceLink = '';
  String _level = 'beginner';
  String _recommendedBrandsRaw = '';
  String _materialsRaw = '';
  String _careTips = '';
  String _tagsRaw = '';

  // Quick static sport list — later replace by API fetch for dynamic options
  final List<Map<String, String>> _sportChoices = [
    {'id': '1', 'name': 'Bulu Tangkis'},
    {'id': '2', 'name': 'Yoga'},
    {'id': '3', 'name': 'Tenis'},
    {'id': '4', 'name': 'Renang'},
    {'id': '5', 'name': 'Panahan'},
    {'id': '6', 'name': 'Lari'},
    {'id': '7', 'name': 'Basket'},
    {'id': '8', 'name': 'Futsal'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Gear')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (v) => _name = v,
                      validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Sport'),
                      items: _sportChoices.map((s) {
                        return DropdownMenuItem(
                          value: s['id'],
                          child: Text(s['name'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) => _sportId = v ?? '',
                      validator: (v) => (v == null || v.isEmpty) ? 'Choose sport' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Function'),
                      onChanged: (v) => _function = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 5,
                      onChanged: (v) => _description = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      onChanged: (v) => _image = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Price range'),
                      onChanged: (v) => _priceRange = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Ecommerce link'),
                      onChanged: (v) => _ecommerceLink = v,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Level'),
                      value: _level,
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('Pemula')),
                        DropdownMenuItem(value: 'intermediate', child: Text('Menengah')),
                        DropdownMenuItem(value: 'advanced', child: Text('Lanjutan')),
                      ],
                      onChanged: (v) => _level = v ?? 'beginner',
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Recommended brands (comma separated)'),
                      onChanged: (v) => _recommendedBrandsRaw = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Materials (comma separated)'),
                      onChanged: (v) => _materialsRaw = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Care tips'),
                      onChanged: (v) => _careTips = v,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                      onChanged: (v) => _tagsRaw = v,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
              if (_loading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final recommended = _recommendedBrandsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final materials = _materialsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final tags = _tagsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    final result = await GearGuideService.submitGear(
      name: _name,
      sportId: _sportId,
      function: _function,
      description: _description,
      image: _image,
      priceRange: _priceRange,
      ecommerceLink: _ecommerceLink,
      level: _level,
      recommendedBrands: recommended,
      materials: materials,
      careTips: _careTips,
      tags: tags,
    );

    setState(() => _loading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Gear berhasil ditambahkan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, true); // pop form and return true
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final message = result['message'] ?? 'Server error';
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Gagal menambahkan gear: $message'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }
}
