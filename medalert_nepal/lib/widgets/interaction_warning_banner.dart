import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ml_provider.dart';
import '../providers/medical_profile_provider.dart';

class InteractionWarningBanner extends ConsumerWidget {
  final String targetMedicineName;

  const InteractionWarningBanner({
    super.key,
    required this.targetMedicineName,
  });

  List<String> _parseMedications(String medicationsStr) {
    if (medicationsStr.isEmpty) return [];
    return medicationsStr.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(medicalProfileProvider);

    if (!profileAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final profile = profileAsync.value!;
    final currentMeds = _parseMedications(profile.currentMedications);

    if (currentMeds.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedMeds = List.from(currentMeds)..sort();
    final interactionKey = '${sortedMeds.join(',')}|$targetMedicineName';
    final interactionAsync = ref.watch(interactionCheckProvider(interactionKey));

    if (!interactionAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final warnings = interactionAsync.value!;

    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Drug Interaction Warning',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${warning['drug_a'] as String} + ${warning['drug_b'] as String}: ${warning['interaction_text'] as String}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Consult your doctor or pharmacist before taking this medication.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer.withAlpha(204),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
