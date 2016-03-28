CREATE OR REPLACE FUNCTION easter_date_gregorian(year INTEGER) RETURNS date LANGUAGE plpgsql IMMUTABLE AS $$
-- Uses the the "New York Anonymous", a.k.a. "Meeus/Jones/Butcher" algorithm,
-- valid for any year in the Gregorian calendar (year >= 1583).
DECLARE
	a INTEGER;
	b INTEGER;
	c INTEGER;
	d INTEGER;
	e INTEGER;
	f INTEGER;
	g INTEGER;
	h INTEGER;
	i INTEGER;
	k INTEGER;
	l INTEGER;
	m INTEGER;
	month INTEGER;
	day INTEGER;
BEGIN
	a := year % 19;
	b := year / 100;
	c := year % 100;
	d := b / 4;
	e := b % 4;
	f := (b + 8) / 25;
	g := (b - f + 1) / 3;
	h := (19 * a + b - d - g + 15) % 30;
	i := c / 4;
	k := c % 4;
	l := (32 + 2 * e + 2 * i - h - k) % 7;
	m := (a + 11 * h + 22 * l) / 451;
	month := (h + l - 7 * m + 114) / 31;
	day := (h + l - 7 * m + 114) % 31 + 1;
	RETURN make_date(year, month, day);
END;
$$;
