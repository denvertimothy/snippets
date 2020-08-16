create domain email_address as citext check (value ~* '^[a-z0-9._%+-]+@(?:[a-z0-9-]+\.)+[a-z]{2,16}$');
create type email_contact as (address email_address, name text);

create domain phone_country_code as text check (value ~ '^[0-9]{1,3}$');
create domain phone_subscriber_number as text check (value ~ '^[0-9]{9,14}$');
create type phone_intl as (country_code phone_country_code, number phone_subscriber_number);

create domain phone_e164 as text check (value ~ '^\+?[0-9]{10,15}$');
create domain phone_nanp as text check (value ~ '^[0-9]{10}$');
