create or replace view organization_view as 
	select organization_name, link, tin, form_name
	from commercial_organization, establishment_form
	where fk_id_establishment_form = id_establishment_form;

create or replace view points_view as
	select sales_point_name, sales_point_address, organization_name
	from sales_point, commercial_organization
	where fk_id_commercial_organization = id_commercial_organization;

create or replace view order_view as
	select concat(client_name,' ', client_surname, ' ', client_patronymic) as client, order_address, order_status, order_date, sales_point_name 
	from order_, sales_point, client
	where fk_id_client = id_client and fk_id_sales_point = id_sales_point;

create or replace view product_view as
	select concat(product_type, ' ', brand_name) as product, product_size, country_name as country, organization_name as commercial_organization
	from brand , country, product, commercial_organization
	where (fk_id_brand = id_brand) and (fk_id_country = id_country) and (fk_id_commercial_organization = id_commercial_organization);

create or replace view receipt_view as
	select fk_id_order as order_id,	concat(product_type,' ',(select brand_name from brand where id_brand = fk_id_brand)) as product,
        concat(receipt_product_amount,' x ',receipt_product_price) as "amount*sum", order_date as "date"
	from receipt,product, order_;
