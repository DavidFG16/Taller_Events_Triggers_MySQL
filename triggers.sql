USE pizzas;

-- PUNTO 1: Validar stock antes de agregar detalle de producto (Trigger `BEFORE INSERT`).

DELIMITER //
DROP TRIGGER IF EXISTS trg_before_insert_detalle //

CREATE TRIGGER IF NOT EXISTS trg_before_insert_detalle
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '40001'
         SET MESSAGE_TEXT = 'La cantidad de ser minimo 1';

    END IF;
END //
DELIMITER ;

-- PUNTO 2: Descontar stock tras agregar ingredientes extra (Trigger `AFTER INSERT`).

DELIMITER //
DROP TRIGGER IF EXISTS trg_after_insert_ing_extra //

CREATE TRIGGER IF NOT EXISTS trg_after_insert_ing_extra
AFTER INSERT ON ingredientes_extra
FOR EACH ROW
BEGIN
    UPDATE ingrediente 
    SET stock = stock - NEW.cantidad
    WHERE NEW.ingrediente_id = ingrediente.id;
    
END //
DELIMITER ;

INSERT INTO ingredientes_extra (detalle_id, ingrediente_id, cantidad)
VALUES(5,3,2)

SELECT * FROM detalle_pedido

SELECT * FROM ingrediente

-- PUNTO 3: Registrar auditoría de cambios de precio (Trigger `AFTER UPDATE`).
DROP TABLE IF EXISTs auditoria_precio;
CREATE TABLE IF NOT EXISTS auditoria_precio (
  id                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  producto_id       INT NOT NULL,
  presentacion_id   INT NOT NULL,
  old_precio        INT NOT NULL,
  new_precio        INT NOT NULL,
  fecha_creacion    DATETIME NOT NULL DEFAULT NOW(),
  usuario_creador   VARCHAR(50) NOT NULL
);

DELIMITER //

DROP TRIGGER IF EXISTS trg_after_insert_precio_auditoria //
CREATE TRIGGER IF NOT EXISTS trg_after_insert_precio_auditoria
AFTER UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_precio(producto_id, presentacion_id, old_precio, new_precio, fecha_creacion, usuario_creador)
    VALUES (NEW.producto_id, NEW.presentacion_id, OLD.precio, NEW.precio, NOW(), USER());
END //
DELIMITER ;

UPDATE producto_presentacion SET precio = 15900 WHERE producto_id = 1 AND presentacion_id = 1;

SELECT * FROM producto_presentacion

SELECT * FROM auditoria_precio

-- PUNTO 4: Impedir precio cero o negativo (Trigger `BEFORE UPDATE`).

DELIMITER //

DROP TRIGGER IF EXISTS trg_before_update_precio //
CREATE TRIGGER IF NOT EXISTS trg_before_update_precio
BEFORE UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF NEW.precio < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nuevo precio debe ser mayor a 1';
    END IF;
END //
DELIMITER ;

UPDATE producto_presentacion SET precio = 0 WHERE producto_id = 1

-- PUNTO 5: Generar factura automática (Trigger `AFTER INSERT`).

DELIMITER //

DROP TRIGGER IF EXISTS trg_factura_automatica //
CREATE TRIGGER IF NOT EXISTS trg_factura_automatica
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    INSERT INTO factura(total, fecha, pedido_id, cliente_id)
    VALUES(NEW.total, NOW(), NEW.id, NEW.cliente_id);
    
END //
DELIMITER ;

INSERT INTO pedido(fecha_recogida, total, cliente_id, metodo_pago_id)
VALUES ('2025-06-20 12:00:00', 60000, 3, 1);

SELECT * FROM factura;
SELECT * FROM pedido;

-- PUNTO 6: Actualizar estado de pedido tras facturar (Trigger `AFTER INSERT`).
DELIMITER //
DROP TRIGGER IF EXISTS trg_actualizar_estado_pedido //

CREATE TRIGGER IF NOT EXISTS trg_actualizar_estado_pedido
AFTER INSERT ON factura
FOR EACH ROW
BEGIN
    UPDATE pedido 
    SET estado = 'En preparación', 
    facturacion = 'Facturado'
    WHERE NEW.pedido_id = pedido.id;
    
END //
DELIMITER ;

DESCRIBE factura