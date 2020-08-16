CREATE OR REPLACE FUNCTION is_leap_year(year integer)
RETURNS BOOLEAN AS $$
        SELECT ($1 % 4 = 0) AND (($1 % 100 <> 0) or ($1 % 400 = 0))
$$ LANGUAGE sql IMMUTABLE STRICT;
 
CREATE OR REPLACE FUNCTION is_leap_year(date date)
RETURNS BOOLEAN AS $$
        SELECT DATE_PART('month', DATE_TRUNC('year', $1)+'1 months 28 days'::INTERVAL) = 2;
$$ LANGUAGE sql IMMUTABLE STRICT;
