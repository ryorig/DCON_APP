import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'neighborhood_view_model.dart';
import '../../data/models/models.dart';

class NeighborhoodScreen extends ConsumerWidget {
  const NeighborhoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(neighborhoodViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('地域マップ')),
      body: alertsAsync.when(
        data: (alerts) => _buildBody(context, alerts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<NeighborhoodAlertModel> alerts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Side by side
          return Row(
            children: [
              Expanded(flex: 2, child: _AlertMap(alerts: alerts)),
              const VerticalDivider(width: 1),
              Expanded(flex: 1, child: _AlertList(alerts: alerts)),
            ],
          );
        } else {
          // Tabbed view or Stack? Let's use column for now, map on top
          return Column(
            children: [
              Expanded(flex: 1, child: _AlertMap(alerts: alerts)),
              const Divider(height: 1),
              Expanded(flex: 1, child: _AlertList(alerts: alerts)),
            ],
          );
        }
      },
    );
  }
}

class _AlertMap extends StatelessWidget {
  final List<NeighborhoodAlertModel> alerts;

  const _AlertMap({required this.alerts});

  @override
  Widget build(BuildContext context) {
    // Center map on first alert or default
    final center = alerts.isNotEmpty 
        ? LatLng(alerts.first.lat, alerts.first.lng) 
        : const LatLng(35.6812, 139.7671);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: alerts.map((alert) {
            return Marker(
              point: LatLng(alert.lat, alert.lng),
              width: 40,
              height: 40,
              child: _buildMarkerIcon(alert),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarkerIcon(NeighborhoodAlertModel alert) {
    Color color;
    switch (alert.severity) {
      case AlertSeverity.critical: color = Colors.red; break;
      case AlertSeverity.warn: color = Colors.orange; break;
      case AlertSeverity.info: color = Colors.blue; break;
    }
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
    );
  }
}

class _AlertList extends StatelessWidget {
  final List<NeighborhoodAlertModel> alerts;

  const _AlertList({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: alerts.length,
      separatorBuilder: (c, i) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return ListTile(
          leading: Icon(_getIcon(alert.category), color: _getColor(alert.severity)),
          title: Text(alert.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('yyyy/MM/dd HH:mm').format(alert.timestamp)),
              Text(alert.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
          onTap: () {
            // Future: Focus map on this item
          },
        );
      },
    );
  }

  IconData _getIcon(AlertCategory cat) {
    switch (cat) {
      case AlertCategory.suspicious: return Icons.visibility;
      case AlertCategory.theft: return Icons.local_police; // approximate
      case AlertCategory.repeated_ring: return Icons.notifications_active;
      case AlertCategory.night: return Icons.nights_stay;
    }
  }

  Color _getColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical: return Colors.red;
      case AlertSeverity.warn: return Colors.orange;
      case AlertSeverity.info: return Colors.blue;
    }
  }
}
