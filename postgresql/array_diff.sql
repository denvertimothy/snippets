create or replace function array_diff(anyarray, anyarray)
returns anyarray language sql immutable as $$
select array(
  select unnest($2)
  except
  select unnest($1)
);$$;

create operator - (
	procedure = array_diff,
	leftarg=anyarray,
	rightarg=anyarray
);