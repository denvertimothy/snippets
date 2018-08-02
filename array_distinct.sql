CREATE OR REPLACE FUNCTION array_distinct(anyarray)
RETURNS anyarray LANGUAGE sql IMMUTABLE
AS $function$
	SELECT array_agg(DISTINCT x ORDER BY x) FROM unnest($1) AS x;
$function$;
