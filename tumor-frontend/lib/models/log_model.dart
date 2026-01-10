class LogModel {
  final int id;
  final String username;
  final String role;
  final String activity;
  final String details;
  final String timestamp;

  LogModel({
    required this.id,
    required this.username,
    required this.role,
    required this.activity,
    required this.details,
    required this.timestamp,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? "Unknown",
      role: json['role'] ?? "-",
      activity: json['activity'] ?? "-",
      details: json['details'] ?? "-",
      timestamp: json['timestamp'] ?? "-",
    );
  }
}
