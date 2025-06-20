# Taller

## Events

Haciendo uso de las siguientes tablas para la base de datos de `pizza` realice los siguientes ejercicios de `Events`  centrados en el uso de **ON COMPLETION PRESERVE** y **ON COMPLETION NOT PRESERVE** :

```sql
CREATE TABLE IF NOT EXISTS resumen_ventas (
fecha       DATE      PRIMARY KEY,
total_pedidos INT,
total_ingresos DECIMAL(12,2),
creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alerta_stock (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  ingrediente_id  INT UNSIGNED NOT NULL,
  stock_actual    INT NOT NULL,
  fecha_alerta    DATETIME NOT NULL,
  creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id)
);
```

1. Resumen Diario Único : crear un evento que genere un resumen de ventas **una sola vez** al finalizar el día de ayer y luego se elimine automáticamente llamado `ev_resumen_diario_unico`.
2. Resumen Semanal Recurrente: cada lunes a las 01:00 AM, generar el total de pedidos e ingresos de la semana pasada, **manteniendo** el evento para que siga ejecutándose cada semana llamado `ev_resumen_semanal`.
3. Alerta de Stock Bajo Única: en un futuro arranque del sistema (requerimiento del sistema), generar una única pasada de alertas (`alerta_stock`) de ingredientes con stock < 5, y luego autodestruir el evento.
4. Monitoreo Continuo de Stock: cada 30 minutos, revisar ingredientes con stock < 10 e insertar alertas en `alerta_stock`, **dejando** el evento activo para siempre llamado `ev_monitor_stock_bajo`.
5. Limpieza de Resúmenes Antiguos: una sola vez, eliminar de `resumen_ventas` los registros con fecha anterior a hace 365 días y luego borrar el evento llamado `ev_purgar_resumen_antiguo`.

## Triggers

> Si el ER cambia con respecto al manejado en Clase con el Trainer, se deben realizar los ajustes para el cumplimiento con lo solicitado en los Ejercicios.

1. Validar stock antes de agregar detalle de producto (Trigger `BEFORE INSERT`).
2. Descontar stock tras agregar ingredientes extra (Trigger `AFTER INSERT`).
3. Registrar auditoría de cambios de precio (Trigger `AFTER UPDATE`).
4. Impedir precio cero o negativo (Trigger `BEFORE UPDATE`).
5. Generar factura automática (Trigger `AFTER INSERT`).
6. Actualizar estado de pedido tras facturar (Trigger `AFTER INSERT`).
7. Evitar eliminación de combos en uso (Trigger `BEFORE DELETE`).
8. Limpiar relaciones tras borrar un detalle (Trigger `BEFORE DELETE`).
9. Control de stock mínimo tras actualización (Trigger `AFTER UPDATE`).
10. Registrar creación de nuevos clientes (Trigger `AFTER INSERT`).