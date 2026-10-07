class Student {
  final String id;
  final String name;
  final String registrationNumber;
  final bool isPresent;
  final DateTime? date;
  final String module;
  final List<DateTime> attendanceDates;

  Student({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.isPresent,
    required this.date,
    required this.module,
    required this.attendanceDates,
  });

  Student copyWith({bool? isPresent}) {
    return Student(
      id: id,
      name: name,
      registrationNumber: registrationNumber,
      isPresent: isPresent ?? this.isPresent,
      date: date,
      module: module,
      attendanceDates: attendanceDates,
    );
  }
}
