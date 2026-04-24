class NotificationModel {
  final int id;
  final String title;
  final String message;
  final int? analysisId;
  bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.analysisId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      analysisId: json['analysis_id'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
    );
  }
}
