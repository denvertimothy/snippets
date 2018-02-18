/*
	encrypt_feistel_24(digits)
	
	Used as a pseudo-random generator of unique values. It produces an integer
	output that is uniquely associated to its integer input (by a mathematical
	permutation), but looks random at the same time, with zero collision. This
	is useful to communicate numbers generated sequentially without revealing
	their ordinal position in the sequence (for ticket numbers, URLs shorteners,
	promo codes...).
	
	https://wiki.postgresql.org/wiki/Pseudo_encrypt
	
	Takes an integer as parameter and returns pseudo-randomized integer.
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
