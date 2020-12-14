/*Programmer des vues*/

/* Exercice 1 : base hotel */

/* Afficher la liste des hôtels avec leur station.*/
CREATE VIEW v_hotels_station
AS
SELECT hot_id, hot_nom, hot_categorie, hot_ville, sta_nom, sta_id
FROM hotel, station
WHERE hot_sta_id=sta_id

/* Afficher la liste des chambres et leur hôtel */
CREATE VIEW v_chambres_hotels
AS
SELECT cha_numero, cha_capacite, hot_id, hot_nom, hot_categorie, hot_ville
FROM chambre, hotel
WHERE cha_hot_id=hot_id

/* Afficher la liste des réservations avec le nom des clients */
create VIEW v_reservations_clients
as select res_id, res_date, res_date_debut, cli_nom, cli_prenom, cli_id
from reservation, client
WHERE res_cli_id=cli_id

/* Afficher la liste des chambres avec le nom de l'hôtel et le nom de la station */
CREATE VIEW v_chambres_hotels_stations
AS SELECT cha_id, cha_numero, hot_nom, hot_categorie, sta_id, sta_nom
FROM chambre, hotel, station
where cha_hot_id=hot_id and
hot_sta_id=sta_id

/* Afficher les réservations avec le nom du client et le nom de l'hôtel */
CREATE VIEW v_reservations_clients_hotels
as SELECT res_id, res_date, res_date_debut, cli_nom, cli_prenom, cli_id, hot_nom, hot_categorie, hot_id
FROM reservation
JOIN client
ON res_cli_id=cli_id
join chambre
ON res_cha_id=cha_id
join hotel
on cha_hot_id=hot_id
group by res_id


/* Exercice 2 : base gescom */

/* 1.v_Details */
create VIEW v_Details
AS SELECT ode_pro_id as 'code produit', ode_quantity as 'QteTot', (ode_unit_price*ode_quantity-ode_discount) as 'PrixTot'
from orders_details

/* 2.v_Ventes_Zoom  J'ai pas compris c'que c'est ZOOM */
create VIEW v_Ventes_Zoom
as select * from orders_details
where ode_pro_id=ZOOM



/* Programmer des procédures stockées */


/* Exercice 1 : création d'une procédure stockée sans paramètre */
DELIMITER |
CREATE PROCEDURE Lst_Suppliers()
BEGIN
    SELECT DISTINCT(sup_id), sup_name from suppliers
    join products ON products.pro_sup_id=suppliers.sup_id
    join orders_details ON orders_details.ode_pro_id=products.pro_id
    where ode_quantity is not null;
END | 

call Lst_Suppliers();--un appel pour exécuter une procédure stockée

SHOW CREATE PROCEDURE Lst_Suppliers;


/* Exercice 2 : création d'une procédure stockée avec un paramètre en entrée */
DELIMITER |
CREATE PROCEDURE Lst_Rush_Orders(IN p_status VARCHAR(100))
BEGIN
   SELECT * from orders
   WHERE ord_status=p_status;
END |

DELIMITER ;

CALL Lst_Rush_Orders("commande urgente");--un appel pour exécuter une procédure stockée


/* Exercice 3 : création d'une procédure stockée avec plusieurs paramètres */
DELIMITER |
CREATE PROCEDURE CA_Supplier(IN p_id_fou int(10), IN p_annee year, OUT p_ca decimal(7,2))
BEGIN
IF ISNULL(p_id_fou) 
  THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "le code fournisseur n'est pas valide";
   else
  SELECT SUM(ode_unit_price * ode_quantity) INTO p_ca
   FROM orders_details
   join orders on orders.ord_id=orders_details.ode_ord_id
   join products on products.pro_id=orders_details.ode_pro_id
   join suppliers on suppliers.sup_id=products.pro_sup_id
   where SUBSTRING(orders.ord_order_date,1,4)=p_annee AND
   suppliers.sup_id=p_id_fou;
   END IF;
END |

DELIMITER ;

call CA_Supplier('2', '2016', @chiffre); --des appels pour exécuter une procédure stockée

select @chiffre as "chiffre d'affaires"; --chiffre d'affaires 247.58

call CA_Supplier('2', '2020', @chiffre);
select @chiffre as "chiffre d'affaires"; --chiffre d'affaires 517.05

call CA_Supplier('2', '2019', @chiffre);
select @chiffre as "chiffre d'affaires"; --chiffre d'affaires 329.28

call CA_Supplier('1', '2012', @chiffre);
select @chiffre as "chiffre d'affaires"; --chiffre d'affaires 683.29

call CA_Supplier('4', '2012', @chiffre);
select @chiffre as "chiffre d'affaires"; --chiffre d'affaires 2609.90



/* Programmer des triggers */


DELIMITER |
CREATE TRIGGER maj_total 
AFTER INSERT ON lignedecommande
FOR EACH ROW
BEGIN
    DECLARE id_c int(11);
    DECLARE tot decimal(9,2);
    SET id_c = NEW.id_commande;
    SET tot = (SELECT sum(prix*quantite) FROM lignedecommande WHERE id_commande=id_c);
    UPDATE commande SET total=tot WHERE id=id_c;
END |
DELIMITER ;




