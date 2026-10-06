class LandingTask {
  final String id;
  final String title;
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final String phase; // 'pre_departure', 'first_48h', 'first_week'
  final int priority;
  final String? targetGuideCategory;
  final bool isCompleted;

  const LandingTask({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.subtitle,
    required this.subtitleEn,
    required this.phase,
    required this.priority,
    this.targetGuideCategory,
    this.isCompleted = false,
  });

  LandingTask copyWith({
    String? id,
    String? title,
    String? titleEn,
    String? subtitle,
    String? subtitleEn,
    String? phase,
    int? priority,
    String? targetGuideCategory,
    bool? isCompleted,
  }) {
    return LandingTask(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      subtitle: subtitle ?? this.subtitle,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      phase: phase ?? this.phase,
      priority: priority ?? this.priority,
      targetGuideCategory: targetGuideCategory ?? this.targetGuideCategory,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory LandingTask.fromJson(Map<String, dynamic> json, {bool isCompleted = false}) {
    return LandingTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? (json['title'] as String? ?? ''),
      subtitle: json['subtitle'] as String? ?? '',
      subtitleEn: json['subtitleEn'] as String? ?? (json['subtitle'] as String? ?? ''),
      phase: json['phase'] as String? ?? 'pre_departure',
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      targetGuideCategory: json['targetGuideCategory'] as String?,
      isCompleted: isCompleted,
    );
  }
}
