import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/reading_plan_provider.dart';

class ReadingPlansScreen extends StatelessWidget {
  const ReadingPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.windowBg,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
        elevation: 0,
        title: const Text(
          'የንባብ መርሃግብር', // Reading Plan
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ReadingPlanProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: 5, // Sample plans
            itemBuilder: (context, index) {
              return _buildPlanCard(context, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.toolbarPrimary,
        onPressed: () {
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, int index) {
    final plans = [
      {
        'title': 'Bible in One Year',
        'subtitle': 'በአንድ አመት ውስጥ መጽሐፍ ቅዱስን ያንብቡ',
        'duration': '365 ቀናት',
        'progress': 0.25,
        'color': Colors.blue,
      },
      {
        'title': 'New Testament in 90 Days',
        'subtitle': 'አዲስ ኪዳን በ90 ቀናት',
        'duration': '90 ቀናት',
        'progress': 0.5,
        'color': Colors.green,
      },
      {
        'title': 'Psalms & Proverbs',
        'subtitle': 'መዝሙራት እና ምሳሌዎች',
        'duration': '150 ቀናት',
        'progress': 0.15,
        'color': Colors.orange,
      },
      {
        'title': 'Gospels',
        'subtitle': 'ወንጌላት',
        'duration': '40 ቀናት',
        'progress': 0.75,
        'color': Colors.purple,
      },
      {
        'title': 'Old Testament Stories',
        'subtitle': 'የብሉይ ኪዳን ታሪኮች',
        'duration': '180 ቀናት',
        'progress': 0.1,
        'color': Colors.teal,
      },
    ];

    final plan = plans[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${plan['subtitle']} - Coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          plan['color'] as Color,
                          (plan['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
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
                          plan['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan['duration'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.controlNormal,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan['progress'] as double,
                  backgroundColor: AppColors.lighterGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    plan['color'] as Color,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${((plan['progress'] as double) * 100).toInt()}% ተጠናቀቀ',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

