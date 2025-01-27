class DatabaseQueries {
  static const String createCourseTableQuery = """
    CREATE TABLE "course" 
    ("id"	INTEGER,"course_name"	TEXT NOT NULL,"credit_hours"	INTEGER NOT NULL,"percentage"	REAL NOT NULL,"grade"	REAL NOT NULL,"semester_id"	INTEGER NOT NULL,PRIMARY KEY("id"));
  """;
  static const String createSemesterTableQuery = """
  CREATE TABLE "semester" 
  ("id"	INTEGER,"semester_name"	TEXT NOT NULL,PRIMARY KEY("id"));
  """;

  static const String getSemesterDataQuery = """
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
  """;

  static String getCourseDataQuery(int id) => """
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
    """;
  static String getSemesterGradeDataQuery(int id) => """
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
    """;

  static const String getCumulativeDataQuery = """
      SELECT printf("%.2f", COALESCE(SUM(credit_hours*grade)/SUM(credit_hours),0)) AS GPA ,
        CASE
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.60 THEN "A"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 3.00 THEN "B"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.40 THEN "C"
      	WHEN round((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)),2) >= 2.00 THEN "D"          
        ELSE "F"
          END AS grade
      FROM course;
    """;
  static String insertCourseQuery(String courseName, String creditHours,
          String percentage, double grade, int semesterId) =>
      """
  INSERT INTO course 
    (course_name,credit_hours,percentage,grade,semester_id)
    VALUES("$courseName",$creditHours,$percentage,$grade,$semesterId);
  """;

  static String insertSemesterQuery(String semesterName) => """
    INSERT INTO semester 
    (semester_name) VALUES("$semesterName")
  """;

  static String updateSemesterQuery(String semesterName, int id) => """
    UPDATE semester 
    SET semester_name = "$semesterName"
    WHERE id = $id;
  """;

  static String updateCourseQuery(String courseName, int creditHour,
          double percentage, double grade, int id) =>
      """
    UPDATE course
    SET course_name = "$courseName", credit_hours = $creditHour, percentage = $percentage, grade = $grade
    WHERE id = $id
  """;

  static String deleteSemesterQuery(int id) => """
    DELETE FROM semester WHERE id = $id;
    DELETE FROM course WHERE semester_id = $id;
  """;

  static String deleteCourseQuery(int id) => """
    DELETE FROM course WHERE id = $id;
  """;
}
