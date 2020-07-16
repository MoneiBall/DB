Author: Mamedov Sadi

----------------------------------------------------------------------ex 3-------------------------------------------------------------------------
create or replace FUNCTION day_name(d varchar2) RETURN varchar2 IS
    newDate DATE;
    weekday VARCHAR(20);
BEGIN

    IF (INSTR(d, '.') = 5) THEN
        newDate := TO_DATE(d, 'yyyy.mm.dd');
    ELSIF (INSTR(SUBSTR(d, INSTR(d, '.')+1, LENGTH(d)), '.') = 3) THEN
        newDate := TO_DATE(d, 'dd.mm.yyyy');
    ELSE
        newDate := TO_DATE(d, 'mm.yyyy.dd');
    END IF;

    weekday := to_char(newDate, 'Day', 'nls_date_language=english');
    RETURN weekday;


    EXCEPTION
        WHEN others THEN
            RETURN('Wrong format');

END;
/
SELECT day_name('2018.05.01'), day_name('02.05.2018'), day_name('02.1967.03'), day_name('2018.13.13') FROM dual;

----------------------------------------------------------------------ex 2-------------------------------------------------------------------------
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
execute upd_cat(2);

----------------------------------------------------------------ex 4-------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE curs_upd_sal IS 
CURSOR curs3 IS SELECT ename, sal, deptno FROM emp2 FOR UPDATE;
rec curs3%ROWTYPE;
cnt_vowels integer;
minsal number;

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
         IF cnt_vowels = 1 THEN
         SELECT MIN(sal) INTO minsal FROM emp WHERE emp.deptno = rec.deptno;
         UPDATE emp2 SET sal = sal + minsal WHERE CURRENT OF curs3;
         DBMS_OUTPUT.PUT_LINE(TO_CHAR(rec.ename) || ' ' || TO_CHAR(rec.sal));
         END iF;
         
        
     END LOOP;     
     CLOSE curs3;
        
     ROLLBACK;
        
END;
/
set serveroutput on
execute curs_upd_sal();

SELECT * FROM emp;

----------------------------------------------------------------ex 5------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prime_array(n integer) IS
TYPE arr IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
isbn arr;
TYPE sumA IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
arrSum sumA;
status integer := 1;
m number(8) := 3;
i number(8) := 2;
s number(8) := 2;
name VARCHAR2(20);
sName VARCHAR2(20);
BEGIN
LOOP
  FOR j IN 2 .. SQRT(m) LOOP
    IF mod(m, j) = 0 THEN status := 0; exit; END IF; 
  END LOOP;
  IF status <> 0 THEN 
    isbn('Primes: ') := m;
    s := s + m;
    arrSum('Sum: ') := s;
    i := i+1;
  END IF;
  status := 1;
  m := m + 1;
  Exit when i > n;
END LOOP;
name := isbn.FIRST; 
   WHILE name IS NOT null LOOP 
      
      dbms_output.put_line  (TO_CHAR(isbn(name))); 
      name := isbn.NEXT(name); 
   END LOOP;
sName := arrSum.FIRST; 
   WHILE sName IS NOT null LOOP 
     dbms_output.put_line (TO_CHAR(arrSum(sName))); 
      sName := arrSum.NEXT(sName); 
   END LOOP;
END;
/
set serveroutput on
execute prime_array(100);

----------------------------------------------------------------------------------------------------------------

