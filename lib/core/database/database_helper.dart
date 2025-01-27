import 'package:flutter/material.dart';
import 'package:gpa_center/core/database/database_queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initializeDB();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initializeDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'gpa_center.db');
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  _onCreate(Database db, int version) async {
    await db.execute(DatabaseQueries.createCourseTableQuery);
    await db.execute(DatabaseQueries.createSemesterTableQuery);
    debugPrint("${"=" * 10} Database Created ${"=" * 10}");
  }

  Future<List<Map>> getSemesterData() async => await db.then(
      (database) => database!.rawQuery(DatabaseQueries.getSemesterDataQuery));

  Future<List<Map>> getCourseData(int id) async => await db.then(
      (database) => database!.rawQuery(DatabaseQueries.getCourseDataQuery(id)));

  Future<List<Map>> getSemesterGradeData(int id) async => db.then((database) =>
      database!.rawQuery(DatabaseQueries.getSemesterGradeDataQuery(id)));

  Future<List<Map>> getCumulativeData() async => db.then(
      (database) => database!.rawQuery(DatabaseQueries.getCumulativeDataQuery));

  insertCourse({
    required String courseName,
    required String creditHours,
    required String percentage,
    required double grade,
    required int semesterId,
  }) async =>
      await db.then((database) => database!.rawInsert(
          DatabaseQueries.insertCourseQuery(
              courseName, creditHours, percentage, grade, semesterId)));

  insertSemester({
    required String semesterName,
  }) async =>
      await db.then((database) => database!
          .rawInsert(DatabaseQueries.insertSemesterQuery(semesterName)));

  updateSemester({required String semesterName, required int id}) async =>
      await db.then((database) => database!
          .rawUpdate(DatabaseQueries.updateSemesterQuery(semesterName, id)));

  updateCourse({
    required String courseName,
    required int id,
    required int creditHour,
    required double percentage,
    required double grade,
  }) async =>
      await db.then((database) => database!.rawUpdate(
          DatabaseQueries.updateCourseQuery(
              courseName, creditHour, percentage, grade, id)));

  deleteSemester(int id) async => await db.then((database) =>
      database!.rawDelete(DatabaseQueries.deleteSemesterQuery(id)));

  deleteCourse(int id) async => await db.then(
      (database) => database!.rawDelete(DatabaseQueries.deleteCourseQuery(id)));

}
