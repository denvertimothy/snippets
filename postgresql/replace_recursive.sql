CREATE OR REPLACE FUNCTION extensions.replace_recursive(search text, from_to text[])
RETURNS text LANGUAGE plpgsql AS $$
BEGIN
	IF (array_length(from_to,1) > 1) THEN
		RETURN replace_recursive(
			replace(search, from_to[1][1], from_to[1][2]),
			from_to[2:array_upper(from_to,1)]
		);
	ELSE
		RETURN replace(search, from_to[1][1], from_to[1][2]);
	END IF;
END;$$;
