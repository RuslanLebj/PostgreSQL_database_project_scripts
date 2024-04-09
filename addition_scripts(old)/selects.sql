--a) Запрос с условием на числовые данные (>=,<=,>,<,=, between);
--Сводка заказов за апрель.
select * 
from order_
where order_date between '01/04/2023' and '30/04/2023';

--b) Запрос с условием на текстовые данные (LIKE, IN);
--Сводка по клиентам у которых фамилия начинается на C
select *
from client
where client_surname like 'C%';

--c) Запрос с вычисляемым полем;
--Сводка с общей суммой для каждой позиции в чеке
select *, receipt_product_amount*receipt_product_price as total
from receipt

--d)запрос к нескольким таблицам (без явного указания JOIN);
--Полное описание продукта
select concat(product_type, ' ', brand_name) as product,
		product_size,
		country_name as country,
		organization_name as commercial_organization
from brand , country, product, commercial_organization
where (fk_id_brand = id_brand) and (fk_id_country = id_country) and (fk_id_commercial_organization = id_commercial_organization)

--e)запросы с агрегирующими функциями (AVG, SUM, COUNT, MIN, MAX);
--Возраст самого старшего, младшего клиентов и средний возраст всех клиентов
select
  max(date_part('year', age(CURRENT_DATE,client_birth))) as client_max_age,
  min(date_part('year', age(CURRENT_DATE,client_birth))) as client_min_age,
  date_part('year', avg(age(CURRENT_DATE,client_birth))) as client_avg_age
from client;

--f) запрос с группировкой (GROUP BY);
--Сводка по странам и количеству уникальных производимых ими товаров
select (select country_name from country 
        where id_country = fk_id_country) as country, COUNT(*) as counter
from product
group by fk_id_country
order by counter desc;

--g) запрос с сортировкой (ORDER BY);
--Сводка по заказам отсортированным по статусу и дате
select *
from order_
order by order_status, order_date;

--h) запрос с вложенным подзапросом (не менее 3 видов);
--Чек
select fk_id_order as order_id,
		concat(
		(select product_type from product
        where id_product = fk_id_product),' ',
        (select (select brand_name from brand 
        where id_brand = fk_id_brand) from product
        where id_product = fk_id_product)) as product,
        concat(receipt_product_amount,' x ',receipt_product_price) as "amount*sum"
from receipt
--Путь от строки чека до клиента
select  id_receipt,
		fk_id_order as order_id,
        (select (select concat(client_name,' ', client_surname, ' ', client_patronymic) from client 
        where id_client = fk_id_client) from order_
        where id_order = fk_id_order) as client
from receipt
--Путь от строки чека до торговой точки 
select  id_receipt,
		fk_id_order as order_id,
        (select (select sales_point_name from sales_point 
        where id_sales_point = fk_id_sales_point) from order_
        where id_order = fk_id_order) as client
from receipt

--Добавим торговые точки, у которых название совпадает с названием коммерческих организаций
insert into sales_point (sales_point_address, sales_point_name, fk_id_commercial_organization) values ('Герцена,58', 'Street Veat' , 1);
insert into sales_point (sales_point_address, sales_point_name, fk_id_commercial_organization) values ('Малыгина,18', 'Collier-Ryan' , 24);
insert into sales_point (sales_point_address, sales_point_name, fk_id_commercial_organization) values ('Васнецова,12', 'Zieme-Hudson' , 12);

--i) запрос с оператором UNION;
--Выборка коммерческих организаций и магазинов, магазины названия которых совпадает с названием ком. орг. не дублируются
select sales_point_name
from sales_point
union select organization_name
from commercial_organization;

--j) запрос с оператором INTERSECT;
--Выборка магазинов, которые имеют одинаковое название с коммерческой организацией
select sales_point_name
from sales_point
intersect select organization_name
from commercial_organization;

--k) запрос с оператором EXCEPT;
--Выборка магазинов, которые имеют отличное название от коммерческой организации
select sales_point_name
from sales_point
except select organization_name
from commercial_organization;

--l) запрос с выражением CASE;
--Дополнительно маркируем по весу продукта
select * ,
case when (replace(product_size, ',', '.')::decimal < 0.300) then 'Лёгко'
		when (replace(product_size, ',', '.')::decimal < 0.700) then 'Средний вес'
		else 'Тяжело'
		end as weight_mark
from product

--m) запрос с оператором JOIN (пять видов);
--Сводка клиентов не сделавших заказ ни разу
select id_client, concat(client_name,' ', client_surname, ' ', client_patronymic)  as client,id_order 
FROM order_ right join client 
on fk_id_client  = id_client
where id_order is null
order by id_client;
--Сводка заказ-клиент
select id_order, order_address, order_date, concat(client_name,' ', client_surname, ' ', client_patronymic)  as client
from order_ left join client 
on fk_id_client  = id_client;
--Добавим один анонимный заказ
insert into order_ (order_address, order_status, order_date, fk_id_sales_point) values ('Изумрудная,15', '0', '22/04/2023', 23);
--Сводка заказов без авторизации
select id_order, order_address, order_date, id_client as client
from order_ full join client 
on fk_id_client  = id_client
where id_client is null;
--Сводка по всем организациям зарегистрированным как ООО
select id_commercial_organization, organization_name, form_name  as form
from commercial_organization full join establishment_form 
on fk_id_establishment_form = id_establishment_form 
where id_establishment_form = 1;
--Различные сочетания продукт-страна
select concat(product_type, ' ', brand_name) as product, country_name
from product, brand cross join country


--n) иерархический запрос.
--Сводная таблица принадлежности торговых точек к каждой торговой организации
create temporary table temp1 on commit drop as(
select id_commercial_organization as id, organization_name as name, cast(null as int) as parent_id
from commercial_organization 
union all 
select cast(null as int) as id, sales_point_name as name, fk_id_commercial_organization as parent_id
from sales_point
);

with recursive t (id, parent_id, name, path) as (
    select t1.id, t1.parent_id, t1.name, cast(t1.name as varchar(100)) as path
    from temp1 t1
    UNION
    SELECT t2.id, t2.parent_id, t2.name, cast(t.path || '->' || t2.name as varchar(100))
      FROM temp1 t2 JOIN t ON t.parent_id = t2.id
  )
select name, path from t;



