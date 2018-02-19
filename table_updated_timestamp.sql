CREATE FUNCTION updated_when()
RETURNS trigger LANGUAGE plpgsql AS $function$
BEGIN
	NEW.updated_when = NOW();
	RETURN NEW;
END;
$function$;

CREATE FUNCTION install_trigger_updated_when(target_table regclass)
RETURNS void LANGUAGE plpgsql AS $function$
BEGIN
	EXECUTE format('CREATE TRIGGER updated_when BEFORE UPDATE ON %s FOR EACH ROW WHEN (NEW.* IS DISTINCT FROM OLD.*) EXECUTE PROCEDURE updated_when()', target_table);
END;
$function$;
