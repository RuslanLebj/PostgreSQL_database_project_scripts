--1)
--Вставка
create procedure insert_establishment_form(a varchar)
	language sql
	as $$
	insert into establishment_form (form_name) values(a)
	$$;

create procedure insert_commercial_organization(a varchar, b varchar, c varchar, d int)
	language sql
	as $$
	insert into commercial_organization (organization_name, link, tin, fk_id_establishment_form)
	values(a,b,c,d)
	$$;

create procedure insert_sales_point(a varchar, b varchar, c int)
	language sql
	as $$
	insert into sales_point (sales_point_address, sales_point_name, fk_id_commercial_organization)
	values(a,b,c)
	$$;

create procedure insert_country(a varchar)
	language sql
	as $$
	insert into country (country_name) values(a)
	$$;

create procedure insert_brand(a varchar)
	language sql
	as $$
	insert into brand (brand_name) values(a)
	$$;

create procedure insert_product(a varchar, b varchar, c int, d int, e int)
	language sql
	as $$
	insert into product  (product_type, product_size, fk_id_commercial_organization, fk_id_brand, fk_id_country)
	values(a,b,c,d,e)
	$$;

create or replace procedure insert_client(a varchar, b varchar, c varchar, d date, e varchar)
	language sql
	as $$
	insert into client (client_name, client_surname, client_patronymic, client_birth, client_phone)
	values(a,b,c,d,e)
	$$;

create procedure insert_order(a varchar, b bool, c date, d int, e int)
	language sql
	as $$
	insert into order_ (order_address, order_status,order_date, fk_id_client, fk_id_sales_point)
	values(a,b,c,d,e)
	$$;

create procedure insert_receipt(a int, b int, c int, d int)
	language sql
	as $$
	insert into receipt (receipt_product_amount, receipt_product_price, fk_id_order, fk_id_product)
	values(a,b,c,d)
	$$;

--Удаление
create procedure delete_establishment_form(a int)
	language sql
	as $$
	delete from establishment_form where id_establishment_form = a
	$$;

create procedure delete_commercial_organization(a int)
	language sql
	as $$
	delete from commercial_organization where id_commercial_organization = a
	$$;

create procedure delete_sales_point(a int)
	language sql
	as $$
	delete from sales_point where id_sales_point = a
	$$;
	
create procedure delete_country(a int)
	language sql
	as $$
	delete from country where id_country = a
	$$;

create procedure delete_brand(a int)
	language sql
	as $$
	delete from brand where id_brand = a
	$$;

create procedure delete_product(a int)
	language sql
	as $$
	delete from product where id_product = a
	$$;

create procedure delete_client(a int)
	language sql
	as $$
	delete from client where id_client = a
	$$;

create procedure delete_order(a int)
	language sql
	as $$
	delete from order_ where id_order = a
	$$;

create procedure delete_receipt(a int)
	language sql
	as $$
	delete from receipt where id_receipt = a
	$$;

--Редактирование 
create procedure update_establishment_form(a int, b varchar)
	language sql
	as $$
	update establishment_form set form_name = b 
	where id_establishment_form = a
	$$;

create procedure update_commercial_organization(a int, b varchar, c varchar, d varchar)
	language sql
	as $$
	update commercial_organization set organization_name = b, link = c, tin = d
	where id_commercial_organization = a
	$$;

create procedure update_sales_point(a int, b varchar, c varchar)
	language sql
	as $$
	update sales_point set sales_point_address = b, sales_point_name = c
	where id_sales_point = a
	$$;

create procedure update_country(a int, b varchar)
	language sql
	as $$
	update country set country_name = b
	where id_country = a
	$$;
	
create procedure update_brand(a int, b varchar)
	language sql
	as $$
	update brand set brand_name = b
	where id_brand = a
	$$;

create procedure update_product(a int, b varchar, c varchar)
	language sql
	as $$
	update product set product_type = b, product_size = c
	where id_product = a
	$$;
	
create procedure update_client(a int, b varchar, c varchar, d varchar, e date, f varchar)
	language sql
	as $$
	update client set client_name = b, client_surname  = c, client_patronymic = d, client_birth = e, client_phone = f
	where id_client = a
	$$;

create procedure update_order(a int, b varchar, c bool, d date)
	language sql
	as $$
	update order_ set order_address = b, order_status = c, order_date = d
	where id_order = a
	$$;
	
create procedure update_receipt(a int, b int, c int)
	language sql
	as $$
	update receipt set receipt_product_amount = b, receipt_product_price = c
	where id_receipt = a
	$$;
	
--2)
--Функция  с  пустыми  входными  параметрами,  результат  которой скалярное выражение
--Найдём общий оборот за этот год. Считаем что деньги получены если заказ выполнен 
create or replace function curr_year_income()
returns money
as
$$
declare 
	total_sum money:= 0;
	some_rec record;
begin	
	for some_rec in
		select receipt_product_price, order_date, order_status 
		from receipt join order_
		on id_order = fk_id_order
		where date_part('year', order_date) = date_part('year', CURRENT_DATE) and order_status = true
		loop 
			total_sum := total_sum + some_rec.receipt_product_price;	
		end loop;
	return total_sum;
exception
	when others then
		raise exception 'ERROR!';
end;
$$
language plpgsql;

select * from curr_year_income();

--Функция со скалярным аргументом, результат которой соответствует типу существующей таблицы
--Поиск всех невыполненных заказов, срок которых превышает количество месяцев
create or replace function order_prescription_func(month_amount int)
returns setof order_ as
$$
declare 
	order_info order_%rowtype;
	found_order bool := false;
	diff int;
	some_rec record;
begin	
	for some_rec in
		select * 
		from order_
		loop
			diff := ((date_part('year',current_date) - date_part('year',some_rec.order_date)) * 12) + (date_part('month', current_date) - date_part('month', some_rec.order_date));
			if diff > month_amount and some_rec.order_status = false then
				order_info = some_rec;
				found_order = true;
				return next order_info;
			end if;				
		end loop;
if not found_order then
	raise exception 'Заказов по указанному параметру не найдено!';
end if;

return;
end;
$$
language plpgsql;
--Пояснение: если заказ был более (2) месяцев назад и не выполнен, то запись выводится
select * from order_prescription_func(2)
order by order_date desc;

--Функция с выходными аргументами, определенными с помощью OUT.
--Функция для вывода статистики по возрасту клиентов
create or replace function client_age_statistics(out min_age int,out max_age int,out avg_age numeric)
as $$
begin
	select 
	min(date_part('year', age(CURRENT_DATE,client_birth))),
	max(date_part('year', age(CURRENT_DATE,client_birth))),
  	date_part('year', avg(age(CURRENT_DATE,client_birth)))
  	into min_age, max_age, avg_age
  	from client;
end;
$$
language plpgsql;

select * from client_age_statistics();

--3)
--Триггеры на создание/обновление/удаление данных
--Функция проверки на совпадающий номер
create or replace function check_phone_trigger()
returns trigger
as $$
begin 
	if exists (select 1 from client where client_phone = new.client_phone)
	then raise exception 'Такой номер телефона уже зарегестрирован';
	end if;
	return new;
end;
$$
language plpgsql;

--Триггер на вставку нового клиента
create or replace trigger insert_client
	before insert on client
	for each row
	execute function check_phone_trigger();

--Триггер на обновление информации клиента
create or replace trigger update_client
	before update on client
	for each row
	execute function check_phone_trigger();

--Попытаемся создать запись клиент с уже зарегистрированным номером
call insert_client('Иванов', 'Иван', 'Иванович', '11/11/2003', '2598543907');

--Попытаемся изменить номер на чужой уже зарегистрированный
call update_client(1 ,'Иванов', 'Иван', 'Иванович', '11/11/2003', '2598543907');

--Функция для проверки статуса заказа
create or replace function status_check_trigger()
returns trigger
as $$
begin
	if old.order_status = false
	then raise exception 'Невозможно удалить невыполненный заказ.';
	end if;
	return old;
end;
$$
language plpgsql;

--Триггер удаления записи заказ
create or replace trigger delete_order
	before delete on order_
	for each row
	execute function status_check_trigger();

--Попытаемся удалить невыполненный заказ
call delete_order(55);
