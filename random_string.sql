CREATE OR REPLACE FUNCTION random_string(len integer DEFAULT 16, chars text DEFAULT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&#%@!_-^*()@+=?/<>%[]{}'::text)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
BEGIN
	RETURN string_agg(substr(chars, ceil(random() * length(chars))::integer, 1), '') from generate_series(1, len);
END;$function$;
