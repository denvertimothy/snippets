create or replace function jsonb_merge(a jsonb, b jsonb)
returns jsonb language sql as $$
	select
		jsonb_object_agg(
			coalesce(ka, kb),
			case
				when va is null then vb
				when vb is null then va
				when jsonb_typeof(va) <> 'object' or jsonb_typeof(vb) <> 'object' then vb
				else jsonb_merge(va, vb)
			end
		)
	from
		jsonb_each(a) as t1(ka, va)
		full join jsonb_each(b) as t2(kb, vb) on (ka = kb);
$$;

create aggregate jsonb_merge_agg(jsonb) (
	sfunc = jsonb_merge,
	stype = jsonb,
	initcond = '{}'
);
