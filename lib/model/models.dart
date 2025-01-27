abstract class Collage {
  final int id;
  final String name;
  final String grade;
  final double gpa;
  Collage(
      {required this.id,
      required this.name,
      required this.grade,
      required this.gpa});
}

class Course extends Collage {
  final int creditHours;
  Course(
      {required this.creditHours,
      required super.id,
      required super.name,
      required super.grade,
      required super.gpa});
  factory Course.fromJson(json) {
    return Course(
      creditHours: json["credit_hours"],
      id: json["id"],
      name: json["course_name"],
      grade: json["grade"],
      gpa: json["percentage"],
    );
  }
}

class Semester extends Collage {
  Semester(
      {required super.id,
      required super.name,
      required super.grade,
      required super.gpa,});
  factory Semester.fromJson(json) {
    return Semester(
      id: json["id"],
      name: json["semester_name"],
      grade: json["grade"],
      gpa: double.parse(json["GPA"]),
    );
  }
}
