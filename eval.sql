/*evaluation*/


/* Vues */

CREATE VIEW  v_catalogue_produits
(pro_id,pro_ref,pro_name,cat_id,cat_name)
 AS SELECT pro_id,pro_ref,pro_name,cat_id,cat_name
 FROM products, categories
 WHERE pro_cat_id = cat_id



/* Programmer des procédures stockées */


DELIMITER |
CREATE PROCEDURE p_facture(IN p_numcom int(10), OUT p_total decimal(7,2))
BEGIN
   SELECT ord_id as 'numero facture', ord_order_date as 'date de la facture/vente', ord_ship_date as 'date de la livraison',
   ord_payment_date as 'date de paiement', concat(cus_lastname, cus_firstname) as 'nom client',
   cus_address as 'adresse client', pro_ref as 'référence du produit', pro_name as 'produit', cat_name as 'categorie produit',
   ode_unit_price as 'prix unitaire hors taxes/prix catalogue', ode_quantity as 'quantité', ode_discount as'remises'
   from orders
   join customers on orders.ord_cus_id=customers.cus_id
   join orders_details on orders_details.ode_ord_id=orders.ord_id
   join products on orders_details.ode_pro_id=products.pro_id
   join categories on categories.cat_id=products.pro_cat_id
   WHERE p_numcom=orders.ord_id;

select sum(ode_unit_price * ode_quantity) INTO p_total
from orders_details
join orders on orders_details.ode_ord_id=orders.ord_id
where p_numcom=orders.ord_id;

END |
DELIMITER ;


CALL p_facture (11, @prix);
SELECT @prix AS prix_facture; --un appel pour exécuter une procédure stockée


/* Programmer des triggers */



CREATE TABLE IF NOT EXISTS `commander_articles` ( --creation d'une table supplémentaire 
    codart varchar(11) not null,
    qte int(11) not null,
    date datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`codart`)
    ) ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE products ENGINE=InnoDB;


DELIMITER | --pas reussie, #1064 - Erreur de syntaxe près de 'INSERT INTO(codart, qte, date) VALUES (tr_codart, tr_qte, now())
CREATE trigger after_products_update
after UPDATE on products
FOR EACH ROW
BEGIN
DECLARE tr_codart varchar(11);
DECLARE tr_qte int(11);
SET tr_codart=products.pro_id;
SET tr_qte=products.pro_stock_alert;
INSERT INTO commander_articles(codart, qte, date) VALUES (tr_codart, tr_qte, now())
WHERE products.`pro_stock_alert`>products.`pro_stock`;
END |
DELIMITER ;



DELIMITER | --pas reussie, 2eme var, meme erreur
CREATE trigger after_products_update
after UPDATE on products
FOR EACH ROW
BEGIN
DECLARE tr_codart varchar(11);
DECLARE tr_qte int(11);
SET tr_codart=products.pro_id; 
SET tr_qte=products.pro_stock_alert;
UPDATE commander_articles
SET INSERT INTO(codart, qte, date) VALUES (tr_codart, tr_qte, now())
WHERE products.pro_stock_alert > new.pro_stock;
END |
