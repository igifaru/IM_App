import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/common/custom_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  final List<Map<String, dynamic>> _rabSeasons = [
    {
      'name': 'Season A',
      'months': [9, 10, 11, 12, 1, 2],
      'crops': ['Maize', 'Beans', 'Irish Potato', 'Cassava'],
      'color': Colors.green,
      'status': 'Harvesting / Preparation',
    },
    {
      'name': 'Season B',
      'months': [3, 4, 5, 6],
      'crops': ['Sorghum', 'Groundnut', 'Soybean', 'Vegetables'],
      'color': Colors.blue,
      'status': 'Planting / Weeding',
    },
    {
      'name': 'Season C',
      'months': [7, 8],
      'crops': ['Sweet Potato', 'Vegetables'],
      'color': Colors.orange,
      'status': 'Marshland Cultivation',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        title: Text('calendar_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(),
            _buildCalendarGrid(),
            _buildSeasonDetails(),
            _buildUpcomingTasks(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOffset = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox();
              final day = index - firstDayOffset + 1;
              final isToday = day == DateTime.now().day && _focusedDay.month == DateTime.now().month && _focusedDay.year == DateTime.now().year;
              final isDarkMode = Theme.of(context).brightness == Brightness.dark;
              
              return Container(
                decoration: BoxDecoration(
                  color: isToday ? Theme.of(context).primaryColor : (isDarkMode ? Theme.of(context).cardColor : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.white : Colors.black.withOpacity(0.87),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonDetails() {
    final currentSeason = _rabSeasons.firstWhere(
      (s) => (s['months'] as List<int>).contains(_focusedDay.month),
      orElse: () => _rabSeasons[0],
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CustomCard(
        color: (currentSeason['color'] as Color).withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: currentSeason['color']),
                const SizedBox(width: 12),
                Text(
                  'RAB ${currentSeason['name']}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: currentSeason['color'],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentSeason['color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentSeason['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommended Crops:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (currentSeason['crops'] as List<String>).map((crop) => Chip(
                label: Text(crop.tr()),
                backgroundColor: Colors.white,
                side: BorderSide(color: currentSeason['color'].withOpacity(0.3)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Deadlines',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTaskItem('Fertilizer Distribution', 'Ministry of Agriculture', 'Starts Oct 15'),
          _buildTaskItem('Seed Selection Window', 'RAB Guidelines', 'Ends Oct 30'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String subtitle, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_active, color: Colors.amber),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Text(date, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
