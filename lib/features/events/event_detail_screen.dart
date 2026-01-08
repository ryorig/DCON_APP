import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'events_view_model.dart';
import '../../data/models/models.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント詳細'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share), tooltip: '地域へ共有申請'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete), tooltip: '削除'),
        ],
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) return const Center(child: Text('Event not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, event),
                const Divider(height: 32),
                _buildMainContent(context, event),
                const SizedBox(height: 24),
                _buildTranscriptSection(context, event),
                const SizedBox(height: 24),
                _buildImageSection(context, event),
                const SizedBox(height: 40),
                _buildActionButtons(context),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EventModel event) {
    Color riskColor;
    switch (event.risk) {
      case RiskLevel.high: riskColor = Colors.red; break;
      case RiskLevel.mid: riskColor = Colors.orange; break;
      case RiskLevel.low: riskColor = Colors.green; break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(event.type.name.toUpperCase()),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('RISK: ${event.risk.name.toUpperCase()}'),
              backgroundColor: riskColor.withOpacity(0.1),
              labelStyle: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              DateFormat('yyyy/MM/dd HH:mm').format(event.timestamp),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          event.summary,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, EventModel event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('AI応答', event.aiReply),
            if (event.type == EventType.delivery)
             _buildInfoRow('置き配判定', event.packageCheck.name),
            _buildInfoRow('ステータス', event.status.name),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection(BuildContext context, EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('会話ログ', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('訪問者:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(event.transcript),
              const SizedBox(height: 16),
              const Text('AI:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              Text(event.aiReply),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, EventModel event) {
    if (!event.hasImage || event.imageUrl == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('証跡画像', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: event.imageUrl!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            imageErrorBuilder: (c, o, s) => Container(
              height: 300,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('メモを追加'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text('確認完了'),
        ),
      ],
    );
  }
}
