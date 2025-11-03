DROP TABLE STUDENT;

CREATE TABLE STUDENT (
    ROLLNO NUMBER PRIMARY KEY,
    NAME   VARCHAR2(50),
    AGE    NUMBER,
    MARK1  NUMBER,
    MARK2  NUMBER,
    MARK3  NUMBER,
    TOTAL  NUMBER
);

INSERT INTO STUDENT VALUES ( 1,
                             'Aman',
                             22,
                             25,
                             30,
                             35,
                             0 );

INSERT INTO STUDENT VALUES ( 2,
                             'Riya',
                             24,
                             30,
                             35,
                             40,
                             0 );

INSERT INTO STUDENT VALUES ( 3,
                             'Karan',
                             26,
                             40,
                             45,
                             35,
                             0 );

INSERT INTO STUDENT VALUES ( 4,
                             'Simran',
                             23,
                             38,
                             29,
                             28,
                             0 );

INSERT INTO STUDENT VALUES ( 5,
                             'Neha',
                             27,
                             45,
                             40,
                             35,
                             0 );
-- Create second table
CREATE TABLE Student_minor AS SELECT * FROM Student WHERE 1=2;

DECLARE
    CURSOR c1 IS SELECT * FROM Student WHERE age < 25;
    v_rec c1%ROWTYPE;
BEGIN
    FOR v_rec IN c1 LOOP
        INSERT INTO Student_minor VALUES v_rec;
        DELETE FROM Student WHERE Rollno = v_rec.Rollno;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Records moved successfully.');
END;
/

DECLARE
    CURSOR c2 IS SELECT Rollno, mark1, mark2, mark3 FROM Student;
    v_roll Student.Rollno%TYPE;
    v_total NUMBER;
BEGIN
    FOR rec IN c2 LOOP
        v_total := rec.mark1 + rec.mark2 + rec.mark3;
        UPDATE Student SET total = v_total WHERE Rollno = rec.Rollno;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total marks updated successfully.');
END;
/
DECLARE
    v_highest NUMBER;
    v_lowest NUMBER;
BEGIN
    SELECT MAX(total), MIN(total) INTO v_highest, v_lowest FROM Student;

    DBMS_OUTPUT.PUT_LINE('Highest Total: ' || v_highest);
    DBMS_OUTPUT.PUT_LINE('Lowest Total: ' || v_lowest);

    DBMS_OUTPUT.PUT_LINE('---Highest Scorer(s)---');
    FOR rec IN (SELECT * FROM Student WHERE total = v_highest) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.name || ' (' || rec.Rollno || ')');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('---Lowest Scorer(s)---');
    FOR rec IN (SELECT * FROM Student WHERE total = v_lowest) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.name || ' (' || rec.Rollno || ')');
    END LOOP;
END;
/

DECLARE
    CURSOR c5 IS SELECT total FROM Student;
    v_sum NUMBER := 0;
    v_count NUMBER := 0;
    v_avg NUMBER;
BEGIN
    FOR rec IN c5 LOOP
        v_sum := v_sum + rec.total;
        v_count := v_count + 1;
    END LOOP;

    v_avg := v_sum / v_count;
    DBMS_OUTPUT.PUT_LINE('Average total marks = ' || v_avg);
END;
/


CREATE OR REPLACE PROCEDURE get_student_details(p_rollno IN NUMBER) IS
    CURSOR c6 (rno NUMBER) IS SELECT * FROM Student WHERE Rollno = rno;
    v_rec c6%ROWTYPE;
BEGIN
    OPEN c6(p_rollno);
    FETCH c6 INTO v_rec;
    IF c6%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Roll No: ' || v_rec.Rollno);
        DBMS_OUTPUT.PUT_LINE('Name: ' || v_rec.name);
        DBMS_OUTPUT.PUT_LINE('Age: ' || v_rec.age);
        DBMS_OUTPUT.PUT_LINE('Total: ' || v_rec.total);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No student found with Roll No ' || p_rollno);
    END IF;
    CLOSE c6;
END;
/
-- Execute
BEGIN
    get_student_details(2);
END;
/

DROP TABLE EMP;
CREATE TABLE EMP (
    empno NUMBER PRIMARY KEY,
    ename VARCHAR2(50),
    job VARCHAR2(30),
    sal NUMBER,
    deptno NUMBER
);

-- Sample data
INSERT INTO EMP VALUES (101, 'Amit', 'Manager', 60000, 10);
INSERT INTO EMP VALUES (102, 'Riya', 'Analyst', 50000, 10);
INSERT INTO EMP VALUES (103, 'Karan', 'Clerk', 30000, 20);
INSERT INTO EMP VALUES (104, 'Neha', 'Developer', 55000, 20);
INSERT INTO EMP VALUES (105, 'Simran', 'Tester', 40000, 10);
INSERT INTO EMP VALUES (106, 'Rohan', 'Manager', 70000, 30);
COMMIT;

DECLARE
    v_empno  EMP.empno%TYPE;
    v_name   EMP.ename%TYPE;
    v_job    EMP.job%TYPE;
    v_row    EMP%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('---Using %TYPE---');
    SELECT empno, ename, job INTO v_empno, v_name, v_job FROM EMP WHERE empno = 101;
    DBMS_OUTPUT.PUT_LINE('EmpNo: ' || v_empno || ', Name: ' || v_name || ', Job: ' || v_job);

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '---Using %ROWTYPE---');
    SELECT * INTO v_row FROM EMP WHERE empno = 102;
    DBMS_OUTPUT.PUT_LINE('EmpNo: ' || v_row.empno || ', Name: ' || v_row.ename || ', Job: ' || v_row.job);
END;
/


CREATE OR REPLACE FUNCTION get_emp_by_dept(p_deptno IN NUMBER)
RETURN VARCHAR2
IS
    CURSOR c_emp (dno NUMBER) IS
        SELECT empno, ename, job FROM EMP WHERE deptno = dno;

    v_emp c_emp%ROWTYPE;
    v_output VARCHAR2(4000) := '';
BEGIN
    OPEN c_emp(p_deptno);
    LOOP
        FETCH c_emp INTO v_emp;
        EXIT WHEN c_emp%NOTFOUND;
        v_output := v_output || 'EmpNo: ' || v_emp.empno ||
                     ', Name: ' || v_emp.ename ||
                     ', Job: ' || v_emp.job || CHR(10);
    END LOOP;
    CLOSE c_emp;

    RETURN v_output;
END;
/
-- Execute
DECLARE
    v_result VARCHAR2(4000);
BEGIN
    v_result := get_emp_by_dept(10);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
    FUNCTION top_n_employees(p_n NUMBER) RETURN VARCHAR2 IS
        CURSOR c_emp (n NUMBER) IS
            SELECT empno, ename, sal FROM (
                SELECT empno, ename, sal FROM EMP ORDER BY sal DESC
            ) WHERE ROWNUM <= n;

        v_rec c_emp%ROWTYPE;
        v_output VARCHAR2(4000) := '';
    BEGIN
        OPEN c_emp(p_n);
        LOOP
            FETCH c_emp INTO v_rec;
            EXIT WHEN c_emp%NOTFOUND;
            v_output := v_output || 'EmpNo: ' || v_rec.empno ||
                         ', Name: ' || v_rec.ename ||
                         ', Salary: ' || v_rec.sal || CHR(10);
        END LOOP;
        CLOSE c_emp;
        RETURN v_output;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE(top_n_employees(3));
END;
/




DECLARE
    PROCEDURE total_salary(p_n NUMBER) IS
        CURSOR c_emp (n NUMBER) IS
            SELECT sal FROM (
                SELECT sal FROM EMP ORDER BY empno
            ) WHERE ROWNUM <= n;

        v_sal EMP.sal%TYPE;
        v_total NUMBER := 0;
    BEGIN
        OPEN c_emp(p_n);
        LOOP
            FETCH c_emp INTO v_sal;
            EXIT WHEN c_emp%NOTFOUND;
            v_total := v_total + v_sal;
        END LOOP;
        CLOSE c_emp;
        DBMS_OUTPUT.PUT_LINE('Total salary of first ' || p_n || ' employees = ' || v_total);
    END;
BEGIN
    total_salary(4);
END;
/
-- Using the same EMP table as before
SELECT * FROM EMP;



DECLARE
    v_name  EMP.ename%TYPE;
    v_sal   EMP.sal%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Demonstrating Predefined Exceptions ---');

    -- TOO_MANY_ROWS (More than one employee with job 'Manager')
    BEGIN
        SELECT ename, sal INTO v_name, v_sal FROM EMP WHERE job = 'Manager';
        DBMS_OUTPUT.PUT_LINE('Employee: ' || v_name || ', Salary: ' || v_sal);
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Error: TOO_MANY_ROWS - Multiple Managers found.');
    END;

    -- NO_DATA_FOUND (No employee with job 'President')
    BEGIN
        SELECT ename, sal INTO v_name, v_sal FROM EMP WHERE job = 'President';
        DBMS_OUTPUT.PUT_LINE('Employee: ' || v_name || ', Salary: ' || v_sal);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: NO_DATA_FOUND - No employee with job President.');
    END;

    -- WHEN OTHERS (any other unexpected exception)
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Triggering WHEN OTHERS ---');
        -- Intentionally dividing by zero to raise a generic exception
        v_sal := 1000 / 0;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: WHEN OTHERS - ' || SQLERRM);
    END;
END;
/

DECLARE
    v_empno EMP.empno%TYPE := 999; -- Employee ID not in table
    v_sal   EMP.sal%TYPE;
    e_invalid_empno EXCEPTION; -- user-defined exception
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Demonstrating User-Defined Exception ---');

    SELECT sal INTO v_sal FROM EMP WHERE empno = v_empno;

    IF v_sal IS NULL THEN
        RAISE e_invalid_empno;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Salary of Employee ' || v_empno || ' = ' || v_sal);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee found with empno ' || v_empno);
    WHEN e_invalid_empno THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Employee Number entered.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/