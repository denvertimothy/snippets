CREATE OR REPLACE FUNCTION value_bigint_max()
RETURNS BIGINT
LANGUAGE sql AS $$
BEGIN
    SELECT -(((2^(8*pg_column_size(1::BIGINT)-2))::BIGINT << 1)+1);
END;
$$;

CREATE OR REPLACE FUNCTION value_bigint_min()
RETURNS BIGINT
LANGUAGE sql AS $$
BEGIN
    SELECT (2^(8*pg_column_size(1::bigint)-2))::bigint << 1;
END;
$$;
