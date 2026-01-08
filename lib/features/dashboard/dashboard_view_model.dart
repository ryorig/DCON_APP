import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_repository.dart';

final dashboardViewModelProvider = AsyncNotifierProvider<DashboardViewModel, DashboardState>(() {
  return DashboardViewModel();
});

class DashboardState {
  final List<EventModel> recentEvents;
  final List<EventModel> importantEvents;
  final List<NeighborhoodAlertModel> recentAlerts;
  final int todayVisits;
  final int todayDeliveries;
  final int todaySuspicious;
  final int todayAiResponses;

  DashboardState({
    required this.recentEvents,
    required this.importantEvents,
    required this.recentAlerts,
    required this.todayVisits,
    required this.todayDeliveries,
    required this.todaySuspicious,
    required this.todayAiResponses,
  });
}

class DashboardViewModel extends AsyncNotifier<DashboardState> {

  @override
  Future<DashboardState> build() async {
    return _loadData();
  }

  Future<DashboardState> _loadData() async {
    final eventsRepo = ref.read(eventsRepositoryProvider);
    final neighborhoodRepo = ref.read(neighborhoodRepositoryProvider);
    
    final events = await eventsRepo.getEvents();
    final alerts = await neighborhoodRepo.getAlerts();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayEvents = events.where((e) => e.timestamp.isAfter(today)).toList();
    
    return DashboardState(
      recentEvents: events.take(10).toList(),
      importantEvents: events.where((e) => e.risk == RiskLevel.high || e.risk == RiskLevel.mid).take(3).toList(),
      recentAlerts: alerts.take(3).toList(),
      todayVisits: todayEvents.length,
      todayDeliveries: todayEvents.where((e) => e.type == EventType.delivery).length,
      todaySuspicious: todayEvents.where((e) => e.type == EventType.suspicious).length,
      todayAiResponses: todayEvents.length, 
    );
  }

  // Allow manual refresh if needed
  Future<void> loadData() async {
    state = const AsyncValue.loading();
    try {
        final newData = await _loadData();
        state = AsyncValue.data(newData);
    } catch (e, st) {
        state = AsyncValue.error(e, st);
    }
  }
}

