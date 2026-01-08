import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_repository.dart';

final neighborhoodViewModelProvider = FutureProvider<List<NeighborhoodAlertModel>>((ref) async {
  final repo = ref.read(neighborhoodRepositoryProvider);
  return repo.getAlerts();
});
