CREATE DATABASE modelado_sql;
USE modelado_sql;

CREATE TABLE IF NOT EXISTS european_users (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
    );

    CREATE TABLE IF NOT EXISTS american_users (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
    );
 
LOAD DATA LOCAL INFILE "C:/ARCHIVOS/european_users.csv"
INTO TABLE european_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);
 
LOAD DATA LOCAL INFILE "C:/ARCHIVOS/american_users.csv"
INTO TABLE american_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

CREATE TABLE IF NOT EXISTS total_users (
    id INT,    -- se le añadirá PK posteriormente
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255),
    tabla_de_origen VARCHAR(10)
);
   
INSERT INTO total_users
(id, name, surname, phone, email, birth_date, country, city, postal_code, address, tabla_de_origen)
SELECT
	id, name, surname, phone, email, birth_date, country, city, postal_code, address,'European' AS tabla_de_origen
FROM european_users;
    
 INSERT INTO total_users
(id, name, surname, phone, email, birth_date, country, city, postal_code, address, tabla_de_origen)
SELECT
	id, name, surname, phone, email, birth_date, country, city, postal_code, address,'American' AS tabla_de_origen
FROM american_users;  

SELECT * FROM total_users;

CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(15) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(25),
    pin VARCHAR(4),
    cvv VARCHAR(4),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(20)
);

LOAD DATA LOCAL INFILE "C:/ARCHIVOS/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date);

SELECT * FROM credit_cards;

CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
    );

LOAD DATA LOCAL INFILE "C:/ARCHIVOS/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company_id, company_name, phone, email, country ,website);

SELECT * FROM companies;

CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(15),
    business_id VARCHAR(15),
    timestamp TIMESTAMP,
    amount DECIMAL(10,2),
    declined TINYINT,
    product_ids VARCHAR(255),
    user_id INT,
    lat FLOAT,
    longitude FLOAT
);

LOAD DATA LOCAL INFILE "C:/ARCHIVOS/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);

SELECT * FROM transactions;

-- al recargar total_users no se le asigno PK, (en el PDF está correcto)
ALTER TABLE total_users
ADD PRIMARY KEY (id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_total_users
FOREIGN KEY (user_id) REFERENCES total_users(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_cards
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_companies
FOREIGN KEY (business_id) REFERENCES companies(company_id);

DROP TABLE european_users;
DROP TABLE american_users;

-- Ejercicio 1
-- Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones 
-- utilizando al menos 2 mesas.

SELECT id, name
FROM total_users
WHERE id IN (
	SELECT transactions.user_id 
    FROM transactions
    GROUP BY transactions.user_id
    HAVING COUNT(transactions.id)  > 80
    );

-- Ejercicio 2
-- Muestra la media de amount por IBAN de las tarjetas de crédito 
-- a la compañía Donec Ltd, utiliza al menos 2 mesas.

SELECT ROUND(AVG(transactions.amount), 2) AS media_amount, credit_cards.iban
FROM transactions
JOIN credit_cards 
ON transactions.card_id = credit_cards.id 
JOIN companies 
ON  transactions.business_id = companies.company_id
WHERE companies.company_name = 'Donec Ltd'
GROUP BY credit_cards.iban, companies.company_name;

-- NIVEL 2:
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito 
-- basado en si las tres últimas transacciones han sido declinadas entonces es inactivo, 
-- si al menos una no es rechazada entonces es activo. Partiendo de esta tabla responde:
-- Ejercicio 1
-- ¿Cuántas tarjetas están activas?

CREATE TABLE card_status (
    card_id VARCHAR(100) PRIMARY KEY,   
    estado VARCHAR(10)                  
);

INSERT INTO card_status (card_id, estado)
SELECT subconsulta.card_id,
    CASE
        WHEN SUM(CASE WHEN subconsulta.declined = 0 THEN 1 ELSE 0 END) >= 1
            THEN 'activo'
            ELSE 'inactivo'
       END AS estado
FROM (
    SELECT transactions.card_id, transactions.declined,
        ROW_NUMBER() OVER (
            PARTITION BY transactions.card_id
            ORDER BY transactions.timestamp DESC
        ) AS posicion
    FROM transactions
) AS subconsulta
WHERE subconsulta.posicion <= 3
GROUP BY subconsulta.card_id;


SELECT COUNT(*) AS tarjetas_activas          
FROM card_status
WHERE estado = 'activo';

-- NIVEL 3
-- Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
-- teniendo en cuenta que desde transaction tienes product_ids.

CREATE TABLE products(
	id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price VARCHAR(50),
    colour VARCHAR(50),
    weight INT,
    warehouse_id VARCHAR(50)
    );

LOAD DATA LOCAL INFILE "C:/ARCHIVOS/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, price, colour, weight, warehouse_id);

SELECT * FROM modelado_sql.products;

CREATE TABLE IF NOT EXISTS transaction_products (
    transaction_id VARCHAR(100),
    product_id INT,
    PRIMARY KEY  (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO transaction_products (transaction_id, product_id)
SELECT      transactions.id,  jt.product_id       
FROM transactions      
JOIN JSON_TABLE(         
        CONCAT('["', REPLACE(transactions.product_ids, ',', '","'), '"]'),  
        '$[*]' COLUMNS (
        product_id INT PATH '$'
        )               
    ) AS jt;              

SELECT *
FROM transaction_products  
ORDER BY product_id;

SELECT product_id, COUNT(product_id) AS veces_vendido
FROM transaction_products
GROUP BY product_id;

-- fin sprint 4







    