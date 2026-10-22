class GuideStep {
  final int number;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String tip;
  final String tipEn;
  final String? officialUrl;
  final String? officialUrlLabel;
  final String? officialUrlLabelEn;

  GuideStep({
    required this.number,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.tip,
    required this.tipEn,
    this.officialUrl,
    this.officialUrlLabel,
    this.officialUrlLabelEn,
  });

  factory GuideStep.fromJson(Map<String, dynamic> json) {
    return GuideStep(
      number: json['number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      tipEn: json['tipEn'] as String? ?? '',
      officialUrl: json['officialUrl'] as String?,
      officialUrlLabel: json['officialUrlLabel'] as String?,
      officialUrlLabelEn: json['officialUrlLabelEn'] as String?,
    );
  }
  GuideStep copyWith({
    int? number,
    String? title,
    String? titleEn,
    String? description,
    String? descriptionEn,
    String? tip,
    String? tipEn,
    String? officialUrl,
    String? officialUrlLabel,
    String? officialUrlLabelEn,
  }) {
    return GuideStep(
      number: number ?? this.number,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      tip: tip ?? this.tip,
      tipEn: tipEn ?? this.tipEn,
      officialUrl: officialUrl ?? this.officialUrl,
      officialUrlLabel: officialUrlLabel ?? this.officialUrlLabel,
      officialUrlLabelEn: officialUrlLabelEn ?? this.officialUrlLabelEn,
    );
  }
}

class ServiceComparison {
  final String id;
  final String name;
  final String tagline;
  final String taglineEn;
  final Map<String, String> keyAttributes;
  final List<String> pros;
  final List<String> prosEn;
  final List<String> cons;
  final List<String> consEn;
  final String verdict;
  final String verdictEn;
  final String? officialUrl;
  final String? officialUrlLabel;
  final String? officialUrlLabelEn;

  ServiceComparison({
    required this.id,
    required this.name,
    required this.tagline,
    required this.taglineEn,
    required this.keyAttributes,
    required this.pros,
    required this.prosEn,
    required this.cons,
    required this.consEn,
    required this.verdict,
    required this.verdictEn,
    this.officialUrl,
    this.officialUrlLabel,
    this.officialUrlLabelEn,
  });

  factory ServiceComparison.fromJson(Map<String, dynamic> json) {
    final attrs = <String, String>{};
    const reservedKeys = [
      'id', 'name', 'tagline', 'taglineEn', 'pros', 'prosEn', 'cons', 'consEn',
      'verdict', 'verdictEn', 'officialUrl', 'officialUrlLabel', 'officialUrlLabelEn'
    ];
    // Extract dynamic attributes (fees, coverage, etc.)
    for (final key in json.keys) {
      if (!reservedKeys.contains(key)) {
        attrs[key] = json[key]?.toString() ?? '';
      }
    }

    return ServiceComparison(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      taglineEn: json['taglineEn'] as String? ?? '',
      keyAttributes: attrs,
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      prosEn: (json['prosEn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      cons: (json['cons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      consEn: (json['consEn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      verdict: json['verdict'] as String? ?? '',
      verdictEn: json['verdictEn'] as String? ?? '',
      officialUrl: json['officialUrl'] as String?,
      officialUrlLabel: json['officialUrlLabel'] as String?,
      officialUrlLabelEn: json['officialUrlLabelEn'] as String?,
    );
  }
  ServiceComparison copyWith({
    String? id,
    String? name,
    String? tagline,
    String? taglineEn,
    Map<String, String>? keyAttributes,
    List<String>? pros,
    List<String>? prosEn,
    List<String>? cons,
    List<String>? consEn,
    String? verdict,
    String? verdictEn,
    String? officialUrl,
    String? officialUrlLabel,
    String? officialUrlLabelEn,
  }) {
    return ServiceComparison(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      taglineEn: taglineEn ?? this.taglineEn,
      keyAttributes: keyAttributes ?? this.keyAttributes,
      pros: pros ?? this.pros,
      prosEn: prosEn ?? this.prosEn,
      cons: cons ?? this.cons,
      consEn: consEn ?? this.consEn,
      verdict: verdict ?? this.verdict,
      verdictEn: verdictEn ?? this.verdictEn,
      officialUrl: officialUrl ?? this.officialUrl,
      officialUrlLabel: officialUrlLabel ?? this.officialUrlLabel,
      officialUrlLabelEn: officialUrlLabelEn ?? this.officialUrlLabelEn,
    );
  }
}

class CategoryGuide {
  final String id;
  final String title;
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final List<GuideStep> steps;
  final List<ServiceComparison> comparisons;

  CategoryGuide({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.subtitle,
    required this.subtitleEn,
    required this.steps,
    required this.comparisons,
  });

  factory CategoryGuide.fromJson(Map<String, dynamic> json) {
    return CategoryGuide(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      subtitleEn: json['subtitleEn'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => GuideStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comparisons: (json['comparisons'] as List<dynamic>?)
              ?.map((e) => ServiceComparison.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  CategoryGuide copyWith({
    String? id,
    String? title,
    String? titleEn,
    String? subtitle,
    String? subtitleEn,
    List<GuideStep>? steps,
    List<ServiceComparison>? comparisons,
  }) {
    return CategoryGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      subtitle: subtitle ?? this.subtitle,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      steps: steps ?? this.steps,
      comparisons: comparisons ?? this.comparisons,
    );
  }
}
