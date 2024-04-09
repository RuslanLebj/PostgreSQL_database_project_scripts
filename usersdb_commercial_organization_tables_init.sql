create table establishment_form
(
    id_establishment_form SERIAL PRIMARY KEY,
    form_name VARCHAR(30)
);

create table commercial_organization
(
    id_commercial_organization SERIAL PRIMARY KEY,
    organization_name VARCHAR(50),
    link VARCHAR(30),
    TIN VARCHAR(12),
    fk_id_establishment_form int,
    foreign key(fk_id_establishment_form) references establishment_form (id_establishment_form)
);

create table brand
(
    id_brand SERIAL PRIMARY KEY,
    brand_name VARCHAR(20)
);

create table country
(
    id_country SERIAL PRIMARY KEY,
    country_name VARCHAR(53)
);

create table product
(
    id_product SERIAL PRIMARY KEY,
    product_type VARCHAR(30),
    product_size VARCHAR(10),
    fk_id_commercial_organization int,
    foreign key (fk_id_commercial_organization) references commercial_organization (id_commercial_organization),
    fk_id_brand int,
    foreign key (fk_id_brand) references brand (id_brand),
    fk_id_country int,
    foreign key (fk_id_country) references country (id_country)
);

create table client
(
    id_client SERIAL PRIMARY KEY,
    client_name VARCHAR(15),
    client_surname VARCHAR(15),
    client_patronymic VARCHAR(15),
    client_birth DATE,
    client_phone VARCHAR(11) 
);
create table sales_point
(
    id_sales_point SERIAL PRIMARY KEY,
    sales_point_address VARCHAR(30),
    sales_point_name VARCHAR(20),
    fk_id_commercial_organization int,
    foreign key (fk_id_commercial_organization) references commercial_organization (id_commercial_organization)
);
create table order_
(
    id_order SERIAL PRIMARY KEY,
    order_address VARCHAR(30),
    order_status BOOL,
    order_date DATE,
    fk_id_client int,
    foreign key (fk_id_client) references client (id_client),
    fk_id_sales_point int,
    foreign key (fk_id_sales_point) references sales_point (id_sales_point)
);
create table receipt
(
    id_receipt SERIAL PRIMARY KEY,
    receipt_product_amount int2,
    receipt_product_price numeric,
    fk_id_order int,
    foreign key (fk_id_order) references order_ (id_order),
    fk_id_product int,
    foreign key (fk_id_product) references product (id_product)
);