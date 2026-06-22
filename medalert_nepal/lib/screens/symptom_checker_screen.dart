import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ml_provider.dart';

const List<String> uiSymptomColumns = [
  'abdominal_pain',
  'altered_sensorium',
  'back_pain',
  'bladder_discomfort',
  'blood_in_sputum',
  'breathlessness',
  'chest_pain',
  'chills',
  'coma',
  'continuous_feel_of_urine',
  'cough',
  'dark_urine',
  'dehydration',
  'diarrhoea',
  'dischromic _patches',
  'family_history',
  'fast_heart_rate',
  'fatigue',
  'headache',
  'high_fever',
  'increased_appetite',
  'internal_itching',
  'itching',
  'joint_pain',
  'lack_of_concentration',
  'loss_of_appetite',
  'malaise',
  'mild_fever',
  'mucoid_sputum',
  'muscle_pain',
  'muscle_weakness',
  'nausea',
  'neck_pain',
  'nodal_skin_eruptions',
  'pain_behind_the_eyes',
  'passage_of_gases',
  'receiving_unsterile_injections',
  'red_spots_over_body',
  'rusty_sputum',
  'spotting_ urination',
  'stomach_bleeding',
  'stomach_pain',
  'sunken_eyes',
  'sweating',
  'unsteadiness',
  'vomiting',
  'weight_loss',
  'yellow_crust_ooze',
  'yellowing_of_eyes',
  'yellowish_skin',
];

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  final Set<String> _selectedSymptoms = {};

  String _formatSymptomName(String symptom) {
    return symptom.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _onCheckSymptoms() {
    if (_selectedSymptoms.isEmpty) return;
    final sortedSymptoms = _selectedSymptoms.toList()..sort();
    final symptomsKey = sortedSymptoms.join(',');
    ref.read(symptomCheckProvider(symptomsKey).future);
  }

  @override
  Widget build(BuildContext context) {
    final sortedSymptoms = _selectedSymptoms.toList()..sort();
    final symptomsKey = sortedSymptoms.join(',');
    final symptomCheckAsync = ref.watch(symptomCheckProvider(symptomsKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: uiSymptomColumns.length,
              itemBuilder: (context, index) {
                final symptom = uiSymptomColumns[index];
                final isSelected = _selectedSymptoms.contains(symptom);
                return CheckboxListTile(
                  title: Text(_formatSymptomName(symptom)),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              },
            ),
          ),
          if (symptomCheckAsync.hasValue && _selectedSymptoms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptomCheckAsync.value!['predicted_condition'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            symptomCheckAsync.value!['in_dda_list'] == true
                                ? Icons.check_circle
                                : Icons.warning,
                            color: symptomCheckAsync.value!['in_dda_list'] == true
                                ? Colors.green
                                : Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            symptomCheckAsync.value!['in_dda_list'] == true
                                ? 'Available in DDA List'
                                : 'Not in DDA List',
                            style: TextStyle(
                              color: symptomCheckAsync.value!['in_dda_list'] == true
                                  ? Colors.green
                                  : Colors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        symptomCheckAsync.value!['disclaimer'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (symptomCheckAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (symptomCheckAsync.hasError)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Error: ${symptomCheckAsync.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _onCheckSymptoms,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSymptoms.isEmpty ? null : _onCheckSymptoms,
                child: const Text('Check Symptoms'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
