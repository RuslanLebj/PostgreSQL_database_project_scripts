--Установка расширения       
create extension tablefunc;  
--Создаём промежуточную таблицу brand/product_type/amount
create temporary table temp1 on commit drop as(
select (select (select brand_name from brand 
        where id_brand = fk_id_brand) from product
        where id_product = fk_id_product) as brand,
        (select product_type from product
        where id_product = fk_id_product) as product_type,
        receipt_product_amount as amount
        from receipt);   
--Построение сводной таблицы
select * from crosstab 
    (
    $$select coalesce(temp1.product_type, 'total_sum') as product,
	     		coalesce(temp1.brand, 'total_sum') as brand,	         	         
	     		sum(temp1.amount) as agg
      	from temp1
      	group by cube(temp1.brand, temp1.product_type)
      	order by product_type, brand $$,
    $$ (select distinct tt.brand as brand
      			from temp1 tt
      			order by brand )
      			union all
      			select 'total_sum' $$)
   as cst("product" varchar, "Adidas" bigint, "Nike" bigint,
  			"Puma" bigint, "Fila" bigint, "Diamond" bigint, "Reebok" bigint, "Kappa" bigint, 
  			"Vans" bigint, "Columbia" bigint, "total_sum" bigint);
  			