import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Datum> _filteredGears = [];
  
  String? _selectedSport;
  String? _selectedLevel;
  
  List<String> _availableSports = [];

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
        _availableSports = gears.map((g) => g.sportName).toSet().toList()..sort();
        _applyFilters();
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

  void _applyFilters() {
    _filteredGears = _gears.where((gear) {
      bool matchSport = _selectedSport == null || 
          gear.sportName.toLowerCase() == _selectedSport!.toLowerCase();
      bool matchLevel = _selectedLevel == null || 
          gear.levelDisplay == _selectedLevel;
      return matchSport && matchLevel;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Filter Gear',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedSport = null;
                          _selectedLevel = null;
                        });
                        setState(() {
                          _applyFilters();
                        });
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sport Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sport Type',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip('All', _selectedSport == null, () {
                          setModalState(() => _selectedSport = null);
                          setState(() => _applyFilters());
                        }),
                        ..._availableSports.map((sport) => _buildChip(
                          sport,
                          _selectedSport == sport,
                          () {
                            setModalState(() => _selectedSport = sport);
                            setState(() => _applyFilters());
                          },
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Level Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill Level',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip('All', _selectedLevel == null, () {
                          setModalState(() => _selectedLevel = null);
                          setState(() => _applyFilters());
                        }),
                        _buildChip('Pemula', _selectedLevel == 'Pemula', () {
                          setModalState(() => _selectedLevel = 'Pemula');
                          setState(() => _applyFilters());
                        }),
                        _buildChip('Menengah', _selectedLevel == 'Menengah', () {
                          setModalState(() => _selectedLevel = 'Menengah');
                          setState(() => _applyFilters());
                        }),
                        _buildChip('Profesional', _selectedLevel == 'Profesional', () {
                          setModalState(() => _selectedLevel = 'Profesional');
                          setState(() => _applyFilters());
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Show ${_filteredGears.length} Results',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadGears,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Custom App Bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Gear Guide',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                    onPressed: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GearFormPage()),
                      );
                      if (res == true) _loadGears();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Filter Button
        Container(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFF64748B), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    (_selectedSport != null || _selectedLevel != null)
                        ? 'Filters Active'
                        : 'Filter & Sort',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  if (_selectedSport != null || _selectedLevel != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(_selectedSport != null ? 1 : 0) + (_selectedLevel != null ? 1 : 0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ),

        // Results Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_filteredGears.length} ${_filteredGears.length == 1 ? 'gear' : 'gears'} found',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Gear List
        Expanded(
          child: _filteredGears.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No gear found',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedSport = null;
                              _selectedLevel = null;
                              _applyFilters();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Clear Filters',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _filteredGears.length,
                  itemBuilder: (context, i) {
                    final gear = _filteredGears[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GearCard(
                        datum: gear,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GearDetailPage(datum: gear),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }
}