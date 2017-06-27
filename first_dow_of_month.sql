CREATE OR REPLACE FUNCTION first_dow_of_month(year INTEGER, month INTEGER, dow INTEGER)
RETURNS date LANGUAGE plpgsql AS $$
DECLARE
	first_day DATE := (year||'-'||month||'-1')::DATE;
	first_day_plus_week DATE := first_day + '1 week'::INTERVAL;
BEGIN
	RETURN first_day_plus_week + dow - DATE_PART('dow', first_day_plus_week)::INTEGER;
END;
$$;
