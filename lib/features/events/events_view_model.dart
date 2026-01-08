import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_repository.dart';

final eventsViewModelProvider = AsyncNotifierProvider<EventsViewModel, List<EventModel>>(() {
  return EventsViewModel();
});

class EventsViewModel extends AsyncNotifier<List<EventModel>> {
  List<EventModel> _allEvents = [];

  @override
  Future<List<EventModel>> build() async {
    return _loadEvents();
  }

  Future<List<EventModel>> _loadEvents() async {
    final repository = ref.read(eventsRepositoryProvider);
    _allEvents = await repository.getEvents();
    return _allEvents;
  }

  void filterEvents({String? query, EventType? type, RiskLevel? risk, bool? onlyUnread}) {
    if (_allEvents.isEmpty) return;

    List<EventModel> filtered = List.from(_allEvents);

    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((e) => 
        e.summary.contains(query) || e.transcript.contains(query)
      ).toList();
    }

    if (type != null) {
      filtered = filtered.where((e) => e.type == type).toList();
    }

    if (risk != null) {
      filtered = filtered.where((e) => e.risk == risk).toList();
    }

    if (onlyUnread == true) {
      filtered = filtered.where((e) => e.status == EventStatus.unread).toList();
    }

    state = AsyncValue.data(filtered);
  }
}

final eventDetailProvider = FutureProvider.family<EventModel?, String>((ref, id) async {
  final repo = ref.read(eventsRepositoryProvider);
  return repo.getEvent(id);
});

