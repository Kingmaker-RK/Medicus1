import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Sample reminders data
  List<Map<String, dynamic>> reminders = [
    {
      'id': 1,
      'medication': 'Aspirin',
      'dosage': '100mg',
      'time': '08:00 AM',
      'frequency': 'Daily',
      'enabled': true,
      'icon': Icons.medication_rounded,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'medication': 'Vitamin D',
      'dosage': '1000 IU',
      'time': '09:00 AM',
      'frequency': 'Daily',
      'enabled': true,
      'icon': Icons.wb_sunny_rounded,
      'color': Colors.orange,
    },
    {
      'id': 3,
      'medication': 'Blood Pressure Check',
      'dosage': '',
      'time': '06:00 PM',
      'frequency': 'Daily',
      'enabled': false,
      'icon': Icons.favorite_rounded,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medication Reminders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              _showReminderHistory(context);
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: reminders.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Today's overview card
                _buildTodayOverviewCard(),

                const SizedBox(height: 24),

                // Active reminders section
                _buildSectionHeader('Active Reminders'),
                const SizedBox(height: 12),

                ...reminders
                    .where((r) => r['enabled'] == true)
                    .map(
                      (reminder) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildReminderCard(reminder),
                      ),
                    ),

                if (reminders.any((r) => r['enabled'] == false)) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Inactive Reminders'),
                  const SizedBox(height: 12),
                  ...reminders
                      .where((r) => r['enabled'] == false)
                      .map(
                        (reminder) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildReminderCard(reminder),
                        ),
                      ),
                ],

                const SizedBox(height: 20),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddReminderDialog(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const AutoTranslateAutoTranslateAutoTranslateText('Add Reminder'),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reminders Set',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Stay on track with your medication by setting up reminders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _showAddReminderDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Your First Reminder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTodayOverviewCard() {
    final activeReminders = reminders.where((r) => r['enabled'] == true).length;
    final totalReminders = reminders.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$activeReminders',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Active Reminders',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$totalReminders',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total Reminders',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: reminder['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    reminder['icon'],
                    color: reminder['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder['medication'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (reminder['dosage'].isNotEmpty)
                        Text(
                          reminder['dosage'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder['enabled'],
                  onChanged: (value) {
                    setState(() {
                      reminder['enabled'] = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Reminder enabled' : 'Reminder disabled',
                        ),
                        backgroundColor: value
                            ? AppColors.success
                            : AppColors.textSecondary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  reminder['time'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.repeat_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  reminder['frequency'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: AppColors.accent,
                  ),
                  onPressed: () {
                    _showEditReminderDialog(context, reminder);
                  },
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    _showDeleteConfirmation(context, reminder);
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final medicationController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedFrequency = 'Daily';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.add_alert_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              const AutoTranslateAutoTranslateAutoTranslateText('Add Reminder'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: medicationController,
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    prefixIcon: const Icon(Icons.medication_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dosage (optional)',
                    prefixIcon: const Icon(Icons.science_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time',
                      prefixIcon: const Icon(Icons.access_time_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(selectedTime.format(context)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: const Icon(Icons.repeat_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Daily', 'Weekly', 'Monthly', 'As needed']
                      .map(
                        (freq) =>
                            DropdownMenuItem(value: freq, child: Text(freq)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFrequency = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AutoTranslateAutoTranslateAutoTranslateText('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (medicationController.text.isNotEmpty) {
                  setState(() {
                    reminders.add({
                      'id': reminders.length + 1,
                      'medication': medicationController.text,
                      'dosage': dosageController.text,
                      'time': selectedTime.format(context),
                      'frequency': selectedFrequency,
                      'enabled': true,
                      'icon': Icons.medication_rounded,
                      'color': Colors.blue,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const AutoTranslateAutoTranslateAutoTranslateText('Reminder added successfully'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const AutoTranslateAutoTranslateAutoTranslateText('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReminderDialog(
    BuildContext context,
    Map<String, dynamic> reminder,
  ) {
    final medicationController = TextEditingController(
      text: reminder['medication'],
    );
    final dosageController = TextEditingController(text: reminder['dosage']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: AppColors.accent),
            const SizedBox(width: 12),
            const AutoTranslateAutoTranslateAutoTranslateText('Edit Reminder'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: medicationController,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                prefixIcon: const Icon(Icons.medication_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage',
                prefixIcon: const Icon(Icons.science_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateAutoTranslateAutoTranslateText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                reminder['medication'] = medicationController.text;
                reminder['dosage'] = dosageController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const AutoTranslateAutoTranslateAutoTranslateText('Reminder updated'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const AutoTranslateAutoTranslateAutoTranslateText('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> reminder,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            const AutoTranslateAutoTranslateAutoTranslateText('Delete Reminder'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the reminder for ${reminder['medication']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateAutoTranslateText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                reminders.removeWhere((r) => r['id'] == reminder['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const AutoTranslateAutoTranslateText('Reminder deleted'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const AutoTranslateAutoTranslateText('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReminderHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: AppColors.success),
              ),
              title: const AutoTranslateAutoTranslateText('Aspirin - 100mg'),
              subtitle: const AutoTranslateAutoTranslateText('Taken at 08:00 AM'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: AppColors.success),
              ),
              title: const AutoTranslateAutoTranslateText('Vitamin D - 1000 IU'),
              subtitle: const AutoTranslateAutoTranslateText('Taken at 09:00 AM'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, color: AppColors.error),
              ),
              title: const AutoTranslateAutoTranslateText('Blood Pressure Check'),
              subtitle: const AutoTranslateAutoTranslateText('Missed at 06:00 PM'),
            ),
          ],
        ),
      ),
    );
  }
}
