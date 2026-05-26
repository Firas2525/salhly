class NotificationModel {
  final int id;
  final String title;
  final String description;
  final String? type;
  final String? targetType;
  final int? targetId;
  final String? actionScreen;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    this.type,
    this.targetType,
    this.targetId,
    this.actionScreen,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      targetType: json['target_type'],
      targetId: json['target_id'],
      actionScreen: json['action_screen'],
      data: json['data'],
      isRead: json['is_read'],
      readAt: json['read_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target_type': targetType,
      'target_id': targetId,
      'action_screen': actionScreen,
      'data': data,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    String? targetType,
    int? targetId,
    String? actionScreen,
    Map<String, dynamic>? data,
    bool? isRead,
    String? readAt,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      actionScreen: actionScreen ?? this.actionScreen,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationsResponse {
  final bool status;
  final List<NotificationModel> data;
  final Map<String, dynamic> pagination;
  final int unreadCount;

  NotificationsResponse({
    required this.status,
    required this.data,
    required this.pagination,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<dynamic> dataList = rawData is List
        ? rawData
        : (rawData is Map ? (rawData['data'] as List? ?? []) : []);
    final paginationMap = json['pagination'] ?? (rawData is Map ? rawData['pagination'] : {});
    final unreadCountValue = json['unread_count'] ?? (rawData is Map ? rawData['unread_count'] : 0);

    return NotificationsResponse(
      status: json['status'],
      data: dataList.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: (paginationMap ?? {}) as Map<String, dynamic>,
      unreadCount: unreadCountValue is int ? unreadCountValue : int.tryParse(unreadCountValue.toString()) ?? 0,
    );
  }
}