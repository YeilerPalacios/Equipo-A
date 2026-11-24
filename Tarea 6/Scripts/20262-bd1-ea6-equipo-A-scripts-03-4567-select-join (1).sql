-- ---------------------------------------------------------------------------------
-- Scripts - Enunciados 3, 4, 5, 6 y 7 DML para consultas Sin Join, 1 Join, 2 Join, 3 Join y 4 Join
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- 3.- Enunciado para Consulta sin JOIN
-- Análisis de Precios y Disponibilidad en Oferta de Productos
-- ---------------------------------------------------------------------------------

SELECT p.id_producto                AS codigo_producto,
       p.titulo                     AS titulo_descriptivo,
       p.precio                     AS precio_base,
       ROUND(p.precio * 1.05, 2)    AS precio_venta_con_recargo_5_pct,
       p.estado                     AS estado_disponibilidad
FROM producto p
WHERE p.precio BETWEEN 50000 AND 500000
  AND p.estado = 'Disponible'
ORDER BY p.precio DESC
LIMIT 20;

-- ---------------------------------------------------------------------------------
-- 4.- Enunciado para consulta con 1 JOIN. 
-- Censo Institucional de Usuarios por Categoría
-- -----------------------------------------------------------------------------------

SELECT tu.nombre_tipo        AS categoria_institucional,
       COUNT(u.id_usuario)   AS total_usuarios
FROM usuario u
JOIN tipo_usuario tu ON tu.id_tipo_usuario = u.id_tipo_usuario
GROUP BY tu.nombre_tipo
ORDER BY total_usuarios DESC;

-- ---------------------------------------------------------------------------------
-- 5.- Enunciado para consulta con 2 JOINs
-- Trazabilidad de Eventos Académicos y sus Organizadores
-- ---------------------------------------------------------------------------------

SELECT e.titulo                AS titulo_evento,
       te.nombre_tipo          AS tipo_evento,
       e.fecha                 AS fecha_realizacion,
       u.nombre_completo       AS organizador,
       u.correo                AS correo_institucional
FROM evento e
JOIN tipo_evento te ON te.id_tipo_evento = e.id_tipo_evento
JOIN usuario u      ON u.id_usuario = e.id_usuario_organizador
WHERE e.fecha >= DATE '2024-01-01'
  AND e.fecha <  DATE '2026-01-01'
ORDER BY e.fecha, e.titulo;

-- ---------------------------------------------------------------------------------
-- 6.- Enunciado para consulta SELECT con 3 JOINs
-- Consumo de Servicios Académicos por Estudiantes Activos
-- ---------------------------------------------------------------------------------

SELECT u.nombre_completo     AS estudiante_solicitante,
       s.nombre_servicio     AS servicio_solicitado,
       ts.nombre_tipo        AS categoria_servicio,
       v.fecha_hora_venta    AS fecha_solicitud
FROM venta_servicio vs
JOIN servicio s       ON s.id_servicio = vs.id_servicio
JOIN tipo_servicio ts ON ts.id_tipo_servicio = s.id_tipo_servicio
JOIN venta v          ON v.id_venta = vs.id_venta
JOIN usuario u        ON u.id_usuario = v.id_usuario_comprador
WHERE u.id_tipo_usuario = 1
  AND v.estado = 'Completado'
ORDER BY v.fecha_hora_venta DESC;

-- ---------------------------------------------------------------------------------
-- 7.- Enunciado para consulta con 4 JOINs
-- Reporte Transaccional Consolidado de Venta de Productos
-- ---------------------------------------------------------------------------------

SELECT p.titulo              AS titulo_producto,
       tp.nombre_tipo        AS categoria_producto,
       vp.precio_unitario    AS precio_pagado,
       vp.cantidad           AS cantidad,
       u.nombre_completo     AS comprador,
       tu.nombre_tipo        AS tipo_usuario_comprador
FROM venta_producto vp
JOIN producto p       ON p.id_producto = vp.id_producto
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
JOIN venta v          ON v.id_venta = vp.id_venta
JOIN usuario u        ON u.id_usuario = v.id_usuario_comprador
JOIN tipo_usuario tu  ON tu.id_tipo_usuario = u.id_tipo_usuario
WHERE tu.nombre_tipo IN ('Egresado', 'Estudiante')
  AND vp.precio_unitario > 100000
ORDER BY vp.precio_unitario DESC;