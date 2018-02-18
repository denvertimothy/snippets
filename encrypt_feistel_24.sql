/*
	Used as a pseudo-random number generator of unique values. Useful for communicating
	numbers generated sequentially without revealing their ordinal position in the sequence.
*/

CREATE OR REPLACE FUNCTION encrypt_feistel_24(digits BIGINT)
	RETURNS INTEGER
	LANGUAGE plpgsql STRICT IMMUTABLE
	AS $$
DECLARE
	l1 INTEGER := (digits >> 16) & 65535;
	l2 INTEGER;
	r1 INTEGER := digits & 65535;
	r2 INTEGER;
	i INTEGER := 0;
BEGIN
	WHILE i < 3 LOOP
		l2 := r1;
		r2 := l1 # ((((1366 * r1 + 150889) % 714025) / 714025.0) * 32767)::INTEGER;
		l1 := l2;
		r1 := r2;
		i := i + 1;
	END LOOP;
	RETURN ((r1 << 16) + l1);
END;$$;
