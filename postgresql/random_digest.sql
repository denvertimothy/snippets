CREATE OR REPLACE FUNCTION random_md5() RETURNS text LANGUAGE sql
AS $$ SELECT md5(gen_random_bytes(1024)); $$;

CREATE OR REPLACE FUNCTION sha256(subject bytea) RETURNS text LANGUAGE sql
AS $$ SELECT ENCODE(DIGEST($1, 'sha256'), 'hex'); $$;

CREATE OR REPLACE FUNCTION random_sha256() RETURNS text LANGUAGE sql
AS $$ SELECT sha256(gen_random_bytes(1024)); $$;
