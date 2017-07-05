CREATE OR REPLACE FUNCTION decode_base36(base36 varchar)
LANGUAGE 'plpgsql' IMMUTABLE RETURNS bigint AS $$
DECLARE
	a char[];
	ret bigint;
	i int;
	val int;
	chars varchar;
BEGIN
chars := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

FOR i IN REVERSE char_length(base36)..1 LOOP
	a := a || substring(upper(base36) FROM i FOR 1)::char;
END LOOP;
i := 0;
ret := 0;
WHILE i < (array_length(a,1)) LOOP		
	val := position(a[i+1] IN chars)-1;
	ret := ret + (val * (36 ^ i));
	i := i + 1;
END LOOP;

RETURN ret;
END;$$;
