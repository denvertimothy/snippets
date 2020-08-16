create or replace function create_table_like(source_table regclass, dest_schema text, dest_table text)
	returns void language plpgsql as $$
declare
	rec record;
begin
	-- create table with not-nulls, check constraints, defaults, indexes, constraints (primary key, unique, exclude), storage settings, comments
	execute format('create table %s.%s (like %s including all)', dest_schema, dest_table, source_table);
	
	-- add foreign keys
	for rec in
		select oid, conname from pg_constraint where contype='f' and conrelid=source_table;
	loop
		execute format('alter table %s.%s add %s', dest_schema, dest_table, pg_get_constraintdef(rec.oid));
	end loop;
end;$$;
