enum EventType { delivery, sales, suspicious, family, other }
enum RiskLevel { low, mid, high }
enum PackageCheckStatus { match, mismatch, unknown, none }
enum EventStatus { unread, read }

class EventModel {
  final String id;
  final String deviceId;
  final DateTime timestamp;
  final EventType type;
  final RiskLevel risk;
  final String summary;
  final String transcript;
  final String aiReply;
  final bool hasImage;
  final String? imageUrl;
  final bool hasAudio;
  final String? audioUrl;
  final PackageCheckStatus packageCheck;
  final EventStatus status;
  final String locationMesh;

  EventModel({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    required this.type,
    required this.risk,
    required this.summary,
    required this.transcript,
    required this.aiReply,
    required this.hasImage,
    this.imageUrl,
    required this.hasAudio,
    this.audioUrl,
    required this.packageCheck,
    required this.status,
    required this.locationMesh,
  });

  EventModel copyWith({EventStatus? status}) {
    return EventModel(
      id: id,
      deviceId: deviceId,
      timestamp: timestamp,
      type: type,
      risk: risk,
      summary: summary,
      transcript: transcript,
      aiReply: aiReply,
      hasImage: hasImage,
      imageUrl: imageUrl,
      hasAudio: hasAudio,
      audioUrl: audioUrl,
      packageCheck: packageCheck,
      status: status ?? this.status,
      locationMesh: locationMesh,
    );
  }
}

enum AlertCategory { suspicious, theft, repeated_ring, night }
enum AlertSeverity { info, warn, critical }

class NeighborhoodAlertModel {
  final String id;
  final DateTime timestamp;
  final AlertCategory category;
  final String meshId;
  final String title;
  final String description;
  final AlertSeverity severity;
  final double lat;
  final double lng;

  NeighborhoodAlertModel({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.meshId,
    required this.title,
    required this.description,
    required this.severity,
    required this.lat,
    required this.lng,
  });
}
