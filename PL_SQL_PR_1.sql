-------------------------------------------------------------PL SQL 3. task -----------------------------

CREATE OR REPLACE function gcd(p1 integer, p2 integer) RETURN number is
BEGIN  
IF p2 = 0
THEN
  RETURN p1;
ELSE
  RETURN gcd(p2 , (p1 mod p2));
END IF;  
END;
/
SELECT gcd(7293,14586) FROM dual;

-------------------------------------------------------------PL SQL 4. task -----------------------------

CREATE OR REPLACE FUNCTION factor(n integer) RETURN integer IS
BEGIN
    IF n = 0 THEN
    RETURN 1;
    ELSE
    RETURN n * (factor(n-1));
    END IF;
END;
/
SELECT factor(6) FROM dual;

----------------------------------------------------------------PL SQL 5. task --------------------------
CREATE OR REPLACE FUNCTION num_times(p1 VARCHAR2, p2 VARCHAR2) RETURN integer IS
--indexum  integer := 0;
cnt  integer := 0;
BEGIN
    FOR i IN 1..length(p1) LOOP
      IF substr(p1,i,length(p2)) = p2 THEN   
      cnt := cnt + 1;
      END IF;
    END LOOP;    
     RETURN cnt;
END;
/
SELECT num_times ('ab c ab ab de ab fg', 'ab') FROM dual;

----------------------------------------------------------------PL SQL 6. task --------------------------

CREATE OR REPLACE FUNCTION sum_of(p_char VARCHAR2) RETURN number IS
summation integer;
BEGIN
    SELECT SUM(row_sum) INTO summation FROM (select trim(regexp_substr(p_char,'[^+]+', 1, level)) as row_sum from dual
                                             connect by regexp_substr(p_char, '[^+]+', 1, level) IS NOT NULL);
    RETURN summation;
END;
/
SELECT sum_of('1 + 4 + 13 + 5 + 24') FROM dual;