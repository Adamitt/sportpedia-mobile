import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportpedia_mobile/services/gearguide_service.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';

class GearFormPage extends StatefulWidget {
  final Datum? gear; // Tambahkan parameter optional untuk edit mode
  
  const GearFormPage({super.key, this.gear});

  @override
  State<GearFormPage> createState() => _GearFormPageState();
}

class _GearFormPageState extends State<GearFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Controllers untuk menyimpan nilai awal saat edit
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
  void initState() {
    super.initState();
    
    // Inisialisasi controllers dengan data dari gear jika ada (edit mode)
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

    // Set sportId dan level jika edit mode
    if (widget.gear != null) {
      // Cari sportId berdasarkan sportName dari gear
      final sportName = widget.gear!.sportName;
      final matchingSport = _sportChoices.firstWhere(
        (s) => s['name'] == sportName,
        orElse: () => {'id': '', 'name': ''},
      );
      _sportId = matchingSport['id'] ?? '';
      
      // Konversi levelDisplay ke level yang sesuai dengan form
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items,
        onChanged: onChanged,
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
                      onPressed: _loading ? null : _submit,
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
                      child: _loading
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

    final result = await GearGuideService.submitGear(
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

    setState(() => _loading = false);

    if (result['success'] == true) {
      if (!mounted) return;
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
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
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, true); // Return true to trigger reload
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
      final message = result['message'] ?? 'Server error';
      if (!mounted) return;
      showDialog(
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
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
                  'Failed to ${widget.gear != null ? 'update' : 'add'} gear: $message',
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