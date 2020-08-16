/*

	cast_interval_json.sql
	Ian Timothy, Thrive Data <ian@thrivedata.it>
	License: BSD
	
	Adds support for casting a value of type INTERVAL to JSON or JSONB.
		
	select make_interval(1, 2, 3, 4, 5, 6, 7.89)::jsonb as casted;
	select cast(make_interval(1, 2, 3, 4, 5, 6, 7.89) as jsonb) as casted;
	select cast_interval_jsonb(make_interval(1, 2, 3, 4, 5, 6, 7.89)) as casted;
	┌─────────────────────────────────────────────────────────────────────────────────────────┐
	│                                          casted                                         │
	├─────────────────────────────────────────────────────────────────────────────────────────┤
	│ {"days": 4, "mins": 6, "secs": 7, "hours": 5, "usecs": 890000, "years": 1, "months": 2} │
	└─────────────────────────────────────────────────────────────────────────────────────────┘
	
	Changelog:
	2020-08-13: Intial revision.
	
*/


begin;

create or replace function public.cast_interval_json(input interval)
returns json language sql as $$
    select
    json_strip_nulls(
	    json_build_object(
			'years', nullif(to_char(input, 'FMYYYY'), '0')::integer,
			'months', nullif(to_char(input, 'FMMM'), '0')::integer,
			'days', nullif(to_char(input, 'FMDD'), '0')::integer,
			'hours', nullif(to_char(input, 'FMHH24'), '0')::integer,
			'mins', nullif(to_char(input, 'FMMI'), '0')::integer,
			'secs', nullif(to_char(input, 'FMSS'), '0')::integer,
			'usecs', nullif(to_char(input, 'FMUS'), '000000')::integer
		)
    );
$$;

create or replace function public.cast_interval_jsonb(input interval)
returns jsonb language sql as $$
    select cast_interval_json(input)::jsonb;
$$;

create cast (interval as json) with function cast_interval_json(interval) as assignment;
create cast (interval as jsonb) with function cast_interval_jsonb(interval) as assignment;

commit;