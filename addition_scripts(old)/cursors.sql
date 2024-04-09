--создать связанный с простым запросом курсор и использовать цикл для перемещения по нему MOVE 
--и в теле цикла менять каждую четную строку и удалять каждую нечетную;
create or replace function update_or_delete() 
returns void as $$
declare 
	curs cursor for select * from receipt order by id_receipt;
	counter int := 0; 
begin
	open curs;
	loop
		move next from curs;
		exit when not found;
		counter := counter + 1;
		if counter % 2 = 0 then
			update receipt 
			set receipt_product_price = receipt_product_price * 0.9
			where current of curs;
		else 
			delete from receipt where current of curs;
		end if;
	end loop;
	close curs;
end;
$$
language plpgsql;
--Вызов 
select update_or_delete();

--Cоздать связанный с параметрическим запросом курсор и вывести данные из пятой с конца строки на экран, для перемещения использовать FETCH;
--В качестве передаваемого параметра порядковый номер с конца 
create or replace function fetch_by_serial(serial_num int)
returns setof receipt as $$
declare 
	curs cursor(num int) for 
	select * from receipt order by id_receipt
	offset(select count(*) - num from receipt) limit 1;
	some_rec receipt%rowtype;
	row_amount int;
begin
	select count(*) into row_amount from receipt;
	if serial_num > row_amount then
		raise exception 'Количество строк в таблице меньше, чем передаваемое значение';
	end if;
	open curs(serial_num);
	loop
		fetch curs into some_rec;
		exit when not found;
		return next some_rec;
	end loop;
	close curs;
	return;
end;
$$ language plpgsql;
--Вызов
select fetch_by_serial(5);

--Создать несвязанный курсор и открыть его для динамически создаваемого запроса.
do $$
declare
	refcurs refcursor;
	some_rec record;
	query text;
	counter integer := 0;
begin
	query := 'select * from receipt';
	open refcurs for execute query;
	loop
		counter := counter + 1;
		fetch next from refcurs into some_rec;
		exit when not found;
		raise notice '%. %',counter, some_rec;
	end loop;
	close refcurs;
end
$$;