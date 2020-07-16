CREATE TABLE emp2 AS SELECT * FROM emp;
CREATE TABLE likes2 AS SELECT * FROM likes;
CREATE TABLE dept2 AS SELECT * FROM dept;
CREATE TABLE sal_cat2 AS SELECT * FROM sal_cat;



----------------------------------------------DELETE--------------------------------------
-- Delete the employees whose commission is null.
DELETE from emp2 WHERE comm is null;
-- Delete the employees whose hiredate is before 1982.01.01.
DELETE from emp2 WHERE hiredate < to_date ('1982.01.01', 'yyyy.mm.dd');
-- Delete the employees whose department's location is DALLAS.
DELETE from emp2 WHERE deptno = (SELECT deptno from dept WHERE loc = 'DALLAS');
--Delete the employees whose salary is less than the average salary
DELETE from emp2 WHERE sal < (SELECT round(AVG(sal)) FROM emp2);
--Delete the employees whose salary is less than the average salary on his department.
DELETE FROM emp2
WHERE sal < (select avg(sal) from emp2 e2 where e2.deptno = emp2.deptno);
-- Delete the employee (employees) whose salary is the greatest.
DELETE from emp2 WHERE sal in ( 
SELECT sal FROM emp2 MINUS
SELECT e1.sal FROM emp2 e1 , emp2 e2
WHERE e1.sal < e2.sal);
-- Delete the departments which has an employee with salary category 2.
DELETE FROM dept2 WHERE dname IN (
SELECT dname from dept WHERE deptno IN
 (SELECT deptno FROM emp, sal_cat
 WHERE category = 2 AND sal BETWEEN lowest_sal AND highest_sal));
-- Delete the departments which has at least two employees with salary category 2. 
DELETE FROM dept2 WHERE dname IN( 
SELECT dname from dept WHERE deptno IN
(SELECT deptno FROM emp, sal_cat
WHERE category = 2 AND sal BETWEEN lowest_sal AND highest_sal
GROUP BY deptno HAVING COUNT(ename) >= 2));

--------------------------------------------------Insert------------------------------------------
-- Insert a new employee with the following values:
--   empno=1, ename='Smith', deptno=10, hiredate=sysdate, salary=average salary in department 10.
--   All the other columns should be NULL.
INSERT INTO emp2 (empno, ename, deptno, hiredate, sal)
VALUES (1 , 'Smith', 10, sysdate, (SELECT round(AVG(sal)) FROM emp2 WHERE deptno = 10));

-- a) Insert the row with the 'VALUES' keyword
INSERT INTO emp2 (empno, ename, deptno, hiredate, sal)
VALUES (&empno, '&ename', &deptno, '&hiredate', &sal);
-- b) Insert the row with a SELECT query without 'VALUES' keyword.
INSERT INTO emp2 (empno, ename, job, deptno, hiredate, sal)
SELECT empno, ename, job, deptno, hiredate, sal FROM emp2 WHERE sal = 3000;

-------------------------------------------------UPDATE----------------------------------
-- Increase the salary of the employees in department 20 with 20%.
UPDATE emp2 SET sal = sal * 1.2 WHERE deptno IN 20;
-- Increase the salary with 500 of the employees whose commission is NULL or whose salary is less than the average.
UPDATE emp2 SET sal = sal + 500 WHERE comm is NULL or sal < (SELECT avg(sal) FROM emp2);
-- Increase the commission of all employees with the maximal commission.
-- If an employee has NULL commission, treat it as 0.
UPDATE emp2 SET comm = coalesce(comm,0) + (SELECT MAX(comm) FROM emp2);
-- Modify the name of the employee with the lowest salary to 'Poor'.
UPDATE emp2 SET ename = 'Kasib' WHERE sal = (SELECT MIN(sal) FROM emp2);
-- Increase the commission with 3000 of the employees, who has at least 2 direct subordinates.
-- If an employee has NULL commission, treat it as 0.
UPDATE emp2 SET comm = coalesce(comm,0) + 3000 WHERE ename IN (
SELECT DISTINCT e2.ename FROM emp2 e1 JOIN emp2 e2 ON e1.mgr = e2.empno
GROUP BY e2.ename HAVING COUNT(e1.empno) >= 2);

-- Increase the salary of those employees who has a subordinate. The increment is the minimal salary.
UPDATE emp2 SET sal = sal +  (SELECT MIN(sal) FROM emp2) WHERE ename IN (
SELECT DISTINCT e2.ename FROM emp2 e1 JOIN emp2 e2 ON e1.mgr = e2.empno);

-- Increase the salary of the employees who don't have a subordinate. The increment is
-- the average salary of their own department.
UPDATE emp2 SET sal = sal + (SELECT AVG(sal) FROM emp2 e2 WHERE e2.deptno = emp2.deptno) WHERE ename IN (
SELECT ename FROM emp2 MINUS
SELECT DISTINCT e2.ename FROM emp2 e1 JOIN emp2 e2 ON e1.mgr = e2.empno);
----------------- or -----------------
UPDATE emp2 e1 SET sal = sal + (SELECT avg(sal) FROM emp2 e2 WHERE e2.deptno = e1.deptno)
WHERE empno NOT IN (SELECT coalesce(mgr,0) FROM emp2);
-----------------------------------------------------------------------------------------------