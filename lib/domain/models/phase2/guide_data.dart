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
}
