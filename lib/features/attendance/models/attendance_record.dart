class AttendanceRecord {
  final int? id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final int lateMinutes;
  final int workingMinutes;
  final String notes;

  AttendanceRecord({
    this.id,
    required this.checkInTime,
    this.checkOutTime,
    this.lateMinutes = 0,
    this.workingMinutes = 0,
    this.notes = '',
  });

  AttendanceRecord copyWith({
    int? id,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    int? lateMinutes,
    int? workingMinutes,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      workingMinutes: workingMinutes ?? this.workingMinutes,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'check_in': checkInTime.toIso8601String(),
      'check_out': checkOutTime?.toIso8601String(),
      'late_minutes': lateMinutes,
      'working_minutes': workingMinutes,
      'notes': notes,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      checkInTime: DateTime.parse(map['check_in']),
      checkOutTime: map['check_out'] != null ? DateTime.parse(map['check_out']) : null,
      lateMinutes: map['late_minutes'] ?? 0,
      workingMinutes: map['working_minutes'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }
}
