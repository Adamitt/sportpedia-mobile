// Screen untuk menampilkan Riwayat Aktivitas
// Menerapkan layout widgets, event handling, dan pemanggilan async

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/activity_history.dart';
import '../services/profile_service.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  // State variables
  List<ActivityHistory> _activities = [];
  List<ActivityHistory> _filteredActivities = [];
  bool _isLoading = true;
  String? _selectedFilter;

  // Filter options based on Django action types
  final List<Map<String, String>> _filterOptions = [
    {'value': '', 'label': 'Semua'},
    {'value': 'MODULE_ACCESS', 'label': 'Akses Modul'},
    {'value': 'VIDEO_VIEW', 'label': 'Tonton Video'},
    {'value': 'FORUM_POST', 'label': 'Post Forum'},
    {'value': 'TESTIMONIAL_SUBMIT', 'label': 'Testimoni'},
    {'value': 'ADMIN_CREATE', 'label': 'Admin Create'},
    {'value': 'ADMIN_UPDATE', 'label': 'Admin Update'},
    {'value': 'ADMIN_DELETE', 'label': 'Admin Delete'},
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // ============================================================
  // PEMANGGILAN ASYNC KE WEB SERVICE DJANGO
  // ============================================================

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();

      // Memanggil API untuk mendapatkan semua aktivitas
      final activities = await ProfileService.getActivityHistory(request);

      setState(() {
        _activities = activities;
        _applyFilter(); // Apply filter setelah data dimuat
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  // ============================================================
  // FILTER LOGIC
  // ============================================================

  void _applyFilter() {
    if (_selectedFilter == null || _selectedFilter!.isEmpty) {
      _filteredActivities = List.from(_activities);
    } else {
      _filteredActivities = _activities
          .where((a) => a.actionType == _selectedFilter)
          .toList();
    }
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  void _onFilterChanged(String? value) {
    setState(() {
      _selectedFilter = value;
      _applyFilter();
    });
  }

  void _onActivityTap(ActivityHistory activity) {
    // Tampilkan detail aktivitas dalam bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getActivityColor(
                      activity.actionType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      activity.activityIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activity.actionDisplay,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Detail
            _buildDetailRow('Tipe Aktivitas', activity.actionType),
            const SizedBox(height: 8),
            _buildDetailRow('Deskripsi', activity.description),
            const SizedBox(height: 8),
            _buildDetailRow('Waktu', activity.formattedDate),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================
      // LAYOUT WIDGET - AppBar
      // ============================================================
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ============================================================
          // LAYOUT WIDGET - Filter Section
          // ============================================================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Aktivitas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // ============================================================
                // INPUT WIDGET - Dropdown untuk filter
                // ============================================================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFilter ?? '',
                      hint: const Text('Pilih filter'),
                      items: _filterOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(option['label']!),
                        );
                      }).toList(),
                      onChanged: _onFilterChanged, // Event handling
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // LAYOUT WIDGET - Activity List
          // ============================================================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredActivities.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadActivities,
                    child: _buildActivityList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _selectedFilter != null && _selectedFilter!.isNotEmpty
                ? 'Tidak ada aktivitas dengan filter ini'
                : 'Belum ada aktivitas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai jelajahi SportPedia!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    // Group activities by date
    final groupedActivities = <String, List<ActivityHistory>>{};

    for (var activity in _filteredActivities) {
      final dateKey = _formatDateHeader(activity.timestamp);
      groupedActivities.putIfAbsent(dateKey, () => []);
      groupedActivities[dateKey]!.add(activity);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedActivities.length,
      itemBuilder: (context, index) {
        final date = groupedActivities.keys.elementAt(index);
        final activities = groupedActivities[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),

            // Activity cards
            ...activities.map((activity) => _buildActivityCard(activity)),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(date.year, date.month, date.day);

    if (activityDate == today) {
      return 'Hari Ini';
    } else if (activityDate == yesterday) {
      return 'Kemarin';
    } else {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  Widget _buildActivityCard(ActivityHistory activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onActivityTap(activity), // Event handling
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Activity icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getActivityColor(
                    activity.actionType,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    activity.activityIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(activity.timestamp),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getActivityColor(String actionType) {
    switch (actionType) {
      case 'MODULE_ACCESS':
        return Colors.blue;
      case 'VIDEO_VIEW':
        return Colors.red;
      case 'FORUM_POST':
        return Colors.green;
      case 'TESTIMONIAL_SUBMIT':
        return Colors.amber;
      case 'ADMIN_CREATE':
        return Colors.purple;
      case 'ADMIN_UPDATE':
        return Colors.orange;
      case 'ADMIN_DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
