import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportpedia_mobile/services/gearguide_service.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';

class GearFormPage extends StatefulWidget {
  final Datum? gear; 
  const GearFormPage({super.key, this.gear});

  @override
  State<GearFormPage> createState() => _GearFormPageState();
}

class _GearFormPageState extends State<GearFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  
  List<Map<String, String>> _sportChoices = [];
  bool _sportsLoading = true; 

  late TextEditingController _nameController;
  late TextEditingController _functionController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _priceRangeController;
  late TextEditingController _ecommerceLinkController;
  late TextEditingController _recommendedBrandsController;
  late TextEditingController _materialsController;
  late TextEditingController _careTipsController;
  late TextEditingController _tagsController;

  String _sportId = '';
  String _level = 'beginner';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gear?.name ?? '');
    _functionController = TextEditingController(text: widget.gear?.function ?? '');
    _descriptionController = TextEditingController(text: widget.gear?.description ?? '');
    _imageController = TextEditingController(text: widget.gear?.image ?? '');
    _priceRangeController = TextEditingController(text: widget.gear?.priceRange ?? '');
    _ecommerceLinkController = TextEditingController(text: widget.gear?.ecommerceLink ?? '');
    _recommendedBrandsController = TextEditingController(
      text: widget.gear?.recommendedBrands.join(', ') ?? ''
    );
    _materialsController = TextEditingController(
      text: widget.gear?.materials.join(', ') ?? ''
    );
    _careTipsController = TextEditingController(text: widget.gear?.careTips ?? '');
    _tagsController = TextEditingController(
      text: widget.gear?.tags.join(', ') ?? ''
    );
    
    _fetchSports();

    if (widget.gear != null) {
      _sportId = widget.gear!.sportId.toString(); 
      
      final levelDisplay = widget.gear!.levelDisplay.toLowerCase();
      if (levelDisplay.contains('pemula') || levelDisplay.contains('beginner')) {
        _level = 'beginner';
      } else if (levelDisplay.contains('menengah') || levelDisplay.contains('intermediate')) {
        _level = 'intermediate';
      } else if (levelDisplay.contains('profesional') || levelDisplay.contains('advanced')) {
        _level = 'advanced';
      }
    }
  }

  Future<void> _fetchSports() async {
    try {
      final List<Map<String, String>> fetchedSports = await GearGuideService.getSports(); 
      
      if (mounted) {
        setState(() {
          _sportChoices = fetchedSports;
          _sportsLoading = false;

          if (widget.gear == null && _sportChoices.isNotEmpty && _sportId.isEmpty) {
             _sportId = _sportChoices.first['id'] ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sportsLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sport list: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _functionController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _priceRangeController.dispose();
    _ecommerceLinkController.dispose();
    _recommendedBrandsController.dispose();
    _materialsController.dispose();
    _careTipsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
    required bool isLoading, 
  }) {
    final dropdownItems = isLoading 
      ? [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('Loading Sports...', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
          )
        ]
      : items;

    final displayValue = isLoading ? null : (value.isEmpty ? null : value);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: displayValue, 
      
        onChanged: isLoading ? null : onChanged, 
        
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isLoading ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isLoading ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: dropdownItems,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.gear != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Gear' : 'Add Gear',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditMode ? Icons.edit_outlined : Icons.add_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditMode ? 'Edit Gear' : 'Add New Gear',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEditMode ? 'Update the details below' : 'Fill in the details below',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Basic Information Section
                  Text(
                    'Basic Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Gear Name',
                    icon: Icons.label_outline,
                    controller: _nameController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                  ),

                  // ✅ GUNAKAN _sportsLoading DI SINI
                  _buildDropdown(
                    label: 'Sport Type',
                    icon: Icons.sports,
                    value: _sportId,
                    items: _sportChoices.map((s) {
                      return DropdownMenuItem(
                        value: s['id'],
                        child: Text(s['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _sportId = v ?? ''),
                    validator: (v) => (v == null || v.isEmpty) ? 'Choose a sport' : null,
                    isLoading: _sportsLoading, // ✅ Pass loading state
                  ),

                  _buildDropdown(
                    label: 'Skill Level',
                    icon: Icons.trending_up,
                    value: _level,
                    items: const [
                      DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                    ],
                    onChanged: (v) => setState(() => _level = v ?? 'beginner'),
                    isLoading: false, // Tidak perlu loading untuk level
                  ),

                  const SizedBox(height: 24),

                  // Details Section
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Function',
                    icon: Icons.star_outline,
                    controller: _functionController,
                  ),

                  _buildTextField(
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    controller: _descriptionController,
                  ),

                  const SizedBox(height: 24),

                  // Media & Pricing Section
                  Text(
                    'Media & Pricing',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Image URL',
                    icon: Icons.image_outlined,
                    controller: _imageController,
                    keyboardType: TextInputType.url,
                  ),

                  _buildTextField(
                    label: 'Price Range',
                    icon: Icons.attach_money,
                    controller: _priceRangeController,
                  ),

                  _buildTextField(
                    label: 'E-commerce Link',
                    icon: Icons.shopping_cart_outlined,
                    controller: _ecommerceLinkController,
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 24),

                  // Additional Info Section
                  Text(
                    'Additional Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Recommended Brands (comma separated)',
                    icon: Icons.verified_outlined,
                    controller: _recommendedBrandsController,
                  ),

                  _buildTextField(
                    label: 'Materials (comma separated)',
                    icon: Icons.layers_outlined,
                    controller: _materialsController,
                  ),

                  _buildTextField(
                    label: 'Care Tips',
                    icon: Icons.health_and_safety_outlined,
                    maxLines: 3,
                    controller: _careTipsController,
                  ),

                  _buildTextField(
                    label: 'Tags (comma separated)',
                    icon: Icons.local_offer_outlined,
                    controller: _tagsController,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading || _sportsLoading ? null : _submit, // 🛑 Disable jika loading sport juga
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
                      ),
                      child: _loading || _sportsLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  isEditMode ? 'Update Gear' : 'Submit Gear',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  // Konversi input text -> List<String>
  final recommended = _recommendedBrandsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  final materials = _materialsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  final tags = _tagsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      final result = widget.gear == null
        ? await GearGuideService.submitGear(
              context,
              name: _nameController.text,
              sportId: _sportId,
              function: _functionController.text,
              description: _descriptionController.text,
              image: _imageController.text,
              priceRange: _priceRangeController.text,
              ecommerceLink: _ecommerceLinkController.text,
              level: _level,
              recommendedBrands: recommended,
              materials: materials,
              careTips: _careTipsController.text,
              tags: tags,
            )
        : await GearGuideService.editGear(
              context,
              widget.gear!.id, // Menggunakan ID yang sudah ada
              name: _nameController.text,
              sportId: _sportId,
              function: _functionController.text,
              description: _descriptionController.text,
              image: _imageController.text,
              priceRange: _priceRangeController.text,
              ecommerceLink: _ecommerceLinkController.text,
              level: _level,
              recommendedBrands: recommended,
              materials: materials,
              careTips: _careTipsController.text,
              tags: tags,
            );
        
      if (!mounted) return;
      setState(() => _loading = false);

      final bool ok = result['ok'] == true;
      if (ok) {
        // ✅ Sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Success!',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.gear != null
                        ? 'Gear has been updated successfully'
                        : 'Gear has been added successfully',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);      // close dialog
                        Navigator.pop(context, true); // trigger reload di GearGuidePage
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // ❌ Gagal tapi server balikin JSON ok:false
        final msg = (result['error'] ?? result['message'] ?? 'Unknown error')
            .toString();

        await showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to ${widget.gear != null ? 'update' : 'add'} gear: $msg',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // 🔥 Kalau ada exception (misal koneksi error), loading TETEP dimatiin
      if (!mounted) return;
      setState(() => _loading = false);

      await showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Unexpected Error',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}