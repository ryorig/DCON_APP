import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'events_view_model.dart';
import '../../data/models/models.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  EventType? _selectedType;
  RiskLevel? _selectedRisk;
  bool _onlyUnread = false;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('イベント履歴')),
      body: Column(
        children: [
          _buildFilters(context),
          const Divider(height: 1),
          Expanded(
            child: eventsAsync.when(
              data: (events) => events.isEmpty
                  ? const Center(child: Text('イベントはありません'))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _EventListItem(event: event);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
             FilterChip(
              label: const Text('未読のみ'),
              selected: _onlyUnread,
              onSelected: (val) {
                setState(() => _onlyUnread = val);
                _applyFilters();
              },
            ),
            const SizedBox(width: 8),
            DropdownButton<EventType>(
              value: _selectedType,
              hint: const Text('カテゴリ'),
              underline: Container(),
              items: [
                const DropdownMenuItem(value: null, child: Text('全て')),
                ...EventType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))),
              ],
              onChanged: (val) {
                setState(() => _selectedType = val);
                _applyFilters();
              },
            ),
            const SizedBox(width: 8),
            DropdownButton<RiskLevel>(
              value: _selectedRisk,
              hint: const Text('危険度'),
              underline: Container(),
              items: [
                 const DropdownMenuItem(value: null, child: Text('全て')),
                ...RiskLevel.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))),
              ],
              onChanged: (val) {
                setState(() => _selectedRisk = val);
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    ref.read(eventsViewModelProvider.notifier).filterEvents(
      type: _selectedType,
      risk: _selectedRisk,
      onlyUnread: _onlyUnread,
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventModel event;
  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    Color riskColor;
    if (event.risk == RiskLevel.high) {
      riskColor = Colors.red;
    } else if (event.risk == RiskLevel.mid) {
      riskColor = Colors.orange;
    } else {
      riskColor = Colors.grey;
    }

    return ListTile(
      onTap: () => context.go('/events/${event.id}'),
      leading: CircleAvatar(
        backgroundColor: riskColor.withOpacity(0.1),
        child: Icon(_getIcon(event.type), color: riskColor),
      ),
      title: Text(
        event.summary,
        style: TextStyle(fontWeight: event.status == EventStatus.unread ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(event.timestamp)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(event.risk.name.toUpperCase(), style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(EventType type) {
    switch (type) {
      case EventType.delivery: return Icons.local_shipping;
      case EventType.sales: return Icons.store;
      case EventType.suspicious: return Icons.warning;
      case EventType.family: return Icons.home;
      default: return Icons.info;
    }
  }
}
