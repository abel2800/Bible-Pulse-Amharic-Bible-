import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_plan_provider.dart';

class ReadingPlansScreen extends StatefulWidget {
  const ReadingPlansScreen({super.key});

  @override
  State<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends State<ReadingPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReadingPlanProvider>().loadPlans(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingPlanProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reading plans')),
      body: switch ((provider.isLoading, provider.availablePlans.isEmpty)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, true) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No licensed reading-plan catalog is installed.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        _ => ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.availablePlans.length,
            itemBuilder: (context, index) {
              final plan = provider.availablePlans[index];
              final userPlan = provider.getUserPlanByPlanId(plan.id);
              return Card(
                child: ListTile(
                  minTileHeight: 64,
                  title: Text(plan.title['en'] ?? plan.name),
                  subtitle: Text('${plan.duration} days'),
                  trailing: userPlan == null
                      ? FilledButton(
                          onPressed: () => provider.startPlan(plan),
                          child: const Text('Start'),
                        )
                      : Text('${(userPlan.progress * 100).round()}%'),
                ),
              );
            },
          ),
      },
    );
  }
}
