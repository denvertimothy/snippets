create or replace function import_mysql(
	foreign_host text,
	foreign_port text,
	foreign_username text,
	foreign_password text,
	foreign_database text,
	local_server text,
	local_user text,
	local_schema text,
	change_date_types_to_text boolean default false
) returns void
language plpgsql
as $function$
declare
	t record;
begin
	-- install extension
	create extension if not exists mysql_fdw;
	
	-- create local schema
	execute format($$create schema if not exists %I$$, local_schema);
	
	-- create foreign server
	execute format($$create server %I foreign data wrapper mysql_fdw options (host '%s', port '%s')$$, local_server, foreign_host, foreign_port);
	
	-- create user mapping
	execute format($$create user mapping for %I server %I options (username '%s', password '%s')$$, local_user, local_server, foreign_username, foreign_password);
	
	-- import foreign schema
	execute format($$import foreign schema %I from server %I into %I$$, foreign_database, local_server, local_schema);
	
	-- change dates/times to text
	if(change_date_types_to_text is true) then
		for t in
			select attrelid::regclass, n.nspname, c.relname, a.attname
			from pg_attribute as a
				join pg_class as c on (a.attrelid = c.oid)
				join pg_namespace as n on (c.relnamespace = n.oid)
			where n.nspname=local_schema
				and a.attname like '%_at'
		loop
			execute format('alter foreign table %I.%I alter column %I type text', t.nspname, t.relname, t.attname);
		end loop;
	end if;
end;
$function$;
