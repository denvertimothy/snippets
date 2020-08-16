CREATE OR REPLACE FUNCTION base_encode(digits BIGINT, charset TEXT DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')
	RETURNS TEXT LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
	encoded TEXT := '';
	base INTEGER := char_length(charset);
BEGIN
	WHILE (digits > 0) LOOP
		encoded := substr(charset, ((digits % base)+1)::INTEGER, 1) || encoded;
		digits := floor(digits / base);
	END LOOP;
	RETURN encoded;
END;$$;

CREATE OR REPLACE FUNCTION base62_encode(digits BIGINT)
	RETURNS TEXT LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
	RETURN base_encode(digits, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
END;$$;
