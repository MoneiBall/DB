/* SELECT ... INTO ...
Write a procedure which prints out the number of employees and average salary of the employees 
whose hiredate was the day which is the parameter of the procedure (e.g. 'Monday'). 
*/
create or replace PROCEDURE day_avg(d varchar2) IS
count_of_emp integer;
avrg number;
BEGIN
   SELECT COUNT(ename) ,TRUNC(AVG(sal)) INTO count_of_emp, avrg FROM emp WHERE TRIM(TO_CHAR(hiredate, 'Day','nls_date_language=english')) = d;
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(count_of_emp) || ' - ' || TO_CHAR(avrg));
   --SELECT AVG(sal) INTO avrg FROM emp WHERE substr(TO_CHAR(hiredate, 'day'),1,7) = 'tuesday';
END;
/
execute day_avg('Thursday');

/* SELECT ... INTO ...
Write a function which returns the average salary within a salary category (parameter).
*/
create or replace FUNCTION cat_avg(categ integer) RETURN number IS
avrg number;
BEGIN
   SELECT AVG(sal) INTO avrg FROM emp JOIN sal_cat ON category = categ WHERE sal BETWEEN lowest_sal AND highest_sal;
   RETURN avrg;
END;
/
SELECT cat_avg(2) FROM dual;



--//-------------------------------------------------------------------------------------------------------------------
/* Cursor
Write a procedure which takes the employees working on the parameter department
in alphabetical order, and prints out the jobs of the employees in a concatenated string. */

set serveroutput on
CREATE OR REPLACE PROCEDURE jobs(d_name varchar2) IS

CURSOR curs1 IS SELECT job FROM emp e JOIN dept d  ON e.deptno = d.deptno WHERE dname = d_name ORDER BY ename;
rec curs1%ROWTYPE;
jobs_body VARCHAR(200);
BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO rec;
    EXIT WHEN curs1%NOTFOUND;      
    jobs_body := jobs_body  || to_char(rec.job) || '-'; 
    --DBMS_OUTPUT.PUT_LINE(TO_CHAR(jobs_body));  
  END LOOP;    
  CLOSE curs1;
     jobs_body := substr(jobs_body, 1, (length(jobs_body) - 1));
     DBMS_OUTPUT.PUT_LINE(TO_CHAR(jobs_body));
END;
/
EXECUTE jobs('SALES');
EXECUTE jobs('RESEARCH');

-----------------------------------------------------------------------------------------------------------------
/* Associative array
Write a procedure which takes the first n (n is the parameter) prime numbers and puts them into 
an associative array. The procedure should print out the last prime and the total sum of the prime numbers. */

create or replace procedure primes(n integer) IS
 j integer; i integer; k integer := 0;
 cnt integer; sump integer := 0;
 --TYPE tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;        -- associative array type
 -- tab tab_type;  
 TYPE int_arr IS TABLE OF INTEGER(10) INDEX BY BINARY_INTEGER;
 arr int_arr;
BEGIN

FOR i in 1..n LOOP
   cnt := 0;
  FOR j in 2..i LOOP
    IF mod(i, j) = 0 THEN
      cnt := cnt + 1;
        IF cnt = 2 THEN exit; END IF;
    END IF;
  END LOOP;
 --DBMS_OUTPUT.PUT_LINE(TO_CHAR(cnt));
       IF cnt = 1 THEN
          arr(k) := i;
          sump := sump + i;
          k := k + 1;
       END IF;           
END LOOP;
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(arr(k-1)) || ' ' || TO_CHAR(sump)); 
END;
/
set serveroutput on;
execute primes(11);


CREATE TABLE emp2 AS SELECT * FROM emp;
CREATE TABLE likes2 AS SELECT * FROM likes;
CREATE TABLE dept2 AS SELECT * FROM dept;
CREATE TABLE sal_cat2 AS SELECT * FROM sal_cat;
DROP TABLE emp2;
DROP TABLE likes2;
DROP TABLE dept2;
DROP TABLE sal_cat2;
-----------------------------------------------------------------------------------------------------------------------
/* Cursor and associative array
Write a plsql procedure which takes the employees in alphabetical order
and puts every second employee's name (1st, 3rd, 5th etc.) and salary into an associative array.
The program should print out the last but one (the one before the last) values from the array.
*/
CREATE OR REPLACE PROCEDURE proc9 IS
CURSOR curs2 IS SELECT ename, sal FROM emp ORDER BY ename;
  rec curs2%ROWTYPE;

TYPE tab_type2 IS TABLE OF curs2%ROWTYPE INDEX BY BINARY_INTEGER;   -- array of records
  arr tab_type2;
  
i integer := 0;
b boolean := true;

BEGIN
  OPEN curs2;
  LOOP
    FETCH curs2 INTO rec;
    EXIT WHEN curs2%NOTFOUND;
    
    IF b THEN
       arr(i).ename := rec.ename;
       arr(i).sal := rec.sal;
       i := i + 1;
    END iF;
    b := not b;
    
            
  END LOOP;    
  CLOSE curs2;
  --FOR j in arr.first..arr.last LOOP
  -- DBMS_OUTPUT.PUT_LINE(TO_CHAR(arr(j).ename) || ' ' || TO_CHAR(arr(j).sal));
  -- END LOOP;
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(arr(arr.last - 1).ename) || ' ' || TO_CHAR(arr(arr.last - 1).sal));
END;
/
set serveroutput on;
execute proc9;

SELECT ename, sal FROM emp order by ename asc;

-----------------------------------------------------------------------------------------------------------------------
/* Insert, Delete, Update
Write a procedure which increases the salary of the employees who has salary category p (p is parameter).
The increment should be the minimal salary of the employee's own department.
After executing the update statement, the procedure should print out the average salary of all employees.
*/
CREATE OR REPLACE PROCEDURE upd_cat(p integer) IS
v VARCHAR2(20);
BEGIN
  UPDATE emp2 SET sal = sal + (SELECT MIN(sal) FROM emp2 e2 WHERE e2.deptno = emp2.deptno)
  WHERE ename in (SELECT ename FROM emp2 JOIN sal_cat2 ON category = p WHERE sal BETWEEN lowest_sal AND highest_sal);
  
  SELECT to_char(avg(sal),'9999.99') INTO v FROM emp2;
  dbms_output.put_line(v);
  ROLLBACK;  
END;
/
set serveroutput on;
execute upd_cat(3);

--SELECT to_char(AVG(sal),'9999.99') FROM emp2 WHERE ename in 
--(SELECT ename FROM emp2 JOIN sal_cat2 ON category = 2 WHERE sal BETWEEN lowest_sal AND highest_sal);

-------------------------------------------------------------------------------------------------------------------------
/* Update with cursor
Write a procedure which updates the salaries on a department (parameter: department number).
The update should increase the salary with n*10000, where n is the number of vowels (A,E,I,O,U)
in the name of the employee. (For ALLEN it is 2, for KING it is 1.)
The procedure should print out the name and new salary of the modified employees.
*/
CREATE OR REPLACE PROCEDURE curs_upd(dno INTEGER) IS 
CURSOR curs3 IS SELECT ename, sal FROM emp2 WHERE deptno = dno FOR UPDATE;
rec curs3%ROWTYPE;
cnt_vowels integer;

BEGIN
   OPEN curs3;
   LOOP
     FETCH curs3 INTO rec;
     EXIT WHEN curs3%NOTFOUND;
     cnt_vowels := 0;
      FOR i in 1..length(rec.ename) LOOP
        IF substr(rec.ename,i,1) in ('A','E','I','O','U') THEN
                cnt_vowels := cnt_vowels + 1;
        END IF;      
      END LOOP;
         --DBMS_OUTPUT.PUT_LINE(TO_CHAR(cnt_vowels));
         --DBMS_OUTPUT.PUT_LINE(TO_CHAR(rec.ename));
         UPDATE emp2 SET sal = sal + cnt_vowels * 10000 WHERE CURRENT OF curs3;
         DBMS_OUTPUT.PUT_LINE(TO_CHAR(rec.ename) || ' ' || TO_CHAR(rec.sal));
        
     END LOOP;     
     CLOSE curs3;
        
     ROLLBACK;
        
END;
/
set serveroutput on
execute curs_upd(10);