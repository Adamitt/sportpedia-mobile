// lib/screens/gearguide_page.dart
import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/services/gearguide_service.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';
import 'package:sportpedia_mobile/screens/gear_form_page.dart';
import 'package:sportpedia_mobile/widgets/gear_card.dart';
import 'package:sportpedia_mobile/screens/gear_detail_page.dart';

class GearGuidePage extends StatefulWidget {
  const GearGuidePage({super.key});

  @override
  State<GearGuidePage> createState() => _GearGuidePageState();
}

class _GearGuidePageState extends State<GearGuidePage> {
  bool _loading = true;
  String? _error;
  List<Datum> _gears = [];

  @override
  void initState() {
    super.initState();
    _loadGears();
  }

  Future<void> _loadGears() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gears = await GearGuideService.fetchGears();
      setState(() {
        _gears = gears;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadGears,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_gears.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No gear found.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadGears,
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    // RESPONSIVE — list untuk mobile kecil, grid untuk tablet/desktop
    return LayoutBuilder(builder: (context, constraints) {
      // Mobile mode
      if (constraints.maxWidth < 500) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _gears.length,
          itemBuilder: (context, i) {
            final g = _gears[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GearCard(
                datum: g,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GearDetailPage(datum: g),
                    ),
                  );
                },
              ),
            );
          },
        );
      }

      // Tablet / Desktop grid
      final crossAxisCount =
          constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 700 ? 3 : 2);

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: _gears.length,
        itemBuilder: (context, idx) {
          final g = _gears[idx];
          return GearCard(
            datum: g,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GearDetailPage(datum: g),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Guide'),
        actions: [
          IconButton(
            tooltip: 'Add gear (form)',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GearFormPage()),
              );

              if (res == true) {
                _loadGears();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
