-- NIVEL 1 Ejercicio 1:

USE transactions;
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    );
SELECT * FROM user;    

CREATE TABLE IF NOT EXISTS credit_card(
    id VARCHAR(20) PRIMARY KEY,         
    iban VARCHAR(50) NOT NULL,           
    pan VARCHAR(25) NOT NULL,          
    pin VARCHAR(4) NOT NULL,             
    cvv VARCHAR(4) NOT NULL,                    
    expiring_date VARCHAR(20) NOT NULL   
);

SHOW tables;    
SELECT * FROM  credit_card;  

ALTER table transaction
	ADD CONSTRAINT fk_transaction_credit_card_id
    FOREIGN KEY (credit_card_id)
    REFERENCES credit_card(id);     

ALTER TABLE user
MODIFY id INT;

ALTER table transaction
	ADD CONSTRAINT fk_transaction_user
    FOREIGN KEY (user_id)
    REFERENCES user(id);  

-- Ejercicio  2

SELECT * FROM credit_card 
WHERE id = 'CcU-2938';       

UPDATE credit_card 
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';        

SELECT * FROM credit_card 
WHERE id = 'CcU-2938';         -

-- Ejercicio 3:

INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999','ES0000000000000000000000','000000000000000','0000','000','00/00/00'); 

INSERT INTO company (id, company_name, phone, email, country, website)
VALUES ('b-9999', 'company_test', '000000000', 'test@test.com', 'country_test', 'www.test.com'); 

INSERT INTO user (id) VALUES ('9999');  

INSERT INTO transaction (Id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES  ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Ejercicio 4

ALTER TABLE credit_card
DROP COLUMN pan;

-- NIVEL 2, Ejercicio 1

DELETE FROM transaction WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Ejercicio 2:

CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country, ROUND(AVG(amount),2) AS promedio_compra
FROM company JOIN transaction
ON company.id = transaction.company_id
GROUP BY company_name, phone, country
ORDER BY promedio_compra DESC;   

SELECT * FROM VistaMarketing;   

-- Ejercicio 3

SELECT * FROM VistaMarketing
WHERE country = "Germany";       

-- NIVEL 3, Ejercicio 1

-- 3.1.1 tabla company: eliminar columna website:

ALTER TABLE company
DROP COLUMN website;
SHOW COLUMNS FROM company;     

-- 3.1.2 tabla transaction cambiar credit_card_id VARCHAR (15) a credit_card_id VARCHAR (20)

ALTER TABLE transaction
MODIFY credit_card_id VARCHAR (20);

-- 3.1.3 tabla credit_card añadir fecha_actual DATE

ALTER TABLE credit_card
ADD fecha_actual DATE DEFAULT (CURDATE());  

-- 3.1.4 tabla user cambiar nombre de la tabla por data_user

RENAME TABLE user
TO data_user;

-- 3.1.5 tabla credit_card, cambiar 'cvv VARCHAR(4)' por 'cvv INT'

ALTER TABLE credit_card
MODIFY cvv INT;

-- 3.1.6 tabla  data_user renombrar columna 'email' a 'personal_email';

ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

-- NIVEL 3: Ejercicio 2

CREATE VIEW InformeTecnico AS
SELECT t.id AS Identificador, d.name AS Nombre, d.surname AS Apellido, cc.iban, c.company_name AS Empresa, d.country AS País
FROM transaction t 
JOIN data_user d
ON t.user_id = d.id
JOIN credit_card cc
ON t.credit_card_id = cc.id
JOIN company c
ON t.company_id = c.id
ORDER BY t.id DESC;     

SELECT * 
FROM InformeTecnicoinformetecnico;   

-- Final script 3
