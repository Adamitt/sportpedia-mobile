// lib/widgets/gear_card.dart
import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';

class GearCard extends StatelessWidget {
  final Datum datum;
  final VoidCallback? onTap;

  const GearCard({super.key, required this.datum, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tags = datum.tags ?? [];
    final imageUrl =
        (datum.image != null && datum.image!.isNotEmpty) ? datum.image : null;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),

              const SizedBox(width: 12),

              // Right content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Level
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            datum.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            datum.levelDisplay
                                .toString()
                                .replaceAll('Level.', '')
                                .replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 11),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      datum.sportName,
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 12),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      datum.priceRange.isNotEmpty
                          ? datum.priceRange
                          : 'Harga: -',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 6),

                    // Tags (horizontal chip list)
                    if (tags.isNotEmpty)
                      SizedBox(
                        height: 26,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: tags.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                tags[index],
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          },
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, color: Colors.white54),
    );
  }
}
