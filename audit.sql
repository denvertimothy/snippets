CREATE OR REPLACE FUNCTION audit_table_create(
	source_schema text,
	source_table text,
	dest_schema text DEFAULT NULL::text,
	dest_table text DEFAULT NULL::text
)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
	dest_schema := COALESCE(dest_schema, source_schema||'_audit');
	dest_table := COALESCE(dest_table, source_table);
	
	-- create audit schema
	IF NOT EXISTS(SELECT TRUE FROM pg_namespace WHERE nspname=dest_schema) THEN
		EXECUTE FORMAT('CREATE SCHEMA IF NOT EXISTS %I', dest_schema);
	END IF;

	-- create audit table
	IF EXISTS (SELECT * FROM pg_tables WHERE schemaname=source_schema AND tablename=source_table) THEN
		EXECUTE FORMAT('CREATE TABLE IF NOT EXISTS %I.%I (
			id SERIAL NOT NULL,
			created TIMESTAMPTZ NOT NULL DEFAULT now(),
			usr TEXT NOT NULL,
			opr TEXT NOT NULL,
			before JSONB,
			after JSONB,
			query TEXT
		)', dest_schema, dest_table);
		
		-- create trigger on source table
		IF NOT EXISTS (SELECT * FROM pg_trigger WHERE NOT tgisinternal AND tgrelid=(source_schema||'.'||source_table)::regclass) THEN
			EXECUTE FORMAT('CREATE TRIGGER audit AFTER INSERT OR DELETE OR UPDATE ON %I.%I FOR EACH ROW EXECUTE PROCEDURE audit_table_log(%s, %s)',
				source_schema, source_table, dest_schema, dest_table);
		END IF;
	ELSE
		RAISE 'Table %.% does not exist.', source_schema, source_table;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.audit_table_log()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
	dest_schema TEXT := COALESCE(TG_ARGV[0], TG_TABLE_SCHEMA||'_audit');
	dest_table TEXT := COALESCE(TG_ARGV[1], TG_TABLE_NAME);
BEGIN
	-- save audit info
	IF (TG_OP = 'UPDATE' AND NEW.* IS DISTINCT FROM OLD.*) THEN
		EXECUTE FORMAT('INSERT INTO %I.%I (usr, opr, before, after, query) VALUES ($1, $2, $3, $4, $5)', dest_schema, dest_table)
			USING SESSION_USER::TEXT, TG_OP, row_to_json(OLD.*), row_to_json(NEW.*), CURRENT_QUERY();
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		EXECUTE FORMAT('INSERT INTO %I.%I (usr, opr, before, after, query) VALUES ($1, $2, $3, $4, $5)', dest_schema, dest_table)
			USING SESSION_USER::TEXT, TG_OP, row_to_json(NULL), row_to_json(NEW.*), CURRENT_QUERY();
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		EXECUTE FORMAT('INSERT INTO %I.%I (usr, opr, before, after, query) VALUES ($1, $2, $3, $4, $5)', dest_schema, dest_table)
			USING SESSION_USER::TEXT, TG_OP, row_to_json(OLD.*), row_to_json(NULL), CURRENT_QUERY();
		RETURN OLD;
	END IF;
	
	-- this should be an after trigger so return value is ignored
	RETURN NULL;
END;
$$;
