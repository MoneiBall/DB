-----------------------------------------
/* (exception)
Write a function which gets a date parameter in one of the following formats: 
'yyyy.mm.dd' or 'dd.mm.yyyy'. The function should return the name of the 
day, e.g. 'Tuesday'. If the parameter doesn't match any of the formats, the function
should return 'wrong format'.
*/

CREATE OR REPLACE FUNCTION day_name(d varchar2) RETURN varchar2 IS
not_a_valid_date exception;
pragma exception_init(not_a_valid_date, -1830);
dt_var DATE;
ad varchar2(100) := '';

BEGIN
dt_var := TO_DATE(d, 'yyyy.mm.dd');
ad := TO_CHAR(dt_var,'Day');
RETURN ad;

EXCEPTION
WHEN not_a_valid_date THEN
dt_var := TO_DATE(d, 'dd.mm.yyyy');
ad := TO_CHAR(dt_var,'Day');
RETURN ad;
 
WHEN OTHERS THEN
RETURN 'wrong format';

END day_name;
/
SELECT day_name('2017.05.01'), day_name('02.05.2017'), day_name('abc') FROM dual;

--------------------------------------------------------------------------------------------
/* (exception, SQLCODE)
Write a procedure which gets a number parameter and prints out the reciprocal,
the sqare root and the factorial of the parameter in different lines. 
If any of these outputs is not defined or causes an overflow, the procedure should 
print out 'not defined' or the error code (SQLCODE) for this part.
(The factorial is defined only for nonnegative integers.)
*/
CREATE OR REPLACE PROCEDURE numbers(n number) IS
fac number := 1;
BEGIN
FOR i in 2..n LOOP
  fac := fac*i;
END LOOP;

dbms_output.put_line(round(1/n, 3) || ' ' || fac || ' '|| round(sqrt(n),3));
EXCEPTION 
WHEN OTHERS THEN
 dbms_output.put_line('not defined');
END;
/
set serveroutput on;
execute numbers(0);
execute numbers(-2);
execute numbers(11);

/* (exception)
Write a function which returns the sum of the numbers in its string parameter.
The numbers are separated with a '+'. If any expression between the '+' characters
is not a number, the function should consider this expression as 0.
*/
/
CREATE OR REPLACE FUNCTION sum_of2(p_char VARCHAR2) RETURN number IS
summation integer;
BEGIN
    SELECT SUM(row_sum) INTO summation FROM (select trim(regexp_substr(p_char,'[^+]+', 1, level)) as row_sum from dual
                                             connect by regexp_substr(p_char, '[^+]+', 1, level) IS NOT NULL);
    RETURN summation;
EXCEPTION
WHEN OTHERS THEN
    summation := 0;
    RETURN summation;
END;
/

SELECT sum_of2('1 + 21 + kkg + +  k + 3') FROM dual;
---------------------------------------------------------------------------------------------------

/
create or replace function is_number(p_string varchar2) return number is
begin
return to_number(p_string);
exception when value_error then
return 0;
end;
/
CREATE OR REPLACE FUNCTION sum_of23(p_char VARCHAR2) RETURN number IS
tmp VARCHAR(100) := p_char;
plus number := 0;
num number  := 0;
sum_ number := 0;
begin

while instr(tmp,'+')!=0
    loop
            plus := instr(tmp,'+');
            num  := is_number(substr(tmp,0,plus-2));
            tmp  := substr(tmp,plus+1);
            sum_ := sum_+num;
            dbms_output.put_line(num);
    end loop;
 -- it's the last character with plus sign!
    plus := instr(tmp,'+');
    num  := to_number(substr(tmp,plus));
    tmp  := substr(tmp,length(tmp));
    sum_ := sum_ + num;
   
     return sum_;
END;
/
SELECT sum_of23('1 + 21 + bubu + + 2 + +') FROM dual;

--Hint: try to convert the expressions to number, and handle the exception
----------------------------------------------------------------



