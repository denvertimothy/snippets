CREATE OR REPLACE FUNCTION value_bigint_max()
RETURNS BIGINT
LANGUAGE sql AS $$
    SELECT -(((2^(8*pg_column_size(1::BIGINT)-2))::BIGINT << 1)+1);
$$;

CREATE OR REPLACE FUNCTION value_bigint_min()
RETURNS BIGINT
LANGUAGE sql AS $$
    SELECT (2^(8*pg_column_size(1::bigint)-2))::bigint << 1;
$$;
