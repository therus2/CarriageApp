class StationConfig {
  final int id;
  final int tracksCount;
  final DateTime createdAt;

  StationConfig({
    required this.id,
    required this.tracksCount,
    required this.createdAt,
  });

  factory StationConfig.fromJson(Map<String, dynamic> json) {
    return StationConfig(
      id: json['id'],
      tracksCount: json['tracks_count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracks_count': tracksCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
