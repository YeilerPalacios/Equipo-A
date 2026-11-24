-- ---------------------------------------------------------------------------------------------------------------------------------
-- 9.- Enunciado para creación de Vista (VIEW) con 4 JOINs, GROUP BY y HAVING
-- Construya una vista (VIEW) con el enunciado del ítem 7. Debe crear la vista (darle un nombre) y ejecutarla.
-- ---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_reporte_ventas_productos AS
SELECT vp.id_venta_producto                      AS id_transaccion,
       p.titulo                                  AS titulo_producto,
       tp.nombre_tipo                            AS categoria_producto,
       vp.precio_unitario                        AS precio_pagado,
       u.nombre_completo                         AS comprador,
       tu.nombre_tipo                            AS tipo_usuario_comprador,
       SUM(vp.cantidad)                          AS unidades,
       SUM(vp.cantidad * vp.precio_unitario)     AS monto_total
FROM venta_producto vp
JOIN producto p       ON p.id_producto = vp.id_producto
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
JOIN venta v          ON v.id_venta = vp.id_venta
JOIN usuario u        ON u.id_usuario = v.id_usuario_comprador
JOIN tipo_usuario tu  ON tu.id_tipo_usuario = u.id_tipo_usuario
WHERE tu.nombre_tipo IN ('Egresado', 'Estudiante')
  AND vp.precio_unitario > 100000
GROUP BY vp.id_venta_producto, p.titulo, tp.nombre_tipo, vp.precio_unitario, u.nombre_completo, tu.nombre_tipo
HAVING SUM(vp.cantidad * vp.precio_unitario) > 100000;

SELECT * FROM vw_reporte_ventas_productos
ORDER BY monto_total DESC
LIMIT 20;

SELECT COUNT(*) AS total_filas_vista FROM vw_reporte_ventas_productos;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- 10.- Ejercicio del enunciado para consulta parametrizada (PREPARE / EXECUTE) con 4 JOINs (GROUP BY y HAVING)
-- ---------------------------------------------------------------------------------------------------------------------------------

PREPARE stmt_analisis_participacion_eventos (INT, DATE) AS
SELECT u.id_usuario                      AS id_organizador,
       u.nombre_completo                 AS organizador,
       tu.nombre_tipo                    AS tipo_usuario_organizador,
       te.nombre_tipo                    AS tipo_evento,
       COUNT(ue.id_usuario_evento)       AS total_participantes_confirmados
FROM usuario_evento ue
JOIN evento e        ON e.id_evento = ue.id_evento
JOIN tipo_evento te  ON te.id_tipo_evento = e.id_tipo_evento
JOIN usuario u       ON u.id_usuario = e.id_usuario_organizador
JOIN tipo_usuario tu ON tu.id_tipo_usuario = u.id_tipo_usuario
WHERE e.id_tipo_evento = $1
  AND e.fecha >= $2
  AND ue.estado_participacion = 'Confirmado'
GROUP BY u.id_usuario, u.nombre_completo, tu.nombre_tipo, te.nombre_tipo
HAVING COUNT(ue.id_usuario_evento) >= 10
ORDER BY total_participantes_confirmados DESC;

EXECUTE stmt_analisis_participacion_eventos(3, DATE '2023-01-01');
EXECUTE stmt_analisis_participacion_eventos(1, DATE '2024-01-01');

EXPLAIN (ANALYZE, BUFFERS) EXECUTE stmt_analisis_participacion_eventos(3, DATE '2023-01-01');

DEALLOCATE stmt_analisis_participacion_eventos;

-- ---------------------------------------------------------------------------------------------------------------------------------
--11.- Ejercicio del enunciado para Evaluación Experimental de Rendimiento con ANALYZE
-- ---------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS usuario_1000;
DROP TABLE IF EXISTS usuario_100000;

CREATE TABLE usuario_1000 (
    id_usuario       integer      PRIMARY KEY,
    nombre_completo  varchar(120) NOT NULL,
    id_tipo_usuario  integer      NOT NULL,
    fecha_registro   date         NOT NULL
);
CREATE TABLE usuario_100000 (LIKE usuario_1000 INCLUDING ALL);

INSERT INTO usuario_1000
SELECT g, 'Usuario de prueba ' || g, 1 + floor(random() * 9)::int, DATE '2020-01-01' + floor(random() * 2515)::int
FROM generate_series(1, 1000) g;

INSERT INTO usuario_100000
SELECT g, 'Usuario de prueba ' || g, 1 + floor(random() * 9)::int, DATE '2020-01-01' + floor(random() * 2515)::int
FROM generate_series(1, 100000) g;

ANALYZE usuario_1000;
ANALYZE usuario_100000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_registrados
FROM usuario_1000
WHERE fecha_registro BETWEEN DATE '2025-03-01' AND DATE '2025-03-15'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_registrados
FROM usuario_100000
WHERE fecha_registro BETWEEN DATE '2025-03-01' AND DATE '2025-03-15'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

CREATE INDEX idx_usuario_1000_fecha_registro   ON usuario_1000 (fecha_registro);
CREATE INDEX idx_usuario_100000_fecha_registro ON usuario_100000 (fecha_registro);
ANALYZE usuario_1000;
ANALYZE usuario_100000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_registrados
FROM usuario_1000
WHERE fecha_registro BETWEEN DATE '2025-03-01' AND DATE '2025-03-15'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_registrados
FROM usuario_100000
WHERE fecha_registro BETWEEN DATE '2025-03-01' AND DATE '2025-03-15'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

SET enable_bitmapscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_registrados
FROM usuario_100000
WHERE fecha_registro BETWEEN DATE '2025-03-01' AND DATE '2025-03-15'
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

RESET enable_bitmapscan;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.- Enunciado para Validación de Propiedades ACID en 4 Tablas del DDL
-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.1.- Atomicidad (Atomicity): Demostrar que una compra de un producto que falla en medio de la transacción por 
-- saldo  insuficiente o error de clave foránea revierte absolutamente todas las operaciones previas mediante ROLLBACK, 
-- dejando las tablas intactas.
-- ---------------------------------------------------------------------------------------------------------------------------------

UPDATE usuario SET saldo = 1000 WHERE id_usuario = 2;

SELECT (SELECT COUNT(*) FROM venta)          AS ventas_antes,
       (SELECT COUNT(*) FROM venta_producto) AS detalles_antes,
       (SELECT saldo FROM usuario WHERE id_usuario = 2) AS saldo_comprador_antes,
       (SELECT precio FROM producto WHERE id_producto = 1) AS precio_producto;

BEGIN;

    INSERT INTO venta (id_usuario_comprador, id_usuario_vendedor, total, estado)
    SELECT 2, p.id_usuario, p.precio, 'Pendiente' FROM producto p WHERE p.id_producto = 1;

    INSERT INTO venta_producto (id_venta, id_producto, cantidad, precio_unitario)
    SELECT currval(pg_get_serial_sequence('venta', 'id_venta')), p.id_producto, 1, p.precio
    FROM producto p WHERE p.id_producto = 1;

    SELECT (SELECT COUNT(*) FROM venta) AS ventas_dentro_transaccion,
           (SELECT COUNT(*) FROM venta_producto) AS detalles_dentro_transaccion;

    UPDATE usuario
    SET saldo = saldo - (SELECT precio FROM producto WHERE id_producto = 1)
    WHERE id_usuario = 2;

ROLLBACK;

SELECT (SELECT COUNT(*) FROM venta)          AS ventas_despues,
       (SELECT COUNT(*) FROM venta_producto) AS detalles_despues,
       (SELECT saldo FROM usuario WHERE id_usuario = 2) AS saldo_comprador_despues;

BEGIN;
    INSERT INTO venta (id_usuario_comprador, id_usuario_vendedor, total, estado) VALUES (3, 4, 50000, 'Pendiente');

    SAVEPOINT sp_detalle;

    INSERT INTO venta_producto (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (currval(pg_get_serial_sequence('venta', 'id_venta')), 999999, 1, 50000);

    ROLLBACK TO SAVEPOINT sp_detalle;

    SELECT COUNT(*) AS ventas_en_transaccion FROM venta WHERE total = 50000 AND id_usuario_comprador = 3;
ROLLBACK;

SELECT COUNT(*) AS ventas_tras_rollback FROM venta WHERE total = 50000 AND id_usuario_comprador = 3;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.2.- Consistencia (Consistency): Demostrar cómo las restricciones de integridad física (CHECK precio >= 0, FOREIGN KEY, NOT NULL) 
-- impiden que la base de datos ingrese a un estado de datos inconsistente o embasurado.
-- ---------------------------------------------------------------------------------------------------------------------------------

INSERT INTO producto (id_tipo_producto, id_usuario, precio, titulo, estado)
VALUES (1, 1, -5000, 'Libro con precio inválido', 'Disponible');

INSERT INTO producto (id_tipo_producto, id_usuario, precio, titulo, estado)
VALUES (1, 1, 20000, 'Libro con estado inválido', 'Regalado');

INSERT INTO producto (id_tipo_producto, id_usuario, precio, titulo, estado)
VALUES (9999, 1, 20000, 'Producto huérfano', 'Disponible');

INSERT INTO venta_producto (id_venta, id_producto, cantidad, precio_unitario)
VALUES (99999999, 1, 1, 20000);

INSERT INTO usuario (id_rol, id_tipo_usuario, nombre_usuario, correo, "contraseña")
VALUES (3, 1, 'usuario_invalido', 'invalido@pascualbravo.edu.co', 'x');

UPDATE usuario SET saldo = -100 WHERE id_usuario = 1;

INSERT INTO usuario (id_rol, id_tipo_usuario, nombre_completo, nombre_usuario, correo, "contraseña")
SELECT 3, 1, 'Usuario duplicado', 'usuario_duplicado', correo, 'x' FROM usuario WHERE id_usuario = 1;

SELECT (SELECT COUNT(*) FROM producto WHERE precio < 0 OR titulo LIKE '%inválido%' OR titulo = 'Producto huérfano') AS productos_invalidos,
       (SELECT COUNT(*) FROM usuario  WHERE nombre_usuario IN ('usuario_invalido', 'usuario_duplicado'))           AS usuarios_invalidos;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.4.- Durabilidad (Durability): Demostrar que una vez ejecutado exitosamente el comando COMMIT, los datos persisten de manera 
-- permanente en el almacenamiento físico de PostgreSQL (archivos WAL) incluso ante una simulación de desconexión imprevista del servidor.
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT pg_current_wal_lsn() AS lsn_antes, pg_walfile_name(pg_current_wal_lsn()) AS archivo_wal;
SHOW synchronous_commit;
SHOW fsync;

BEGIN;
    INSERT INTO venta (id_usuario_comprador, id_usuario_vendedor, total, estado)
    VALUES (3, 4, 777777.77, 'Completado');
    INSERT INTO venta_producto (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (currval(pg_get_serial_sequence('venta', 'id_venta')), 1, 1, 777777.77);
COMMIT;

SELECT pg_current_wal_lsn() AS lsn_despues, pg_walfile_name(pg_current_wal_lsn()) AS archivo_wal;

BEGIN;
INSERT INTO venta (id_usuario_comprador, id_usuario_vendedor, total, estado) VALUES (3, 4, 888888.88, 'Completado');
SELECT pg_terminate_backend(pg_backend_pid());

SELECT v.id_venta, v.total, v.estado, vp.id_producto
FROM venta v LEFT JOIN venta_producto vp ON vp.id_venta = v.id_venta
WHERE v.total IN (777777.77, 888888.88);