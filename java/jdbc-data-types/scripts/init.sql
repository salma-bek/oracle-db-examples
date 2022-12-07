
-- Table used for Generation of XML and JSON from Releation table
create table orders(
    orderId          number generated by default on null as identity primary key,
    productId        number,
    order_count      number,
    order_date       date,
    order_invoice_id number
);

insert into orders(productId, order_count, order_date, order_invoice_id)
values (3, 1, to_date('11/29/2022', 'MM/DD/YYYY'), 219);
insert into orders(productId, order_count, order_date, order_invoice_id)
values (2, 2, to_date('11/29/2022', 'MM/DD/YYYY'), 219);
insert into orders(productId, order_count, order_date, order_invoice_id)
values (4, 2, sysdate, 218);
insert into orders(productId, order_count, order_date, order_invoice_id)
values (2, 5, sysdate, 218);
insert into orders(productId, order_count, order_date, order_invoice_id)
values (3, 1, sysdate, 218);

-- JSON column example
CREATE TABLE PRODUCTS(
    productId          NUMBER generated by default on null as identity primary key,
    productInformation json
);

insert into products(productInformation)
values ('{
  "Title": "Gone the Days of Summer",
  "ProductType": "Book",
  "Author": "Eliza Smith",
  "Stock": 5
}');

insert into products(productInformation)
values ('{
  "Title": "At the End of the Universe and Spring",
  "ProductType": "Book",
  "Author": "Frank Thorn",
  "Stock": 2
}');

insert into products(productInformation)
values ('{
  "Title": "As Calm as Winter Nights",
  "ProductType": "Book",
  "Stock": 0
}');

-- XMLTYPE as a table example
CREATE TABLE VENDOR_INVOICES of XMLTYPE;

insert into VENDOR_INVOICES values(XMLTYPE('<?xml version="1.0"?>
<Invoice><InvoiceId>273</InvoiceId></Invoice>'));

-- XMLTYPE as a column example
CREATE TABLE INVOICES(
    invoiceId NUMBER generated by default on null as identity primary key,
    invoice   xmltype
);

insert into invoices(invoice) values (XMLTYPE('<?xml version="1.0"?>
<Invoice>
    <InvoiceId>272</InvoiceId>
    <ShippingInformation>
        <ContactInformation>
            <FirstName>Jane</FirstName>
            <LastName>Smith</LastName>
            <Phone>7408812361</Phone>
        </ContactInformation>
        <ShippingAddress>
            <Address>33079 23 Mile Rd</Address>
            <City>Chesterfield</City>
            <State>Michigan</State>
            <Zip>48047</Zip>
            <Country>United States</Country>
        </ShippingAddress>
    </ShippingInformation>
    <Orders>
        <Order>
            <ProductId>3</ProductId>
            <Count>5</Count>
        </Order>
    </Orders>
</Invoice>
'));


-- sys_refcursor example with a function
create or replace function get_information return sys_refcursor is
    v_refc sys_refcursor;
begin
    open v_refc for
        select p.productInformation from products p;
    return v_refc;
end;
/

-- REF Cursor Package
CREATE OR REPLACE PACKAGE products_data AUTHID DEFINER AS
    TYPE prdcursorA IS REF CURSOR RETURN products%ROWTYPE;
    TYPE prdcursorB IS REF CURSOR;
    PROCEDURE open_prod_cv_a(products_curvar IN OUT prdcursorA);
    PROCEDURE open_prod_cv_b(products_curvar IN OUT prdcursorB, source VARCHAR2);
END products_data;
/
CREATE or REPLACE PACKAGE BODY products_data AS
    --- strong cusror
    PROCEDURE open_prod_cv_a(products_curvar IN OUT prdcursorA) IS
    BEGIN
        OPEN products_curvar FOR SELECT * from products;
    END open_prod_cv_a;
    --- weak cursor (different return types)
    PROCEDURE open_prod_cv_b(products_curvar IN OUT prdcursorB, source VARCHAR2) IS
    BEGIN
        CASE source
            WHEN 'Products' then OPEN products_curvar FOR SELECT * FROM PRODUCTS;
            WHEN 'Invoices' then OPEN products_curvar FOR SELECT * FROM INVOICES;
            WHEN 'Orders' then OPEN products_curvar FOR SELECT * FROM ORDERS;
            END CASE;

    END open_prod_cv_b;
END products_data;
/

-- Associative Array procedure
create or replace procedure get_order_status(status_id in number, return_status out varchar2) is
    TYPE status IS TABLE OF VARCHAR2(250)
        INDEX BY VARCHAR2(64);
    orderStatus status;
begin
    orderStatus(1) := 'Received';
    orderStatus(2) := 'Processing';
    orderStatus(3) := 'Shipped';
    orderStatus(4) := 'Completed';
    orderStatus(5) := 'Cancelled';

    return_status := orderStatus(status_id);
end;
/
