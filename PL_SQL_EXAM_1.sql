CREATE TABLE emp2 AS SELECT * FROM emp;
CREATE TABLE likes2 AS SELECT * FROM likes;
CREATE TABLE dept2 AS SELECT * FROM dept;
CREATE TABLE sal_cat2 AS SELECT * FROM sal_cat;


CREATE OR REPLACE PROCEDURE add_mgrSalary IS
v VARCHAR2(20);
BEGIN
  UPDATE emp2 SET sal = coalesce(sal,0) + (SELECT sal FROM emp2 e2 WHERE e2.empno = emp2.mgr)
  WHERE mgr is NOT NULL;

  SELECT to_char(avg(sal),'9999.99') INTO v FROM emp2;
  dbms_output.put_line(v);
  ROLLBACK;  
END;
/
execute add_mgrSalary();


-----------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE sal_increase(dno INTEGER) IS 
CURSOR curs3 IS SELECT ename, sal FROM emp2 WHERE deptno = dno FOR UPDATE;
rec curs3%ROWTYPE;
cat integer;
BEGIN
   OPEN curs3;
   LOOP
     FETCH curs3 INTO rec;
     EXIT WHEN curs3%NOTFOUND;
   
     IF rec.ename LIKE '%T%' THEN      
                UPDATE emp2 SET sal = sal + 10000 WHERE CURRENT OF curs3;
     ELSE
                SELECT category INTO cat FROM emp, sal_cat WHERE sal BETWEEN lowest_sal AND highest_sal AND ename = rec.ename;                
                UPDATE emp2 SET sal = sal + cat*100 WHERE CURRENT OF curs3;
     END IF;
         DBMS_OUTPUT.PUT_LINE(TO_CHAR(rec.ename) || ' ' || TO_CHAR(rec.sal));
        
     END LOOP;     
     CLOSE curs3;
        
     ROLLBACK;        
END;
/
set serveroutput on
execute sal_increase(20);
--------------------------------------------------------------------------------------------------------------------
/*
exercise 3 (cursor)
Write a procedure which prints out the names of the employees whose name has two identical
letters (e.g. TURNER has two 'R'-s). The procedure should print out the names of these 
employees and the sum of their salaries. */
CREATE OR REPLACE PROCEDURE letter2 IS 
CURSOR curs1 IS SELECT job FROM emp e JOIN dept d  ON e.deptno = d.deptno;-- WHERE dname = d_name ORDER BY ename;
rec curs1%ROWTYPE;
jobs_body VARCHAR(200);
BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO rec;
    EXIT WHEN curs1%NOTFOUND; 
      FOR i in 1..length(rec.ename) LOOP
           IF substr(rec.ename,i,1) = herif THEN
                cnt_vowels := cnt_vowels + 1;
           END IF;
    jobs_body := jobs_body  || to_char(rec.job) || '-'; 
    --DBMS_OUTPUT.PUT_LINE(TO_CHAR(jobs_body));  
  END LOOP;    
  CLOSE curs1;
     jobs_body := substr(jobs_body, 1, (length(jobs_body) - 1));
     DBMS_OUTPUT.PUT_LINE(TO_CHAR(jobs_body));
END;   
/
execute letter2();

----------------------------------------------------------------------------------------------exersice5-----

--Exercise 5
Create Or Replace Function Day_Name(D Varchar2) Return Varchar2 Is
ad2 Date;
Ad Varchar2(20) := '';
Begin
 
 IF INSTR(D, '.') = 5 THEN
  ad2 := TO_DATE(D, 'YYYY.MM.DD');
 ELSIF INSTR(D, '.') = 3 THEN
  ad2 := TO_DATE(D, 'MM.YYYY.DD');
 ELSIF INSTR(D, '-') = 3 THEN
  ad2 := TO_DATE(D, 'DD-MM-YYYY');
 END IF;
 Ad := To_Char(ad2, 'Day', 'nls_date_language=english');
 Return Ad;
Exception 
When Others then
 Ad := 'Wrong format';
 Return Ad;
End;
/

SELECT Day_Name('2018.05.01'), Day_Name('02-05-2018'), Day_Name('02.1967.03'), Day_Name('2018.13.13') FROM dual;

set serveroutput on
















