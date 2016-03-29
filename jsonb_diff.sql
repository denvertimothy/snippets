CREATE OR REPLACE FUNCTION jsonb_diff(l JSONB, r JSONB) RETURNS JSONB LANGUAGE sql AS $$
	-- Delete matching key/value pairs from the left operand.
	SELECT jsonb_object_agg(a.key, a.value) FROM
		(SELECT key, value FROM jsonb_each(l)) AS a LEFT OUTER JOIN
		(SELECT key, value FROM jsonb_each(r)) AS b ON a.key = b.key
	WHERE a.value != b.value OR b.key IS NULL;
$$;

CREATE OPERATOR - (
	procedure = jsonb_diff,
	leftarg=JSONB,
	rightarg=JSONB
);
