create or replace function vehicle_vin_transliterate_digit(c character) returns integer language sql as $$
	select ((position(c in '0123456789.ABCDEFGH..JKLMN.P.R..STUVWXYZ')-1) % 10)::integer;
$$;

create or replace function vehicle_vin_weight_positiion(character_position integer) returns integer language sql as $$
	select position(substring('8765432X098765432' from character_position for 1) in '0123456789X')-1;
$$;

create or replace function vehicle_vin_check_digit(vin text) returns character language plpgsql as $$
declare
	vin_array text[] := string_to_array(vin, null);
	check_sum integer := 0;
begin
	for i in 1..17 loop
		check_sum = check_sum + (vehicle_vin_transliterate_digit(vin_array[i]) * vehicle_vin_weight_positiion(i));
	end loop;
	return substring('0123456789X' from (check_sum % 11 + 1) for 1);
end;$$;

create or replace function vehicle_vin_validate(vin text) returns boolean language plpgsql as $$
begin
	if(char_length(vin) = 17 and substring(vin, 9, 1) = vehicle_vin_check_digit(vin)) then
		return true;
	end if;
	return false;
end;$$;
