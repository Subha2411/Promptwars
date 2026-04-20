/// A smart contextual alert shown to the user.
class SmartAlert {
  final String id;
  final String message;
  final AlertType alertType;
  final String icon;
  final AlertSeverity severity;
  final DateTime createdAt;
  bool isActive;

  SmartAlert({
    required this.id,
    required this.message,
    required this.alertType,
    required this.icon,
    this.severity = AlertSeverity.info,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'alert_type': alertType.name,
        'icon': icon,
        'severity': severity.name,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  factory SmartAlert.fromJson(Map<String, dynamic> json) {
    return SmartAlert(
      id: json['id'] as String,
      message: json['message'] as String,
      alertType: AlertType.values.firstWhere(
        (e) => e.name == json['alert_type'],
        orElse: () => AlertType.general,
      ),
      icon: json['icon'] as String? ?? '📢',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

enum AlertType { crowd, food, restroom, group, route, general }

enum AlertSeverity { info, warning, critical }
