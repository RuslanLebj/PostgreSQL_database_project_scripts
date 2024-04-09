--создаем две новых роли
create role role1 login;
create role role2 login;
--проверяем
select rolname from pg_catalog.pg_roles; 


--наделяем первую роль привилегиями на часть таблиц
grant select, insert, update on receipt to role1;
grant select, insert, update on product to role1;
grant select, insert, update on sales_point to role1;
--проверяем
select
	table_schema,
	table_name,
	privilege_type
from
	information_schema.table_privileges
where
	grantee = 'role1';


--назначим второй роли первую в качестве роли
grant role1 to role2;
--проверяем(просморим унаследованные привелегии для role2 и привилегии role1)
select
	r.rolname as user_name,
	c.oid::regclass as table_name,
	p.perm as privilege_type
from
	pg_class c
cross join pg_roles r
cross join unnest(array['select', 'insert', 'update', 'delete', 'truncate' , 'references', 'trigger']) p(perm)
where
	c.relkind = 'r'
	and c.relnamespace not in (
	select
		oid
	from
		pg_namespace
	where
		nspname in ('pg_catalog', 'information_schema'))
	and has_table_privilege(r.rolname,
	c.oid,
	p.perm)
	and (r.rolname = 'role1'
		or r.rolname = 'role2');

--отменим одну из привилегий (отменим привилегию insert из sales_point)
revoke insert on sales_point from role1;
--проверяем
select
	table_schema,
	table_name,
	privilege_type
from
	information_schema.table_privileges
where
	grantee = 'role1';

--изменим первую роль (зададим срок действия пароля)
alter role role1 WITH PASSWORD 'hu8jmn3';
--проверяем
select rolname, rolvaliduntil from pg_catalog.pg_roles where rolname = 'role1'; 

--удалим вторую роль
drop role role2
--проверяем
select rolname from pg_catalog.pg_roles; 

