import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_view_model.dart';
import 'kpi_cards.dart';
import '../../data/models/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateForAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(dashboardViewModelProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: stateForAsync.when(
        data: (state) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKpiSection(state),
              const SizedBox(height: 24),
              _buildImportantEventsSection(context, state.importantEvents),
              const SizedBox(height: 24),
              _buildAnalysisRow(context, state),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildKpiSection(DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final count = isWide ? 4 : 2;
        
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            KpiCard(
              title: '今日の訪問',
              value: '${state.todayVisits}',
              icon: Icons.people,
              color: Colors.blue,
            ),
            KpiCard(
              title: '置き配',
              value: '${state.todayDeliveries}',
              icon: Icons.local_shipping,
              color: Colors.green,
            ),
            KpiCard(
              title: '不審判定',
              value: '${state.todaySuspicious}',
              icon: Icons.warning,
              color: Colors.orange,
            ),
            KpiCard(
              title: 'AI応答',
              value: '${state.todayAiResponses}',
              icon: Icons.smart_toy,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildImportantEventsSection(BuildContext context, List<EventModel> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('重要イベント', style: Theme.of(context).textTheme.headlineSmall),
            TextButton(onPressed: () => context.go('/events'), child: const Text('すべて見る')),
          ],
        ),
        const SizedBox(height: 8),
        if (events.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('重要な通知はありません'))),
        ...events.map((e) => _ImportantEventCard(event: e)),
      ],
    );
  }

  Widget _buildAnalysisRow(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentEventsList(context, state.recentEvents)),
              const SizedBox(width: 24),
              Expanded(child: _buildAlertsList(context, state.recentAlerts)),
            ],
          );
        } else {
          return Column(
            children: [
               _buildRecentEventsList(context, state.recentEvents),
               const SizedBox(height: 24),
               _buildAlertsList(context, state.recentAlerts),
            ],
          );
        }
      },
    );
  }

  Widget _buildRecentEventsList(BuildContext context, List<EventModel> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最新のイベント', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (c, i) {
              final e = events[i];
              return ListTile(
                leading: _buildCategoryIcon(e.type),
                title: Text(e.summary),
                subtitle: Text(DateFormat('MM/dd HH:mm').format(e.timestamp)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => c.go('/events/${e.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsList(BuildContext context, List<NeighborhoodAlertModel> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('地域アラート', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (c, i) {
              final a = alerts[i];
              return ListTile(
                leading: const Icon(Icons.notification_important, color: Colors.red),
                title: Text(a.title),
                subtitle: Text(a.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => c.go('/neighborhood'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(EventType type) {
    IconData icon;
    Color color;
    switch (type) {
      case EventType.delivery:
        icon = Icons.local_shipping;
        color = Colors.green;
        break;
      case EventType.sales:
        icon = Icons.store;
        color = Colors.blue;
        break;
      case EventType.suspicious:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case EventType.family:
        icon = Icons.home;
        color = Colors.purple;
        break;
      case EventType.other:
      default:
        icon = Icons.info;
        color = Colors.grey;
        break;
    }
    return CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20));
  }
}

class _ImportantEventCard extends StatelessWidget {
  final EventModel event;

  const _ImportantEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(event.summary, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('時刻: ${DateFormat('HH:mm').format(event.timestamp)} - ${event.risk.name.toUpperCase()} RISK'),
        trailing: ElevatedButton(
          onPressed: () => context.go('/events/${event.id}'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
          child: const Text('確認'),
        ),
      ),
    );
  }
}
