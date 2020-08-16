CREATE OR REPLACE FUNCTION extract_nth_dow(d date) RETURNS integer
AS $$
	-- Calculates and returns the Nth day of the week for the given date.
	SELECT (EXTRACT(day FROM d)::INTEGER - 1) / 7 + 1;
$$ LANGUAGE sql;
