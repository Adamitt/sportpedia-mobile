import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
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
        onChanged: onChanged,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Add Gear',
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
                          child: const Icon(
                            Icons.add_circle_outline,
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
                                'Add New Gear',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fill in the details below',
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
                    onChanged: (v) => _name = v,
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
                    onChanged: (v) => _function = v,
                  ),

                  _buildTextField(
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    onChanged: (v) => _description = v,
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
                    onChanged: (v) => _image = v,
                    keyboardType: TextInputType.url,
                  ),

                  _buildTextField(
                    label: 'Price Range',
                    icon: Icons.attach_money,
                    onChanged: (v) => _priceRange = v,
                  ),

                  _buildTextField(
                    label: 'E-commerce Link',
                    icon: Icons.shopping_cart_outlined,
                    onChanged: (v) => _ecommerceLink = v,
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
                    onChanged: (v) => _recommendedBrandsRaw = v,
                  ),

                  _buildTextField(
                    label: 'Materials (comma separated)',
                    icon: Icons.layers_outlined,
                    onChanged: (v) => _materialsRaw = v,
                  ),

                  _buildTextField(
                    label: 'Care Tips',
                    icon: Icons.health_and_safety_outlined,
                    maxLines: 3,
                    onChanged: (v) => _careTips = v,
                  ),

                  _buildTextField(
                    label: 'Tags (comma separated)',
                    icon: Icons.local_offer_outlined,
                    onChanged: (v) => _tagsRaw = v,
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
                                  'Submit Gear',
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

    final recommended = _recommendedBrandsRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final materials = _materialsRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final tags = _tagsRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

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
                  'Gear has been added successfully',
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
                      Navigator.pop(context);
                      Navigator.pop(context, true);
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
                  'Failed to add gear: $message',
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