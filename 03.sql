/*
 * Q1: “Students with grade 1 from some course”
 */
SELECT Student.ID, Student.Name, CourseStudent.Grade
FROM CourseStudent
         INNER JOIN Student
                    ON CourseStudent.StudentID = Student.ID
WHERE CourseStudent.Grade = 1;

/*
 * Q2: “Students of ‘Video retrieval’ course who
 *      already have a grade”
 */
SELECT Student.ID, Student.Name, CourseStudent.Grade
FROM CourseStudent
         INNER JOIN Student
                    ON CourseStudent.StudentID = Student.ID
         INNER JOIN Course
                    ON CourseStudent.CourseID = Course.ID
WHERE Course.Name = 'Video retrieval'
  AND CourseStudent.Grade IS NOT NULL;

/*
 * Q3: “Students who have a diploma thesis
 *      supervisor with name Jane”
 */
SELECT Student.ID, Student.Name
FROM Student
         INNER JOIN Teacher
                    ON Student.DT_SupervisorID = Teacher.ID
WHERE Teacher.Name = 'Jane';


/*
 * Q4: “Students with the same bachelor and
 *      diploma thesis supervisor”
 */
SELECT Student.ID, Student.Name
FROM Student
         INNER JOIN Teacher
                    ON Student.DT_SupervisorID = Teacher.ID
                        AND Student.BT_SupervisorID = Teacher.ID;


/*
 * Q5: “Teachers supervising both the bachelor
 *      and diploma thesis of a student”
 */
SELECT Teacher.*
FROM Teacher
WHERE EXISTS(SELECT * FROM Student WHERE Student.BT_SupervisorID = Teacher.ID)
  AND EXISTS(SELECT * FROM Student WHERE Student.DT_SupervisorID = Teacher.ID);


/*
 * Q6: “Teachers with the same name as their
 *      supervised student”
 */
SELECT Teacher.ID, Student.ID, Student.Name AS Name
FROM Student
         INNER JOIN Teacher
                    ON Student.Name = Teacher.Name
                        AND (Student.DT_SupervisorID = Teacher.ID
                            OR Student.BT_SupervisorID = Teacher.ID);

/*
 * Q7: “Courses with the number of course
 *      students, sorted by the number of students”
 */
SELECT Course.Name, (SELECT COUNT(*) FROM CourseStudent WHERE CourseStudent.CourseID = Course.ID) AS Students
FROM Course
ORDER BY Students;


/*
 * Q8: “Courses with the number of course students
 *      without grades, sorted by the number of students”
 */
SELECT Course.Name,
       (SELECT COUNT(*) FROM CourseStudent WHERE CourseStudent.CourseID = Course.ID AND Grade IS NULL) AS Students
FROM Course
ORDER BY Students;


/*
 * Q9: “Students without courses”
 */
SELECT Student.*
FROM Student
WHERE NOT Student.ID IN (SELECT CourseStudent.StudentID FROM CourseStudent);


/*
 * Q10: “All students with the highest number of
 *       courses”
 */
SELECT Student.ID, Student.Name, CourseCount.MaxCount
FROM Student,
    (SELECT MAX(StudentCourseCount.Count) AS MaxCount
     FROM (SELECT COUNT(*) AS Count
           FROM CourseStudent
           GROUP BY StudentID
          ) AS StudentCourseCount
    ) AS CourseCount
WHERE CourseCount.MaxCount = (SELECT COUNT(*)
                              FROM CourseStudent
                              WHERE CourseStudent.StudentID = Student.ID
                             );

/*
 * Q11: “Students at courses of Tom”
 */
SELECT Student.ID, Student.Name
FROM Student
    INNER JOIN CourseStudent
        ON Student.ID=CourseStudent.StudentID
WHERE CourseStudent.CourseID IN (SELECT Course.ID
                                 FROM Course
                                    INNER JOIN Teacher
                                        ON Teacher.ID=Course.TeacherID
                                 WHERE Teacher.Name='Tom'
                                );