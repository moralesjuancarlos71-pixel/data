USE Transactions;
SELECT * FROM company;
SELECT * FROM transaction;

-- Nivel 1: Ejercicio 2.1 (Utilizando JOIN realizarás las siguientes consultas):
-- Listado de los países que están generando ventas.
SELECT DISTINCT c.country
FROM company c
INNER JOIN  transaction t
ON c.id = t.company_id           -- ON c.id = t.company_id
WHERE t.amount > 0;              -- (WHERE t.amount IS NOT NULL);
 

-- Nivel 1: Ejercicio 2.2 Desde cuántos países se generan las ventas.
SELECT COUNT(DISTINCT country) AS num_paises_ventas
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
WHERE t.amount > 0;

-- Nivel 1: Ejercicio 2.3 Identifica la compañía con la mayor media de ventas.

SELECT c.company_name, t.company_id,  ROUND(AVG(t.amount),2) AS media_ventas
FROM company c
JOIN transaction t 
ON c.id = t.company_id
GROUP BY c.company_name, t.company_id
ORDER BY media_ventas DESC LIMIT 1;

-- Nivel 1, Ejercicio 3.1
-- Utilizando sólo subconsultas (sin utilizar JOIN):
-- 3.1 Muestra todas las transacciones realizadas por empresas de Alemania.

    
SELECT t.id
FROM transaction t
WHERE t.company_id IN (
    SELECT c.id
    FROM company c
    WHERE c.country = 'Germany'
);                                         -- 13291 rows

-- Nivel 1, Ejercicio 3..2 
-- Lista las empresas que han realizado transacciones por un amount superior a 
-- la media de todas las transacciones


SELECT company_name, id             -- nombre de las compañías con su identificador un ..
FROM company
WHERE id IN (                       -- WHERE EXISTS
	SELECT company_id               -- id de las compañías con amount superior a :
    FROM transaction 
    WHERE amount >(
		SELECT AVG(amount)          -- la  media de las transacciones 
        FROM transaction)  
);                                  -- 100 rows 

-- Nivel 1, Ejercicio 3..3 Eliminarán del sistema las empresas que no tienen transacciones registradas, 
-- entrega el listado de estas empresas.

SELECT id, company_name
FROM company 
WHERE id  NOT IN
     (SELECT company_id 
      FROM transaction
);
-- 0 rows


-- Nivel 2, ejercicio 1:
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
-- Muestra la fecha de cada transacción junto con el total de las ventas.

-- agrupa por fecha
SELECT DATE(t.timestamp) AS fecha, SUM(t.amount) AS suma_cantidad
FROM transaction t
GROUP BY fecha
ORDER BY suma_cantidad DESC
LIMIT 5;

-- Nivel 2, ejercicio 2:
-- ¿Cuál es el promedio de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT c.country, AVG(t.amount) AS promedio_ventas 
FROM transaction t
JOIN company c 
ON t.company_id = c.id
GROUP BY  c.country
ORDER BY promedio_ventas DESC;  -- 15 rows

-- Nivel 2, ejercicio 3:
-- En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía "Non Institute". 
-- Para ello, te piden la lista de todas las transacciones realizadas por empresas 
-- que están situadas en el mismo país que esta compañía. 

-- Muestra el listado aplicando JOIN y subconsultas.

SELECT t.id, c.company_name, c.country
FROM transaction t
JOIN company c 
ON t.company_id = c.id
WHERE c.company_name != "Non Institute"     -- entiendo el enunciado sin "Non Institute" 
AND c.country = ( 
	SELECT c.country 
	FROM company c
	WHERE c.company_name = "Non Institute"
);  
-- sin "Non Institute"  12233 rows
-- con "Non Institute"  13776 rows

-- Muestra el listado aplicando solamente subconsultas.
SELECT id
FROM transaction
WHERE company_id IN (                                  -- Query final : 12233 rows
    SELECT id
    FROM company
    WHERE company_name != 'Non Institute'              -- Subquery 1: 8 rows
      AND country = (
            SELECT country
            FROM company
            WHERE company_name = 'Non Institute'       -- Subquery 2: United Kingdom
      )
);

-- Nivel 3, Ejercicio 1: 
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones 
-- con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas: 
-- 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
-- Ordena los resultados de mayor a menor cantidad.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id 
WHERE t.amount BETWEEN 350 AND 400
AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20 ', '2024-03-13' )
ORDER BY t.amount DESC;
-- 8 rows 

-- Nivel 3, Ejercicio 2:
-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
-- por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
-- pero el departamento de recursos humanos es exigente y quiere un listado de las empresas 
-- donde especifiques si tienen más de 400 transacciones o menos.

SELECT c.company_name, COUNT(t.id) AS total_transacciones,
CASE
	WHEN COUNT(t.id) < 400 THEN 'Menor de 400'
    WHEN COUNT(t.id) = 400 THEN '400'
    ELSE 'Mayor de 400'
END AS 'Número de transacciones'
FROM transaction t
JOIN company c 
ON t.company_id = c.id
GROUP BY c.company_name
ORDER BY total_transacciones;












