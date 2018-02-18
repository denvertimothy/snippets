/*
	encrypt_feistel(digits)
	
	Takes an integer as parameter and returns non-colliding pseudo-randomized integer.
	
	Used as a pseudo-random generator of unique values. It produces an integer
	output that is uniquely associated to its integer input (by a mathematical
	permutation), but looks random at the same time, with zero collision. This
	is useful to communicate numbers generated sequentially without revealing
	their ordinal position in the sequence (for ticket numbers, URLs shorteners,
	promo codes...).
	
	https://wiki.postgresql.org/wiki/Pseudo_encrypt
	https://www.postgresql.org/message-id/448163db-cac5-4e99-8c4c-57cbc6f6af78@mm
	https://stackoverflow.com/questions/12761346/pseudo-encrypt-function-in-plpgsql-that-takes-bigint/12761795#12761795
	https://medium.com/@emerson_lackey/postgres-randomized-primary-keys-123cb8fcdeaf
*/

CREATE OR REPLACE FUNCTION encrypt_feistel(digits INTEGER)
	RETURNS integer LANGUAGE plpgsql STRICT IMMUTABLE AS $$
DECLARE
	l1 integer := (digits >> 16) & 65535;
	l2 integer;
	r1 integer := digits & 65535;
	r2 integer;
	i integer := 0;
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

CREATE OR REPLACE FUNCTION encrypt_feistel(digits bigint)
	RETURNS bigint LANGUAGE plpgsql STRICT IMMUTABLE AS $$
DECLARE
	l1 bigint;
	l2 bigint;
	r1 bigint;
	r2 bigint;
	i integer := 0;
BEGIN
    l1:= (digits >> 32) & 4294967295::bigint;
    r1:= digits & 4294967295;
    WHILE i < 3 LOOP
        l2 := r1;
        r2 := l1 # ((((1366.0 * r1 + 150889) % 714025) / 714025.0) * 32767*32767)::int;
        l1 := l2;
        r1 := r2;
    i := i + 1;
    END LOOP;
RETURN ((r1::bigint << 32) + l1);
END;$$;
