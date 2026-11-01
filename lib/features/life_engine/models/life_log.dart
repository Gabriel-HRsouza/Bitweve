class LifeLog {
  final String id;
  final String saveId;
  final int age;
  final int year;
  final String category;
  final String textContent;
  final String icon;
  final String accentColor;
  final DateTime createdAt;

  const LifeLog({
    required this.id,
    required this.saveId,
    required this.age,
    required this.year,
    required this.category,
    required this.textContent,
    this.icon = 'star',
    this.accentColor = '#6366F1',
    required this.createdAt,
  });
}
