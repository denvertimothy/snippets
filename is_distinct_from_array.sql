CREATE FUNCTION is_distinct_from(anyelement, anyelement) RETURNS boolean LANGUAGE sql IMMUTABLE AS $$
	SELECT $1 IS DISTINCT FROM $2;
$$;

CREATE OPERATOR <!> (
	PROCEDURE = is_distinct_from(anyelement, anyelement),
	LEFTARG = anyelement,
	RIGHTARG = anyelement,
	COMMUTATOR = <!>,
	NEGATOR = =!=
);

CREATE FUNCTION is_not_distinct_from(anyelement, anyelement)
RETURNS BOOLEAN LANGUAGE sql IMMUTABLE AS $$
	SELECT $1 IS NOT DISTINCT FROM $2;
$$;

CREATE OPERATOR =!= (
	PROCEDURE = is_not_distinct_from(anyelement, anyelement),
	LEFTARG = anyelement,
	RIGHTARG = anyelement,
	COMMUTATOR = =!=,
	NEGATOR = <!>
);

select 'a' <!> all(array['a', null]);
select 'b' =!= any(array['b', null]);
