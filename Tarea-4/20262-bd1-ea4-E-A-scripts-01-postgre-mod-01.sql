--
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL
-- Todas las instrucciones se deben realizar en secuencia sin errores
-- Probar los scripts en detalle
--

--
-- Modificación de Tablas
--

--
-- Gestionar una tabla "nueva"
-- 1.- "agregar" una nueva tabla a la base de datos que tenga relación con el sistema
-- 2.- Darle un nombre "coherente"
-- 3.- Agregar campos coherentes con la tabla
-- 4.- Realizar todas las operaciones que se solicitan a continuación
--


-- 1.
-- Crear una tabla "nueva" de su iniciativa (una tabla coherente con el sistema con su nombre, no coloque "nueva" como nombre)
--
-- Se crea la tabla "logro": representa los logros/medallas que la plataforma
-- puede otorgar a un usuario (ej. "Primeros 100 seguidores", "10 publicaciones").
CREATE TABLE logro ();

-- 2
-- Agregar una clave primaria y otros 3 campos cualquiera a la tabla "nueva"
-- Mínimo un campo tipo texto y uno numérico
--
ALTER TABLE logro ADD COLUMN id_logro SERIAL PRIMARY KEY;
ALTER TABLE logro ADD COLUMN nombre_logro VARCHAR(50) NOT NULL;      -- campo tipo texto
ALTER TABLE logro ADD COLUMN puntos INTEGER NOT NULL DEFAULT 0;      -- campo tipo numérico
ALTER TABLE logro ADD COLUMN descripcion VARCHAR(255);               -- campo adicional

-- 3
-- Quitar uno de los campos de la tabla "nueva"
--
ALTER TABLE logro DROP COLUMN descripcion;

-- 4
-- Cambiar el nombre de la tabla "nueva" a otro nombre "otro_nombre"
-- Todas las operaciones siguientes se realizan sobre la tabla renombrada
--
ALTER TABLE logro RENAME TO insignia;

-- 5
-- Agregar un campo único a la tabla
--
ALTER TABLE insignia ADD COLUMN codigo_insignia VARCHAR(20);
ALTER TABLE insignia ADD CONSTRAINT uk_insignia_codigo UNIQUE (codigo_insignia);

-- 6
-- Agregar 2 fechas de inicio y fin; y colocar un control de orden de fechas
--
ALTER TABLE insignia ADD COLUMN fecha_inicio DATE;
ALTER TABLE insignia ADD COLUMN fecha_fin DATE;
ALTER TABLE insignia ADD CONSTRAINT ck_insignia_orden_fechas CHECK (fecha_fin >= fecha_inicio);


-- 7
-- Agregar 1 campo entero y colocar un control para que no sea negativo
--
ALTER TABLE insignia ADD COLUMN nivel INTEGER;
ALTER TABLE insignia ADD CONSTRAINT ck_insignia_nivel_no_negativo CHECK (nivel >= 0);


-- 8
-- Modificar el tamaño de un campo texto de la tabla renombra
--
ALTER TABLE insignia ALTER COLUMN nombre_logro TYPE VARCHAR(100);


-- 9
-- Modificar el campo numeríco y colocar un control de rango
--
ALTER TABLE insignia ALTER COLUMN puntos TYPE NUMERIC(6,0);
ALTER TABLE insignia ADD CONSTRAINT ck_insignia_puntos_rango CHECK (puntos BETWEEN 0 AND 1000);



-- 10
-- Agregar un índice a la tabla (cualquier campo)
--
CREATE INDEX idx_insignia_nombre_logro ON insignia (nombre_logro);



--
-- 11
-- Eliminar una de las fechas
--
ALTER TABLE insignia DROP COLUMN fecha_fin CASCADE;



-- 12
-- Borrar todos los datos de una tabla sin dejar traza
--
-- TRUNCATE no genera un registro fila por fila (a diferencia de DELETE) y además
-- reinicia el contador de la secuencia (identidad), por lo que no queda "traza"
-- del conteo anterior ni de las filas eliminadas.
TRUNCATE TABLE insignia RESTART IDENTITY;
