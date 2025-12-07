// lib/screens/gear_detail_page.dart
import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';

class GearDetailPage extends StatelessWidget {
  final Datum datum;

  const GearDetailPage({super.key, required this.datum});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (datum.image != null && datum.image.isNotEmpty) ? datum.image : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            const SizedBox(height: 16),

            // Title + sport + level
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    datum.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                _chipText(_levelText()),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              datum.sportName,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),

            const SizedBox(height: 12),
            _sectionTitle('Function'),
            Text((datum.function ?? '').isNotEmpty ? datum.function! : '-'),

            const SizedBox(height: 12),
            _sectionTitle('Description'),
            Text((datum.description ?? '').isNotEmpty ? datum.description! : '-'),

            const SizedBox(height: 12),
            _sectionTitle('Price'),
            Text((datum.priceRange ?? '').isNotEmpty ? datum.priceRange! : '-'),

            const SizedBox(height: 12),
            if ((datum.recommendedBrands ?? []).isNotEmpty) ...[
              _sectionTitle('Recommended brands'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (datum.recommendedBrands ?? []).map((b) => _tagChip(b)).toList(),
              ),
              const SizedBox(height: 12),
            ],

            if ((datum.materials ?? []).isNotEmpty) ...[
              _sectionTitle('Materials'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (datum.materials ?? []).map((m) => _tagChip(m)).toList(),
              ),
              const SizedBox(height: 12),
            ],

            _sectionTitle('Care tips'),
            Text((datum.careTips ?? '').isNotEmpty ? datum.careTips! : '-'),

            const SizedBox(height: 12),
            if ((datum.tags ?? []).isNotEmpty) ...[
              _sectionTitle('Tags'),
              Wrap(spacing: 8, runSpacing: 8, children: (datum.tags ?? []).map((t) => _tagChip(t)).toList()),
              const SizedBox(height: 12),
            ],

            if ((datum.ecommerceLink ?? '').isNotEmpty) ...[
              _sectionTitle('Buy link'),
              Text(
                datum.ecommerceLink!,
                style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link tersedia (open disabled)')));
                },
                icon: const Icon(Icons.link),
                label: const Text('Show link'),
              ),
              const SizedBox(height: 12),
            ],

            if (datum.owner != null && datum.owner!.isNotEmpty) ...[
              _sectionTitle('Owner'),
              Text(datum.owner ?? '-'),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Convert enum or string to readable level text safely
  String _levelText() {
    try {
      // prefer levelDisplay if available and non-empty
      final ld = datum.levelDisplay;
      if (ld != null) {
        final s = ld.toString();
        // e.g. "Level.BEGINNER" or "Level.PEMULA" -> take last part
        final last = s.split('.').last;
        return last.replaceAll('_', ' ').toLowerCase().splitMapJoin(RegExp(r'^\w'),
            onMatch: (m) => m[0]!.toUpperCase(), onNonMatch: (n) => n); // capitalize first letter
      }
    } catch (_) {}

    try {
      final lv = datum.level;
      if (lv != null) {
        final s = lv.toString().split('.').last;
        return s.replaceAll('_', ' ').toLowerCase().splitMapJoin(RegExp(r'^\w'),
            onMatch: (m) => m[0]!.toUpperCase(), onNonMatch: (n) => n);
      }
    } catch (_) {}

    // fallback to a safe default
    return 'Semua';
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _tagChip(String t) {
    return Chip(label: Text(t));
  }

  Widget _chipText(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Text(t, style: const TextStyle(fontSize: 12)),
    );
  }
}
