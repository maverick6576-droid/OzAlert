class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.isChecked = false,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isChecked,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isChecked': isChecked,
    };
  }
}
