// this query is to select all semesters and there GPA and grade
// if there is no course in the semester we make its GPA 0
String q1 = """
SELECT semester.id,semester.semester_name, 
       printf("%.2f",COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0)) AS GPA,
      CASE 
           WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 3.6 THEN 'A' 
		   WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 3 THEN 'B' 
		   WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 2.4 THEN 'C' 
		   WHEN COALESCE((SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)), 0) >= 2 THEN 'D' 
          ELSE 'F' 
      END AS grade
FROM semester
LEFT JOIN course ON semester.id = course.semester_id
GROUP BY semester.semester_name;
""";
// this query is to select the overall GPA and the overall grade
String q2 = """
SELECT SUM(credit_hours*grade)/SUM(credit_hours) AS GPA ,
	CASE
	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 3.6 THEN "A" 
	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 3 THEN "B" 
	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 2.4 THEN "C" 
	WHEN (SUM(course.credit_hours * course.grade) / SUM(course.credit_hours)) >= 2 THEN "D" 
    ELSE "F"
    END AS grade
FROM course
""";

// this query is to delete a semester and course related to this semeter
String q3 = """
DELETE FROM course WHERE semester_id = 9;
DELETE FROM semester WHERE id = 9;
""";

// this query is to display all courses of a certain semester with credit hours and grade
String q4 = """
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
WHERE semester_id=1;
""";
