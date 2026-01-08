import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

final eventsRepositoryProvider = Provider((ref) => EventsRepository());
final neighborhoodRepositoryProvider = Provider((ref) => NeighborhoodRepository());

class EventsRepository {
  final List<EventModel> _events = [];

  EventsRepository() {
    _generateMockData();
  }

  void _generateMockData() {
    final now = DateTime.now();
    final random = Random();

    for (int i = 0; i < 25; i++) {
      final type = EventType.values[random.nextInt(EventType.values.length)];
      final risk = _determineRisk(type);
      
      _events.add(EventModel(
        id: 'evt_$i',
        deviceId: 'dev_01',
        timestamp: now.subtract(Duration(hours: random.nextInt(72), minutes: random.nextInt(60))),
        type: type,
        risk: risk,
        summary: _generateSummary(type),
        transcript: '申し訳ありません、担当者が不在ですので失礼します。',
        aiReply: '只今留守にしております。ご用件をお話しください。',
        hasImage: true,
        imageUrl: 'https://via.placeholder.com/150',
        hasAudio: false,
        packageCheck: type == EventType.delivery 
            ? PackageCheckStatus.values[random.nextInt(PackageCheckStatus.values.length)] 
            : PackageCheckStatus.none,
        status: i < 5 ? EventStatus.unread : EventStatus.read,
        locationMesh: 'mesh_500m_001',
      ));
    }
    
    // Check sorting
    _events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  RiskLevel _determineRisk(EventType type) {
    switch (type) {
      case EventType.suspicious:
        return RiskLevel.high;
      case EventType.sales:
        return RiskLevel.mid;
      default:
        return RiskLevel.low;
    }
  }

  String _generateSummary(EventType type) {
    switch (type) {
      case EventType.delivery:
        return '宅配業者が荷物を置き配しました';
      case EventType.sales:
        return '訪問販売の勧誘がありました';
      case EventType.suspicious:
        return '長時間ドア付近に滞在している人物がいます';
      case EventType.family:
        return '家族が帰宅しました';
      case EventType.other:
        return '不明な訪問者';
    }
  }

  Future<List<EventModel>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _events;
  }

  Future<EventModel?> getEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}

class NeighborhoodRepository {
  final List<NeighborhoodAlertModel> _alerts = [];

  NeighborhoodRepository() {
    _generateMockAlerts();
  }

  void _generateMockAlerts() {
    final now = DateTime.now();
    final random = Random();
    
    // Base location (approx Tokyo impl or arbitrary)
    const baseLat = 35.6812;
    const baseLng = 139.7671;

    for (int i = 0; i < 10; i++) {
        final cat = AlertCategory.values[random.nextInt(AlertCategory.values.length)];
      _alerts.add(NeighborhoodAlertModel(
        id: 'alert_$i',
        timestamp: now.subtract(Duration(hours: random.nextInt(48))),
        category: cat,
        meshId: 'mesh_${random.nextInt(100)}',
        title: _generateTitle(cat),
        description: '近隣で不審な行動が検知されました。ご注意ください。',
        severity: _determineSeverity(cat),
        lat: baseLat + (random.nextDouble() - 0.5) * 0.01,
        lng: baseLng + (random.nextDouble() - 0.5) * 0.01,
      ));
    }
  }
  
  String _generateTitle(AlertCategory cat) {
      switch(cat) {
          case AlertCategory.suspicious: return '不審者情報';
          case AlertCategory.theft: return '置き配盗難疑い';
          case AlertCategory.repeated_ring: return '執拗な呼び鈴';
          case AlertCategory.night: return '深夜の徘徊';
      }
  }
  
  AlertSeverity _determineSeverity(AlertCategory cat) {
      if (cat == AlertCategory.theft || cat == AlertCategory.night) return AlertSeverity.critical;
      if (cat == AlertCategory.suspicious) return AlertSeverity.warn;
      return AlertSeverity.info;
  }

  Future<List<NeighborhoodAlertModel>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _alerts;
  }
}
