create or replace function natrual_sort_key(text, integer default 9)
returns text language sql as $$
	select regexp_replace(
		regexp_replace($1, '[0-9]+', repeat('0', $2) || '\&', 'g'),
		'[0-9]*([0-9]{'||$2||'})',
		'\1',
		'g'
	);
$$;
