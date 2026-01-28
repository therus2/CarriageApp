class DictionaryItem {
  final int id;
  final String name;

  DictionaryItem({required this.id, required this.name});

  factory DictionaryItem.fromJson(Map<String, dynamic> json) {
    return DictionaryItem(
      id: json['id'],
      name: json['name'] ?? json['type_name'] ?? json['firm_name'] ?? 'Неизвестно',
    );
  }
}