// import 'package:sqflite/sqflite.dart';

// import 'models.dart';

// class DatabaseHelper  {
//   late Database database;
//     List semesters = [];
//     List courses = [];
//     late var cumulativeGpa;
//     late var cumulativeGrade;

//   DatabaseHelper() {
//     createDatabase();
//   }

//   void createDatabase() async {
//     database = await openDatabase(
//       'gpa_center.db',
//       version: 1,
//       onCreate: (database, version) async {
//         await database.execute(
//             'CREATE TABLE "course" ("id"	INTEGER,"course_name"	TEXT NOT NULL,"credit_hours"	INTEGER NOT NULL,"percentage"	REAL NOT NULL,"grade"	REAL NOT NULL,"semester_id"	INTEGER NOT NULL,PRIMARY KEY("id"))');
//         await database.execute(
//             'CREATE TABLE "semester" ("id"	INTEGER,"semester_name"	TEXT NOT NULL,PRIMARY KEY("id"))');
//         print('database created');
//       },
//       onOpen: (database) {
//         print('database opend');
//       },
//     );
//   }

//   Future<void> showSemesters() async {
//     semesters = [];
//     var value = await database.rawQuery("""
// SELECT semester.id,semester.semester_name,
//        printf("%.2f",COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0)) AS GPA,
//       CASE
//            WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 3.6 THEN 'A'
// 		   WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 3 THEN 'B'
// 		   WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 2.4 THEN 'C'
// 		   WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 2 THEN 'D'
//           ELSE 'F'
//       END AS grade
// FROM semester
// LEFT JOIN course ON semester.id = course.semester_id
// GROUP BY semester.semester_name;
// """);
//     for (var element in value) {
//       semesters.add(Semester.fromJson(element));
//     }
//   }

//   Future<void> showCumulativeData() async {
//     var value = await database.rawQuery("""
// SELECT printf("%.2f", COALESCE(SUM(credit_hours*grade)/SUM(credit_hours),0)) AS GPA ,
// 	CASE
// 	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 3.6 THEN "A"
// 	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 3 THEN "B"
// 	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 2.4 THEN "C"
// 	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 2 THEN "D"
//     ELSE "F"
//     END AS grade
// FROM course
// """);
// cumulativeGpa = value[0]["GPA"];
// cumulativeGrade = value[0]["grade"];
//   }

//   Future<void> showCourses(int id) async {
//     courses = [];
//     var value = await database.rawQuery("""
// SELECT id,course_name, credit_hours, percentage,
// CASE
// 	WHEN grade = 4 THEN "A+"
// 	WHEN grade = 3.6 THEN "A"
// 	WHEN grade = 3.3 THEN "B+"
// 	WHEN grade = 3 THEN "B"
// 	WHEN grade = 2.6 THEN "C+"
// 	WHEN grade = 2.4 THEN "C"
// 	WHEN grade = 2.2 THEN "D+"
// 	WHEN grade = 2 THEN "D"
// 	ELSE "F" END AS grade
// FROM course
// WHERE semester_id=$id;
// """);
//     for (var element in value) {
//       courses.add(Course.fromJson(element));
//     }
//     print(value);

//   }

//   void insertSemester(String semesterName) async {
//     await database
//         .transaction((txn) => txn.rawInsert(
//             'INSERT INTO semester (semester_name) VALUES("$semesterName")'))
//         .then((value) {
//       showSemesters();
//       showCumulativeData();
//     });
//   }

//   void insertCourse({
//     required String courseName,
//     required String creditHours,
//     required String percentage,
//     required double grade,
//     required int semesterId,
//   }) async {
//     await database
//         .transaction((txn) => txn.rawInsert(
//             'INSERT INTO course (course_name,credit_hours,percentage,grade,semester_id) VALUES("$courseName",$creditHours,$percentage,$grade,$semesterId)'))
//         .then((value) {
//       showCourses(semesterId);
//       showSemesters();
//       showCumulativeData();
//     });
//   }
// }
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  intialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'gpa_center.db');
    Database mydb = await openDatabase(path, onCreate: _onCreate, version: 1);
    return mydb;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE "course" ("id"	INTEGER,"course_name"	TEXT NOT NULL,"credit_hours"	INTEGER NOT NULL,"percentage"	REAL NOT NULL,"grade"	REAL NOT NULL,"semester_id"	INTEGER NOT NULL,PRIMARY KEY("id"))');
    await db.execute(
        'CREATE TABLE "semester" ("id"	INTEGER,"semester_name"	TEXT NOT NULL,PRIMARY KEY("id"))');
    print(" onCreate =====================================");
  }

  Future<List<Map>> getSemesterData() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery("""
    SELECT semester.id,semester.semester_name,
        printf("%.2f",COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0)) AS GPA,
        CASE
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.60 THEN "A"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.00 THEN "B"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.40 THEN "C"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.00 THEN "D"          
        ELSE 'F'
        END AS grade
    FROM semester
    LEFT JOIN course ON semester.id = course.semester_id
    GROUP BY semester.semester_name;
    """);
    return response;
  }

  Future<List<Map>> getCourseData(int id) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery("""
      SELECT id,course_name, credit_hours, percentage,
      CASE
        WHEN grade = 4 THEN "A+"
        WHEN grade = 3.6 THEN "A"
        WHEN grade = 3.3 THEN "B+"
        WHEN grade = 3 THEN "B"
        WHEN grade = 2.6 THEN "C+"
        WHEN grade = 2.4 THEN "C"
        WHEN grade = 2.2 THEN "D+"
        WHEN grade = 2 THEN "D"
        ELSE "F" END AS grade
      FROM course
      WHERE semester_id=$id;
    """);
    return response;
  }

  Future<List<Map>> getSemesterGradeData(int id) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery("""
      SELECT printf("%.2f", COALESCE(SUM(credit_hours*grade)/SUM(credit_hours),0)) AS GPA ,
        CASE
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.60 THEN "A"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.00 THEN "B"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.40 THEN "C"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.00 THEN "D"          
        ELSE "F"
          END AS grade,
        SUM(credit_hours) as credit_hours
      FROM course
      WHERE semester_id=$id;
    """);
    return response;
  }

  Future<List<Map>> getCumulativeData() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery("""
      SELECT printf("%.2f", COALESCE(SUM(credit_hours*grade)/SUM(credit_hours),0)) AS GPA ,
        CASE
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.60 THEN "A"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.00 THEN "B"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.40 THEN "C"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.00 THEN "D"          
        ELSE "F"
          END AS grade
      FROM course
    """);
    return response;
  }

  insertCourse({
    required String courseName,
    required String creditHours,
    required String percentage,
    required double grade,
    required int semesterId,
  }) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(
        'INSERT INTO course (course_name,credit_hours,percentage,grade,semester_id) VALUES("$courseName",$creditHours,$percentage,$grade,$semesterId)');
    return response;
  }

  insertSemester({
    required String semesterName,
  }) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(
        'INSERT INTO semester (semester_name) VALUES("$semesterName")');
    return response;
  }

  updateSemester({required String semesterName, required int id}) async {
    Database? mydb = await db;
    await mydb!.rawUpdate('''
      UPDATE semester 
      SET semester_name = "$semesterName"
      WHERE id = $id;
    ''');
  }

  updateCourse({
    required String courseName,
    required int id,
    required int creditHour,
    required double percentage,
    required double grade,
  }) async {
    Database? mydb = await db;
    await mydb!.rawUpdate('''
      UPDATE course
      SET course_name = "$courseName", credit_hours = $creditHour, percentage = $percentage, grade = $grade
      WHERE id = $id
    ''');
  }

  deleteSemester(int id) async {
    Database? mydb = await db;
    await mydb!.rawDelete('DELETE FROM semester WHERE id = $id;');
    await mydb.rawDelete('DELETE FROM course WHERE semester_id = $id;');
  }

  deleteCourse(int id) async {
    Database? mydb = await db;
    await mydb!.rawDelete('DELETE FROM course WHERE id = $id;');
  }

// SELECT
// DELETE
// UPDATE
// INSERT
}
