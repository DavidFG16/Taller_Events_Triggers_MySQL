USE pizzas;
CREATE TABLE IF NOT EXISTS resumen_ventas (
fecha       DATE      PRIMARY KEY,
total_pedidos INT,
total_ingresos DECIMAL(12,2),
creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notificacion_stock_bajo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ingrediente_id INT NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    fecha_notificacion DATETIME NOT NULL,
    stock_actual INT NOT NULL,
    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id)
);

-- PUNTO 1 : Resumen Diario Único
DELIMITER //

DROP EVENT IF EXISTS ev_resumen_diario_unico;

CREATE EVENT ev_resumen_diario_unico
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION NOT PRESERVE
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos)
    SELECT
        DATE(NOW() - INTERVAL 1 DAY),
        COUNT(id),
        SUM(total)
    FROM pedido
    WHERE fecha_recogida >= DATE(NOW() - INTERVAL 1 DAY)
    AND fecha_recogida < DATE(NOW());
END //

DELIMITER ;

SELECT * FROM resumen_ventas;
SELECT * FROM pedido;


--PUNTO 2: Resumen Semanal Recurrente
DELIMITER //
DROP EVENT IF EXISTS ev_resumen_semanal;
CREATE EVENT ev_resumen_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-06-23 01:00:00'
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos)
    SELECT
        DATE(NOW() - INTERVAL 1 WEEK),
        COUNT(id),
        SUM(total)
    FROM pedido
    WHERE fecha_recogida >= DATE(NOW() - INTERVAL 1 WEEK)
    AND fecha_recogida < DATE(NOW());
END //

DELIMITER ;

SELECT * FROM resumen_ventas;
SELECT * FROM pedido;

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES 
('2025-06-18 18:00:00', 60000, 1, 1),
('2025-06-18 19:00:00', 25000, 2, 2),
('2025-06-18 18:00:00', 100000, 3, 1),
('2025-06-18 19:00:00', 15900, 2, 2);

DESCRIBE pedido

-- PUNTO 3: Alerta de Stock Bajo Única:
DELIMITER //
DROP EVENT IF EXISTS evento_alerta_stock_unica

CREATE EVENT IF NOT EXISTS evento_alerta_stock_unica
ON SCHEDULE AT '2025-06-19 23:50:00'
ON COMPLETION NOT PRESERVE
DO
BEGIN
    INSERT INTO notificacion_stock_bajo (ingrediente_id, mensaje, fecha_notificacion, stock_actual)
    SELECT 
        id,
        CONCAT('Stock bajo para ', nombre, ': solo ', stock, ' unidades disponibles.'),
        NOW(),
        stock
    FROM ingrediente
    WHERE stock < 5;
END//
DELIMITER ;

UPDATE ingrediente SET stock = 3 WHERE stock < 100;
SELECT * FROM notificacion_stock_bajo;
SELECT * FROM ingrediente;

-- PUNTO 4: Monitoreo Continuo de Stock

DELIMITER //
DROP EVENT IF EXISTS ev_monitor_stock_bajo

CREATE EVENT IF NOT EXISTS ev_monitor_stock_bajo
ON SCHEDULE EVERY 30 MINUTE
DO
BEGIN
    INSERT INTO notificacion_stock_bajo (ingrediente_id, mensaje, fecha_notificacion, stock_actual)
    SELECT 
        id,
        CONCAT('Stock bajo para ', nombre, ': solo ', stock, ' unidades disponibles.'),
        NOW(),
        stock
    FROM ingrediente
    WHERE stock < 10;
END//
DELIMITER ;

UPDATE ingrediente SET stock = 5 WHERE stock < 100;
SELECT * FROM notificacion_stock_bajo;
SELECT * FROM ingrediente;

-- PUNTO 5: Limpieza de Resúmenes Antiguos

DELIMITER //
DROP EVENT IF EXISTS ev_purgar_resumen_antiguo

CREATE EVENT IF NOT EXISTS ev_purgar_resumen_antiguo
ON SCHEDULE AT CURRENT_TIME + INTERVAL 1 SECOND
ON COMPLETION NOT PRESERVE
DO
BEGIN
    DELETE FROM resumen_ventas WHERE creado_en < NOW() - INTERVAL 1 YEAR;
    
END//
DELIMITER ;

SELECT * FROM resumen_ventas
