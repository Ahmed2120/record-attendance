class VacationDay {
  final int? id;
  final DateTime date;

  VacationDay({this.id, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }

  factory VacationDay.fromMap(Map<String, dynamic> map) {
    return VacationDay(
      id: map['id'],
      date: DateTime.parse(map['date']),
    );
  }
}
