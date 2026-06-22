import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_service.dart';

final mlServiceProvider = Provider<MlService>((ref) => MlService());

final medicineInsightProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, genericName) async {
  final service = ref.watch(mlServiceProvider);
  return service.getMedicineInsight(genericName);
});

final symptomCheckProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, symptomsKey) async {
  final service = ref.watch(mlServiceProvider);
  final symptoms = symptomsKey.split(',').where((s) => s.isNotEmpty).toList();
  return service.checkSymptoms(symptoms);
});

final interactionCheckProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, interactionKey) async {
  final service = ref.watch(mlServiceProvider);
  final parts = interactionKey.split('|');
  final currentMeds = parts[0].split(',').where((s) => s.isNotEmpty).toList();
  final targetMedicine = parts[1];
  return service.checkInteractions(currentMeds, targetMedicine);
});
