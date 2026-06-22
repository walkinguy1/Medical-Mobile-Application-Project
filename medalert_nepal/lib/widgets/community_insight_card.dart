import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../providers/ml_provider.dart';

class CommunityInsightCard extends ConsumerWidget {
  final Medicine medicine;

  const CommunityInsightCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(medicineInsightProvider(medicine.genericName));

    if (!insightAsync.hasValue || insightAsync.value == null) {
      return const SizedBox.shrink();
    }

    final insight = insightAsync.value!;
    final effectivenessScore = (insight['avg_effectiveness_score'] as num).toDouble();
    final sideEffectScore = (insight['avg_side_effect_score'] as num).toDouble();
    final reviewCount = insight['review_count'] as int;

    final effectivenessValue = effectivenessScore / 5.0;
    final sideEffectSeverityValue = (6 - sideEffectScore) / 5.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Effectiveness bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Effectiveness',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      effectivenessScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: effectivenessValue.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Side effects bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Side Effect Severity',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      sideEffectScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: sideEffectSeverityValue.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on $reviewCount patient reviews (Druglib.com dataset)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
