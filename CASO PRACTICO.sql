/*Pasos a seguir
a) Crear la base de datos con el archivo create_restaurant_db.sql*/

--b) Explorar la tabla “menu_items” para conocer los productos del menú.
SELECT * FROM menu_items;

/*1.- Realizar consultas para contestar las siguientes preguntas:
● Encontrar el número de artículos en el menú.*/
SELECT COUNT (menu_item_id) AS "Artículos"
FROM menu_items;

--● ¿Cuál es el artículo menos caro y el más caro en el menú?
SELECT MIN (price) AS "Menos caro",
MAX (price) AS "Más caro"
FROM menu_items;

--● ¿Cuántos platos americanos hay en el menú?
SELECT COUNT (category) AS "Platos Americanos"
FROM menu_items
WHERE category='American';

--● ¿Cuál es el precio promedio de los platos?
SELECT AVG (price) AS "Precio promedio"
FROM menu_items;

--c) Explorar la tabla “order_details” para conocer los datos que han sido recolectados.

--1.- Realizar consultas para contestar las siguientes preguntas:
SELECT * FROM order_details;

--● ¿Cuántos pedidos únicos se realizaron en total?
SELECT COUNT (DISTINCT order_id) AS "Pedidos únicos"
FROM order_details
	WHERE item_id IS NOT NULL;

--● ¿Cuáles son los 5 pedidos que tuvieron el mayor número de artículos?
SELECT order_id AS "# de pedido", COUNT(item_id) AS "# de platillos"
FROM order_details
	WHERE item_id IS NOT NULL
GROUP BY order_id
ORDER BY COUNT (item_id) DESC
LIMIT 5;

--● ¿Cuándo se realizó el primer pedido y el último pedido?
SELECT MIN (order_date) AS "Primer pedido",
MAX (order_date) AS "Último pedido"
FROM order_details;


--● ¿Cuántos pedidos se hicieron entre el '2023-01-01' y el '2023-01-05'?
SELECT COUNT (order_details_id) AS "Pedidos del periodo 2023/01/01-2023/01/05"
FROM order_details
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-05';

/*d) Usar ambas tablas para conocer la reacción de los clientes respecto al menú.
1.- Realizar un left join entre entre order_details y menu_items con el identificador
item_id(tabla order_details) y menu_item_id(tabla menu_items).*/
SELECT * FROM order_details AS o
LEFT JOIN menu_items AS m
ON o.item_id=m.menu_item_id

/*e) Una vez que hayas explorado los datos en las tablas correspondientes y respondido las
preguntas planteadas, realiza un análisis adicional utilizando este join entre las tablas. El
objetivo es identificar 5 puntos clave que puedan ser de utilidad para los dueños del
restaurante en el lanzamiento de su nuevo menú. Para ello, crea tus propias consultas y
utiliza los resultados obtenidos para llegar a estas conclusiones.*/

-- Análisis de Ventas por Categoría

SELECT m.category "Origen", SUM(m.price) AS "total de ingresos", COUNT(*) AS "total de ordenes"
FROM order_details AS o
LEFT JOIN menu_items AS m
ON o.item_id = m.menu_item_id
	WHERE m.category IS NOT NULL AND m.price IS NOT NULL
GROUP BY m.category
ORDER BY "total de ingresos" DESC;

-- Identificación de los diez platillos más vendidos

SELECT m.item_name AS "Platillo", m.category AS "Origen", COUNT(*) AS "Total de ordenes", SUM(m.price) AS "Total de ingresos"
FROM order_details AS o
LEFT JOIN menu_items AS m
ON o.item_id = m.menu_item_id
	WHERE m.price IS NOT NULL
GROUP BY "Platillo", "Origen"
ORDER BY "Total de ordenes" DESC
LIMIT 10;

-- Análisis de ventas por hora

WITH ordenes AS (
    SELECT 
        o.order_date,
        EXTRACT(HOUR FROM o.order_time) AS hora,
        m.price
    FROM order_details AS o
    LEFT JOIN menu_items AS m
    ON o.item_id = m.menu_item_id
    WHERE m.price IS NOT NULL
)

SELECT 
    hora AS "hora del día",
    SUM(price) AS "total de ingresos", 
    COUNT(*) AS "total de ordenes"
FROM ordenes
GROUP BY hora
ORDER BY hora;


-- Análisis de ventas por día de la semana

WITH ordenes AS (
    SELECT 
        o.order_date,
        CASE 
            WHEN EXTRACT(DOW FROM o.order_date) = 0 THEN 'Domingo'
            WHEN EXTRACT(DOW FROM o.order_date) = 1 THEN 'Lunes'
            WHEN EXTRACT(DOW FROM o.order_date) = 2 THEN 'Martes'
            WHEN EXTRACT(DOW FROM o.order_date) = 3 THEN 'Miércoles'
            WHEN EXTRACT(DOW FROM o.order_date) = 4 THEN 'Jueves'
            WHEN EXTRACT(DOW FROM o.order_date) = 5 THEN 'Viernes'
            WHEN EXTRACT(DOW FROM o.order_date) = 6 THEN 'Sábado'
        END AS dia_semana,
        m.price
    FROM order_details AS o
    LEFT JOIN menu_items AS m
    ON o.item_id = m.menu_item_id
    WHERE m.price IS NOT NULL
)

SELECT 
    dia_semana AS "Día de la semana",
    SUM(price) AS "Total de ingresos", 
    COUNT(*) AS "Total de ordenes"
FROM ordenes
GROUP BY dia_semana
ORDER BY 
    CASE 
        WHEN dia_semana = 'Domingo' THEN 7
        WHEN dia_semana = 'Lunes' THEN 1
        WHEN dia_semana = 'Martes' THEN 2
        WHEN dia_semana = 'Miércoles' THEN 3
        WHEN dia_semana = 'Jueves' THEN 4
        WHEN dia_semana = 'Viernes' THEN 5
        WHEN dia_semana = 'Sábado' THEN 6
    END;


-- Ingresos por cliente

SELECT o.order_details_id AS "cliente", SUM(m.price) AS "total de ingresos", COUNT(*) AS "total de ordenes"
FROM order_details AS o
LEFT JOIN menu_items AS m
ON o.item_id = m.menu_item_id
	WHERE m.price IS NOT NULL AND o.order_details_id IS NOT NULL
GROUP BY o.order_details_id
ORDER BY "total de ingresos" DESC;

-- Análisis por Mes

WITH ordenes AS (
    SELECT 
        o.order_date,
        TO_CHAR(o.order_date, 'Month') AS mes,
        m.price
    FROM order_details AS o
    LEFT JOIN menu_items AS m
    ON o.item_id = m.menu_item_id
    WHERE m.price IS NOT NULL
)

SELECT 
    mes AS "mes",
    SUM(price) AS "total de ingresos", 
    COUNT(*) AS "total de ordenes"
FROM ordenes
GROUP BY mes
ORDER BY 
    TO_DATE(mes, 'Month');
