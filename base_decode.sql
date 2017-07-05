CREATE OR REPLACE FUNCTION base_decode(digits TEXT, charset TEXT DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')
	RETURNS BIGINT LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
	base INTEGER := char_length(charset);
	decoded BIGINT := 0;
	multiplier INTEGER := 1;
	digit CHAR;
BEGIN
	FOR i IN REVERSE char_length(digits)..1 LOOP
		digit := substr(digits, i, 1);
		decoded := decoded + (multiplier * (strpos(charset, digit)-1));
		multiplier := multiplier * base;
	END LOOP;
	RETURN decoded;
END;$$;

CREATE OR REPLACE FUNCTION base62_decode(digits TEXT)
	RETURNS BIGINT LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
	RETURN base_decode(digits, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
END;$$;
