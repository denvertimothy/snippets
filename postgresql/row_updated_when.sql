CREATE OR REPLACE FUNCTION updated_when()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
	-- the condition is here in the function instead of in the trigger
	-- in order to deal with generated columns
	IF (NEW IS DISTINCT FROM OLD) THEN
		NEW.updated_when = NOW();
	END IF;
	
	RETURN NEW;
END;
$$;

CREATE OR REPLACE PROCEDURE install_trigger_updated_when(target_table regclass, drop_existing boolean)
LANGUAGE plpgsql AS $$
BEGIN
	IF (drop_existing) THEN
		EXECUTE format('DROP TRIGGER updated_when ON %I', target_table);
	END IF;

	EXECUTE format(
		'CREATE TRIGGER updated_when '
			'BEFORE UPDATE ON %I '
			'FOR EACH ROW '
				'EXECUTE PROCEDURE updated_when()',
		target_table
	);
END;$$;
