/*
	encrypt_feistel_24(digits)
	
	Takes an integer as parameter and returns pseudo-randomized integer.
	
	Used as a pseudo-random generator of unique values. It produces an integer
	output that is uniquely associated to its integer input (by a mathematical
	permutation), but looks random at the same time, with zero collision. This
	is useful to communicate numbers generated sequentially without revealing
	their ordinal position in the sequence (for ticket numbers, URLs shorteners,
	promo codes...).
	
	https://wiki.postgresql.org/wiki/Pseudo_encrypt
	https://www.postgresql.org/message-id/448163db-cac5-4e99-8c4c-57cbc6f6af78@mm
	https://medium.com/@emerson_lackey/postgres-randomized-primary-keys-123cb8fcdeaf
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
