begin;

create table system_users (
	id uuid primary key default gen_random_uuid(),
	name text not null check (trim(name) <> '')
);

create table system_roles (
	id text primary key default random_md5() check (trim(id) <> ''),
	name text not null check (trim(name) <> ''),
	active boolean not null default true
);

insert into system_roles (name) values
	('System Administrator'),
	('Account Executive');
	
create table system_permissions (
	id text primary key default random_md5() check (trim(id) <> ''),
	name text not null,
	active boolean not null default true
);

insert into system_permissions (id, name) values
	('data.users', 'Data - Users'),
	('data.roles', 'Data - Roles');

create table system_roles_permissions (
	id uuid primary key default gen_random_uuid(),
	role_id text not null references system_roles(id),
	permissions_id text not null references system_permissions(id),
	grants bit(6) not null default b'0000000'::bit(6)   -- select, update, insert, delete, manager, admin
);

create table system_users_roles (
	id uuid primary key default gen_random_uuid(),
	user_id integer not null references system_users(id),
	role_id text not null references system_roles(id),
	unique (user_id, role_id)
);

alter table users add column permissions_superuser boolean not null default false;
update users set permissions_superuser=true where id in (1, 2);
	
alter table franchises add column account_executive_id integer not null default 1 references users(id);


CREATE OR REPLACE FUNCTION system_permissions_grants_compose(sel BOOLEAN DEFAULT FALSE, up BOOLEAN DEFAULT FALSE, ins BOOLEAN DEFAULT FALSE, del BOOLEAN DEFAULT FALSE, mgr BOOLEAN DEFAULT FALSE, adm BOOLEAN DEFAULT FALSE)
RETURNS BIT(6) LANGUAGE sql AS $$
	SELECT ((sel::INTEGER * 1) + (up::INTEGER * 2) + (ins::INTEGER * 4) + (del::INTEGER * 8) + (mgr::INTEGER * 16) + (adm::INTEGER * 32))::BIT(6);
$$;


CREATE OR REPLACE FUNCTION system_permissions_check(user_id INTEGER, permissions_id TEXT, grants BIT(6))
RETURNS BOOLEAN LANGUAGE sql AS $$
	WITH is_superuser AS (
		SELECT permissions_superuser::INTEGER AS count FROM system_users WHERE id=$1
	),
	is_permitted AS (
		SELECT
			COUNT(rp.*)::INTEGER AS count
		FROM system_users AS u
			LEFT JOIN system_users_roles AS ur ON (ur.user_id = u.id)
			LEFT JOIN system_roles AS r ON (ur.role_id = r.id)
			LEFT JOIN system_roles_permissions AS rp ON (rp.role_id = r.id)
			LEFT JOIN system_permissions AS p ON (rp.permissions_id = p.id)
		WHERE u.id=$1 AND p.id=$2 AND rp.grants & $3 = $3
	)
	SELECT ((SELECT count FROM is_superuser) + (SELECT count FROM is_permitted))::BOOLEAN;
$$;


CREATE OR REPLACE FUNCTION system_permissions_users(permissions_id TEXT, grants BIT(6))
RETURNS users LANGUAGE sql AS $$
	SELECT u.*
	FROM system_users AS u
		LEFT JOIN system_users_roles AS ur ON (ur.user_id = u.id)
		LEFT JOIN system_roles AS r ON (ur.role_id = r.id)
		LEFT JOIN system_roles_permissions AS rp ON (rp.role_id = r.id)
		LEFT JOIN system_permissions AS p ON (rp.permissions_id = p.id)
	WHERE p.id=$1 AND rp.grants & $2 = $2;
$$;


commit;	
