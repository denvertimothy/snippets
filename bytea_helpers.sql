CREATE OR REPLACE FUNCTION replace(subject bytea, search bytea, replace bytea)
RETURNS bytea LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
	buf bytea := '';
	pos integer;
BEGIN
	-- nothing to do if subject or search is null or empty
	IF (subject IS NULL OR length(subject) = 0 OR search IS NULL OR length(search) = 0) THEN
		RETURN subject;
	END IF;

	-- change null to empty
	replace := coalesce(replace, '');

	LOOP
		pos := position(search in subject);

		IF (pos = 0) THEN
			-- search is not found, append remaining subject to buffer and return
			buf := buf || substring(subject from 1);
			RETURN buf;
		ELSE
			-- search found, append substring before search and add replace to buffer
			buf := buf || substring(subject from 1 for pos-1) || replace;
			subject := substring(subject from pos + length(search));
		END IF;
	END LOOP;
END;
$$;


CREATE OR REPLACE FUNCTION replace(subject bytea, search_replace bytea[][])
RETURNS bytea LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
	-- loop through each search term (search_replace[i][1]) and replace with corresponding value (search_replace[i][2])
	FOR i IN 1..array_upper(search_replace, 1) LOOP
		subject := replace(subject, search_replace[i][1], search_replace[i][2]);
	END LOOP;
	RETURN subject;
END;
$$;

CREATE OR REPLACE FUNCTION filter(subject bytea, search bytea[] default NULL)
RETURNS bytea LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
	buf bytea := '';
	tmp bytea;
BEGIN
	-- nothing to do if subject is empty
	IF (subject IS NULL OR length(subject) = 0) THEN
		RETURN subject;
	END IF;

	-- if search characters are not provided, default to ascii set
	IF (search IS NULL) THEN
		search := ARRAY[
			E'\\x0a'::bytea, -- line feed
			E'\\x0d'::bytea, -- carriage return
			E'\\x20'::bytea, -- space
			'!'::bytea, '"'::bytea, '#'::bytea, '$'::bytea, '%'::bytea, '&'::bytea, E'\\x27'::bytea, '('::bytea, ')'::bytea, '*'::bytea, '+'::bytea, ','::bytea, '-'::bytea, '.'::bytea, '/'::bytea,
			'0'::bytea, '1'::bytea, '2'::bytea, '3'::bytea, '4'::bytea, '5'::bytea, '6'::bytea, '7'::bytea, '8'::bytea, '9'::bytea,
			':'::bytea, ';'::bytea, '<'::bytea, '='::bytea, '>'::bytea, '?'::bytea, '@'::bytea, 
			'A'::bytea, 'B'::bytea, 'C'::bytea, 'D'::bytea, 'E'::bytea, 'F'::bytea, 'G'::bytea, 'H'::bytea, 'I'::bytea, 'J'::bytea, 'K'::bytea, 'L'::bytea, 'M'::bytea, 'N'::bytea, 'O'::bytea, 'P'::bytea, 'Q'::bytea, 'R'::bytea, 'S'::bytea, 'T'::bytea, 'U'::bytea, 'V'::bytea, 'W'::bytea, 'X'::bytea, 'Y'::bytea, 'Z'::bytea,
			'['::bytea, E'\\x5c'::bytea, ']'::bytea, '^'::bytea, '_'::bytea, '`'::bytea,
			'a'::bytea, 'b'::bytea, 'c'::bytea, 'd'::bytea, 'e'::bytea, 'f'::bytea, 'g'::bytea, 'h'::bytea, 'i'::bytea, 'j'::bytea, 'k'::bytea, 'l'::bytea, 'm'::bytea, 'n'::bytea, 'o'::bytea, 'p'::bytea, 'q'::bytea, 'r'::bytea, 's'::bytea, 't'::bytea, 'u'::bytea, 'v'::bytea, 'w'::bytea, 'x'::bytea, 'y'::bytea, 'z'::bytea,
			'{'::bytea, '|'::bytea, '}'::bytea, '~'::bytea
		];
	END IF;

	-- loop through each byte eliminating anything not found in search
	FOR i IN 1..octet_length(subject) LOOP
		tmp := substring(subject from i for 1);
		IF (tmp = ANY(search)) THEN
			buf := buf || tmp;
		END IF;
	END LOOP;

	RETURN buf;
END;
$$;

CREATE OR REPLACE FUNCTION decode_filter_convert_base64(subject text)
RETURNS text LANGUAGE sql IMMUTABLE AS $$
	SELECT convert_from(filter(decode(subject, 'base64')), 'utf8');
$$;
