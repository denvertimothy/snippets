create or replace function concat_ws_text(sep text, variadic args text[])
returns text
language sql strict immutable as $$
	select concat_ws(sep, variadic args);
$$;