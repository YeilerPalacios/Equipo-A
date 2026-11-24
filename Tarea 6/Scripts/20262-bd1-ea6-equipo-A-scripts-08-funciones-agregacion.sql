--
-- Scripts - 8.- Enunciados para Consultas con Funciones de Agregación

-- ---------------------------------------------------------------------------------------------------------------------------------
-- Script del Enunciado 8.1 — Función COUNT: Volumen Global de Solicitudes de Servicio
-- Calcular la cantidad total de solicitudes de servicios registradas en la plataforma agrupadas por el estado de la transacción (Completado, Pendiente, Cancelado). 
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT v.estado                 AS estado_transaccion,
       COUNT(vs.id_venta_servicio) AS total_solicitudes
FROM venta_servicio vs
JOIN venta v ON v.id_venta = vs.id_venta
GROUP BY v.estado
ORDER BY total_solicitudes DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- Script del Enunciado 8.2 — Función SUM: Recaudo Comercial Total por Categoría de Producto
-- Calcular el monto total acumulado ($) en ventas de productos pertenecientes a la categoría 'Libros' y 'Tecnología/Computadores'.
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT tp.nombre_tipo                          AS categoria_producto,
       SUM(vp.cantidad * vp.precio_unitario)   AS recaudo_total
FROM venta_producto vp
JOIN venta v          ON v.id_venta = vp.id_venta
JOIN producto p       ON p.id_producto = vp.id_producto
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
WHERE tp.nombre_tipo IN ('Libros', 'Tecnología/Computadores')
  AND v.estado = 'Completado'
GROUP BY tp.nombre_tipo
ORDER BY recaudo_total DESC;