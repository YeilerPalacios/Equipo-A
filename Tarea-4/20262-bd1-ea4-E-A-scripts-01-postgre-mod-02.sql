--
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL
-- Todas las instrucciones se deben realizar en secuencia sin errores
-- Probar los scripts en detalle
--

--
-- Modificación de la Base de Datos
--


--
-- 1.- DATOS SEMI-ESTRUCTURADOS PARA DATOS PARA BIG DATA
-- Gestionar el campo "perfil_usuario" en tabla "usuarios"
-- Debe incluir otros datos diferentes al ejemplo del Anexo B
-- 1.- "agregar" un campo tipo JSON o JSNOB
-- 2.- Agregar un par de registros
-- 3.- Consultar la información agregada
-- 4.- Describir el campo y explicar su propósito
--

-- 1. Agregar el campo
ALTER TABLE usuario ADD COLUMN perfil_usuario JSONB;

-- 2. Agregar un par de registros con información semi-estructurada
--    (datos distintos a los del ejemplo del Anexo B: aquí se guardan redes
--     sociales externas, idiomas hablados y preferencias de notificación,
--     que varían de un usuario a otro y no todos los usuarios diligencian).
UPDATE usuario
SET perfil_usuario = '{
  "redes_sociales": {"instagram": "@laura.jimenez", "linkedin": "laura-jimenez-dev"},
  "idiomas": ["español", "inglés"],
  "preferencias_notificacion": {"email": true, "push": false, "sms": false},
  "tema_interfaz": "oscuro"
}'::jsonb
WHERE id_usuario = 1;

UPDATE usuario
SET perfil_usuario = '{
  "redes_sociales": {"twitter": "@david_rojas99"},
  "idiomas": ["español", "portugués", "inglés"],
  "preferencias_notificacion": {"email": true, "push": true, "sms": true},
  "tema_interfaz": "claro",
  "dispositivos_conectados": ["android", "web"]
}'::jsonb
WHERE id_usuario = 2;

-- 3. Consultar la información agregada
-- 3.1 Ver el documento JSON completo de cada usuario
SELECT id_usuario, nombre_usuario, perfil_usuario
FROM usuario
WHERE perfil_usuario IS NOT NULL;

-- 3.2 Extraer un atributo puntual del documento (operador ->>)
SELECT id_usuario,
       nombre_usuario,
       perfil_usuario ->> 'tema_interfaz' AS tema_interfaz
FROM usuario
WHERE perfil_usuario IS NOT NULL;

-- 3.3 Filtrar usuarios según un valor anidado dentro del JSON
SELECT id_usuario, nombre_usuario
FROM usuario
WHERE (perfil_usuario -> 'preferencias_notificacion' ->> 'push')::boolean = true;

-- 4. Descripción del campo y su propósito
-- El campo "perfil_usuario" (JSONB) almacena información complementaria y
-- opcional del usuario que es heterogénea y cambia con frecuencia: redes
-- sociales externas, idiomas, preferencias de notificación, tema de la
-- interfaz, dispositivos conectados, etc. No todos los usuarios tienen los
-- mismos atributos ni la misma cantidad de ellos, por lo que modelarlo como
-- columnas fijas obligaría a crear muchas columnas casi siempre vacías o a
-- alterar la tabla cada vez que surge un nuevo atributo. JSONB permite
-- guardar esta información variable en un solo campo, indexarla (índices GIN)
-- y consultarla con los operadores nativos de PostgreSQL (->, ->>, @>, ?)
-- sin sacrificar la estructura relacional del resto del modelo.


--
-- 2.- DATOS SEMI-ESTRUCTURADOS (PARA BIG DATA o IOT)
-- Gestionar un nuevo campo "nombre_campo" (de su propia creación) en cualquier tabla (de las existentes) que considere adecuada
-- 1.- "agregar" un campo tipo JSON o JSONB
-- 2.- Agregar un par de registros de información
-- 3.- Consultar la información agregada
-- 4.- Describir el campo y explicar su propósito
--

-- Campo elegido: "especificaciones" en la tabla "producto".
-- Cada categoría de producto tiene atributos distintos (un libro tiene autor
-- e ISBN, una camiseta tiene talla y color, un accesorio electrónico tiene
-- voltaje y garantía), por lo que es un caso típico de dato semi-estructurado.

-- 1. Agregar el campo
ALTER TABLE producto ADD COLUMN especificaciones JSONB;

-- 2. Agregar un par de registros de información
UPDATE producto
SET especificaciones = '{
  "categoria": "ropa",
  "talla": "M",
  "color": "azul",
  "material": "algodón"
}'::jsonb
WHERE id_producto = 1;

UPDATE producto
SET especificaciones = '{
  "categoria": "electronica",
  "voltaje": "110V-220V",
  "garantia_meses": 12,
  "accesorios_incluidos": ["cable USB-C", "manual"]
}'::jsonb
WHERE id_producto = 2;

-- 3. Consultar la información agregada
-- 3.1 Ver las especificaciones completas de cada producto
-- (se hace JOIN con tipo_producto porque "producto" no guarda un nombre
--  propio: su categoría/nombre comercial vive en la tabla tipo_producto)
SELECT p.id_producto, tp.nombre_tipo AS tipo_producto, p.precio, p.especificaciones
FROM producto p
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
WHERE p.especificaciones IS NOT NULL;

-- 3.2 Consultar un atributo específico dentro del JSON
SELECT p.id_producto, tp.nombre_tipo AS tipo_producto,
       p.especificaciones ->> 'categoria' AS categoria
FROM producto p
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
WHERE p.especificaciones IS NOT NULL;

-- 3.3 Filtrar productos cuya categoría sea "electronica"
SELECT p.id_producto, tp.nombre_tipo AS tipo_producto
FROM producto p
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
WHERE p.especificaciones @> '{"categoria": "electronica"}'::jsonb;

-- 4. Descripción del campo y su propósito
-- El campo "especificaciones" (JSONB) guarda los atributos técnicos propios
-- de cada categoría de producto (ropa, tecnología, hogar, etc.), que varían
-- en cantidad y nombre según el tipo de producto. En lugar de crear una
-- columna distinta por cada posible atributo de cada categoría (lo que
-- generaría una tabla con decenas de columnas casi siempre vacías), se usa
-- un documento JSONB que solo contiene los atributos relevantes para ese
-- producto en particular. Esto facilita agregar nuevas categorías o nuevos
-- atributos a futuro sin modificar la estructura de la tabla (ALTER TABLE),
-- lo cual es típico en escenarios de catálogos de producto tipo Big Data/IoT
-- donde el esquema de los metadatos cambia constantemente.
