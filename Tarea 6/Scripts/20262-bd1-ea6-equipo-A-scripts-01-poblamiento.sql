--
-- Script Poblamiento
--
-- 


ALTER TABLE usuario
    ADD COLUMN fecha_registro date          NOT NULL DEFAULT CURRENT_DATE,
    ADD COLUMN saldo          numeric(12,2) NOT NULL DEFAULT 0,
    ADD CONSTRAINT ck_usuario_saldo_no_negativo CHECK (saldo >= 0);

ALTER TABLE perfil
    ADD COLUMN informacion_profesional jsonb;

ALTER TABLE producto
    ADD COLUMN titulo varchar(120),
    ADD COLUMN estado varchar(20) NOT NULL DEFAULT 'Disponible',
    ADD CONSTRAINT ck_producto_estado CHECK (estado IN ('Disponible', 'Agotado', 'Reservado')),
    ADD CONSTRAINT ck_producto_precio_no_negativo CHECK (precio >= 0);

ALTER TABLE evento
    ADD COLUMN titulo varchar(150);

ALTER TABLE servicio
    ADD COLUMN nombre_servicio varchar(120),
    ADD CONSTRAINT ck_servicio_precio_no_negativo CHECK (precio >= 0);

ALTER TABLE venta
    ADD COLUMN estado varchar(15) NOT NULL DEFAULT 'Completado',
    ADD CONSTRAINT ck_venta_estado CHECK (estado IN ('Completado', 'Pendiente', 'Cancelado')),
    ADD CONSTRAINT ck_venta_total_no_negativo CHECK (total >= 0);

ALTER TABLE venta_producto
    ADD CONSTRAINT ck_venta_producto_cantidad_positiva CHECK (cantidad > 0),
    ADD CONSTRAINT ck_venta_producto_precio_no_negativo CHECK (precio_unitario >= 0);

ALTER TABLE usuario_evento
    ADD COLUMN estado_participacion varchar(15) NOT NULL DEFAULT 'Confirmado',
    ADD CONSTRAINT ck_usuario_evento_estado CHECK (estado_participacion IN ('Confirmado', 'Pendiente', 'Cancelado'));

--
-- 1.1- Poblamiento Directo mediante INSERT INTO (Catálogos Base):
--

INSERT INTO rol (id_rol, nombre_rol, descripcion) VALUES
(1, 'Administrador', 'Gestiona usuarios, contenido y configuración de la red social'),
(2, 'Auxiliar',      'Apoya la moderación y la gestión operativa'),
(3, 'Miembro',       'Usuario registrado con acceso completo a la red social'),
(4, 'Visitante',     'Usuario con acceso restringido de solo consulta');

INSERT INTO tipo_usuario (id_tipo_usuario, nombre_tipo, descripcion) VALUES
(1, 'Estudiante',    'Estudiante activo de la institución'),
(2, 'Docente',       'Docente vinculado a la institución'),
(3, 'Egresado',      'Persona graduada de la institución'),
(4, 'Empleado',      'Empleado administrativo o de apoyo vinculado'),
(5, 'Empresario',    'Empresario o aliado externo de la comunidad'),
(6, 'Ex-Empleado',   'Persona que fue empleado de la institución'),
(7, 'Ex-Estudiante', 'Persona que fue estudiante sin culminar su programa'),
(8, 'Ex-Docente',    'Persona que fue docente de la institución'),
(9, 'Guess',         'Invitado externo sin vínculo institucional');

INSERT INTO tipo_servicio (id_tipo_servicio, nombre_tipo, descripcion) VALUES
(1,  'Asesoría académica',          'Acompañamiento en asignaturas y trabajos académicos'),
(2,  'Tutorías',                    'Tutorías personalizadas por asignatura'),
(3,  'Mantenimiento Moto',          'Mantenimiento y reparación de motocicletas'),
(4,  'Mantenimiento Computadores',  'Mantenimiento preventivo y correctivo de equipos de cómputo'),
(5,  'Diseño gráfico',              'Diseño de logos, piezas gráficas y publicidad'),
(6,  'Desarrollo de software',      'Desarrollo de aplicaciones y sistemas de información'),
(7,  'Traducción',                  'Traducción de documentos y textos'),
(8,  'Fotografía',                  'Fotografía de eventos, retratos y productos'),
(9,  'Transporte',                  'Servicio de transporte y domicilios'),
(10, 'Catering y alimentación',     'Preparación de alimentos para eventos'),
(11, 'Clases de idiomas',           'Clases de inglés, francés y otros idiomas'),
(12, 'Asesoría de tesis',           'Orientación metodológica para trabajos de grado'),
(13, 'Edición de video',            'Edición y producción de contenido audiovisual'),
(14, 'Reparación de celulares',     'Reparación de teléfonos móviles y tabletas'),
(15, 'Asesoría contable',           'Apoyo en contabilidad y declaración de renta'),
(16, 'Asesoría jurídica',           'Orientación legal básica'),
(17, 'Diseño web',                  'Diseño y desarrollo de sitios web'),
(18, 'Clases de música',            'Clases de instrumentos y formación musical'),
(19, 'Entrenamiento deportivo',     'Entrenamiento físico y deportivo personalizado'),
(20, 'Limpieza y aseo',             'Servicios de limpieza y aseo');

INSERT INTO tipo_producto (id_tipo_producto, nombre_tipo, descripcion) VALUES
(1,  'Libros',                   'Libros y textos académicos'),
(2,  'Motocicletas',             'Motocicletas nuevas y usadas'),
(3,  'Alimentos',                'Alimentos y bebidas'),
(4,  'Tecnología/Computadores',  'Computadores, portátiles y accesorios tecnológicos'),
(5,  'Celulares y accesorios',   'Teléfonos móviles y accesorios'),
(6,  'Ropa y calzado',           'Prendas de vestir y calzado'),
(7,  'Papelería y útiles',       'Papelería y útiles escolares'),
(8,  'Muebles',                  'Muebles para el hogar y la oficina'),
(9,  'Bicicletas',               'Bicicletas y repuestos'),
(10, 'Electrodomésticos',        'Electrodomésticos para el hogar'),
(11, 'Instrumentos musicales',   'Instrumentos musicales y accesorios'),
(12, 'Equipos deportivos',       'Implementos y equipos deportivos'),
(13, 'Videojuegos',              'Consolas y videojuegos'),
(14, 'Artesanías',               'Productos artesanales'),
(15, 'Cosméticos y cuidado',     'Cosméticos y productos de cuidado personal'),
(16, 'Herramientas',             'Herramientas manuales y eléctricas'),
(17, 'Software y licencias',     'Software y licencias digitales'),
(18, 'Material de laboratorio',  'Insumos y equipos de laboratorio'),
(19, 'Accesorios para vehículos','Accesorios y repuestos para vehículos'),
(20, 'Otros',                    'Otros productos no clasificados');

INSERT INTO tipo_evento (id_tipo_evento, nombre_tipo, descripcion) VALUES
(1,  'Congresos',                'Congresos académicos y científicos'),
(2,  'Conferencias',             'Conferencias magistrales'),
(3,  'Talleres',                 'Talleres prácticos de formación'),
(4,  'Seminarios',               'Seminarios de profundización'),
(5,  'Simposios',                'Simposios temáticos'),
(6,  'Foros',                    'Foros de discusión'),
(7,  'Charlas',                  'Charlas informativas'),
(8,  'Cursos cortos',            'Cursos de corta duración'),
(9,  'Hackathon',                'Maratones de programación e innovación'),
(10, 'Ferias empresariales',     'Ferias de emprendimiento y empresas'),
(11, 'Ferias de empleo',         'Ferias de vinculación laboral'),
(12, 'Exposiciones',             'Exposiciones artísticas y de proyectos'),
(13, 'Conciertos',               'Eventos musicales'),
(14, 'Torneos deportivos',       'Torneos y competencias deportivas'),
(15, 'Encuentros de egresados',  'Encuentros de la comunidad de egresados'),
(16, 'Ceremonias de grado',      'Ceremonias de graduación'),
(17, 'Semilleros de investigación','Encuentros de semilleros de investigación'),
(18, 'Webinars',                 'Eventos virtuales en línea'),
(19, 'Jornadas culturales',      'Jornadas culturales y artísticas'),
(20, 'Reuniones de grupo',       'Reuniones de grupos de interés');

--
-- 1.2- oblamiento Masivo Automatizado (Generadores Aleatorios):
--

SELECT setseed(0.42);

WITH nom AS (
    SELECT ARRAY['Juan','Carlos','Andrés','Santiago','Mateo','Sebastián','Daniel','Camilo','Felipe','David',
                 'María','Valentina','Sofía','Camila','Isabella','Daniela','Laura','Paula','Natalia','Andrea',
                 'Luis','Jorge','Alejandro','Diego','Nicolás','Ana','Carolina','Juliana','Manuela','Mariana'] AS nombres,
           ARRAY['Gómez','Rodríguez','Martínez','López','García','Hernández','Pérez','Sánchez','Ramírez','Torres',
                 'Díaz','Vargas','Castro','Moreno','Ortiz','Rojas','Jiménez','Muñoz','Álvarez','Restrepo',
                 'Zapata','Giraldo','Ospina','Henao','Arango','Cardona','Londoño','Montoya','Valencia','Mejía'] AS apellidos
), base AS (
    SELECT g,
           CASE WHEN g <= 7000  THEN 1 WHEN g <= 7500  THEN 2 WHEN g <= 17500 THEN 3
                WHEN g <= 18000 THEN 4 WHEN g <= 18050 THEN 5 WHEN g <= 18100 THEN 6
                WHEN g <= 18400 THEN 7 WHEN g <= 18500 THEN 8 ELSE 9 END AS tipo,
           1 + floor(random() * 30)::int AS i_nom,
           1 + floor(random() * 30)::int AS i_ap1,
           1 + floor(random() * 30)::int AS i_ap2,
           floor(random() * 2515)::int   AS dias,
           random()                      AS r_saldo
    FROM generate_series(1, 18550) g
)
INSERT INTO usuario (id_rol, id_tipo_usuario, nombre_completo, nombre_usuario, correo, "contraseña", fecha_registro, saldo)
SELECT CASE WHEN b.g = 1 THEN 1 WHEN b.tipo = 9 THEN 4 WHEN b.tipo = 4 THEN 2 ELSE 3 END,
       b.tipo,
       n.nombres[b.i_nom] || ' ' || n.apellidos[b.i_ap1] || ' ' || n.apellidos[b.i_ap2],
       'usuario' || lpad(b.g::text, 5, '0'),
       lower(translate(n.nombres[b.i_nom] || '.' || n.apellidos[b.i_ap1], 'ÁÉÍÓÚÑáéíóúñ', 'AEIOUNaeioun'))
           || b.g || '@pascualbravo.edu.co',
       md5(b.g::text || 'pascualina'),
       DATE '2020-01-01' + b.dias,
       round((b.r_saldo * 2000000)::numeric, 2)
FROM base b CROSS JOIN nom n
ORDER BY b.g;

INSERT INTO perfil (id_usuario, foto_perfil_url, biografia)
SELECT id_usuario,
       'https://redsocial.pascualbravo.edu.co/fotos/' || id_usuario || '.jpg',
       'Miembro de la Red Social Pascualina desde ' || to_char(fecha_registro, 'YYYY')
FROM usuario
ORDER BY id_usuario;

WITH org AS (SELECT array_agg(id_usuario) AS a FROM usuario WHERE id_tipo_usuario IN (2, 4, 5)),
base AS (
    SELECT g,
           1 + floor(random() * 20)::int AS id_tipo_evento,
           org.a[1 + floor(random() * array_length(org.a, 1))::int] AS organizador,
           DATE '2023-01-01' + floor(random() * 1461)::int AS fecha,
           make_time(7 + floor(random() * 13)::int, (floor(random() * 4) * 15)::int, 0) AS hora,
           1 + floor(random() * 8)::int AS i_lugar
    FROM generate_series(1, 3000) g, org
)
INSERT INTO evento (id_tipo_evento, id_usuario_organizador, fecha, hora, lugar, titulo)
SELECT b.id_tipo_evento, b.organizador, b.fecha, b.hora,
       (ARRAY['Auditorio Principal','Aula Máxima','Biblioteca','Bloque de Ingeniería','Coliseo',
              'Plazoleta Central','Sala de Sistemas','Virtual (Teams)'])[b.i_lugar],
       te.nombre_tipo || ' Pascualino #' || b.g
FROM base b JOIN tipo_evento te ON te.id_tipo_evento = b.id_tipo_evento
ORDER BY b.g;

WITH usu AS (SELECT array_agg(id_usuario) AS a FROM usuario),
base AS (
    SELECT g,
           1 + floor(random() * 20)::int AS id_tipo_servicio,
           usu.a[1 + floor(random() * array_length(usu.a, 1))::int] AS id_usuario,
           (20 + floor(random() * 481))::int * 1000 AS precio
    FROM generate_series(1, 3000) g, usu
)
INSERT INTO servicio (id_tipo_servicio, id_usuario, precio, nombre_servicio)
SELECT b.id_tipo_servicio, b.id_usuario, b.precio, ts.nombre_tipo || ' - Oferta #' || b.g
FROM base b JOIN tipo_servicio ts ON ts.id_tipo_servicio = b.id_tipo_servicio
ORDER BY b.g;

WITH usu AS (SELECT array_agg(id_usuario) AS a FROM usuario),
base AS (
    SELECT g,
           1 + floor(random() * 20)::int AS id_tipo_producto,
           usu.a[1 + floor(random() * array_length(usu.a, 1))::int] AS id_usuario,
           (10 + floor(random() * 2991))::int * 1000 AS precio,
           random() AS r_estado,
           1 + floor(random() * 6)::int AS i_marca,
           random() AS r_cond
    FROM generate_series(1, 3000) g, usu
)
INSERT INTO producto (id_tipo_producto, id_usuario, precio, titulo, estado, especificaciones)
SELECT b.id_tipo_producto, b.id_usuario, b.precio,
       tp.nombre_tipo || ' - Artículo #' || b.g,
       CASE WHEN b.r_estado < 0.70 THEN 'Disponible' WHEN b.r_estado < 0.90 THEN 'Agotado' ELSE 'Reservado' END,
       jsonb_build_object('marca', (ARRAY['Genérica','Premium','Económica','Importada','Artesanal','Institucional'])[b.i_marca],
                          'condicion', CASE WHEN b.r_cond < 0.6 THEN 'nuevo' ELSE 'usado' END)
FROM base b JOIN tipo_producto tp ON tp.id_tipo_producto = b.id_tipo_producto
ORDER BY b.g;

WITH prod AS (SELECT array_agg(id_producto) AS a FROM producto),
usu AS (SELECT array_agg(id_usuario) AS a FROM usuario),
off AS (SELECT COALESCE(MAX(id_venta), 0) AS o FROM venta),
s AS MATERIALIZED (
    SELECT g, off.o + g AS id_venta,
           prod.a[1 + floor(random() * array_length(prod.a, 1))::int] AS id_producto,
           1 + floor(random() * 3)::int AS cantidad,
           usu.a[1 + floor(random() * array_length(usu.a, 1))::int] AS comprador,
           random() AS r_estado, random() AS r_fecha
    FROM generate_series(1, 5000) g, prod, usu, off
),
j AS MATERIALIZED (
    SELECT s.*, p.precio, p.id_usuario AS vendedor
    FROM s JOIN producto p ON p.id_producto = s.id_producto
),
v AS (
    INSERT INTO venta (id_venta, id_usuario_comprador, id_usuario_vendedor, fecha_hora_venta, total, estado)
    SELECT id_venta, comprador, vendedor,
           TIMESTAMP '2024-01-01' + r_fecha * INTERVAL '1055 days',
           cantidad * precio,
           CASE WHEN r_estado < 0.70 THEN 'Completado' WHEN r_estado < 0.90 THEN 'Pendiente' ELSE 'Cancelado' END
    FROM j
)
INSERT INTO venta_producto (id_venta, id_producto, cantidad, precio_unitario)
SELECT id_venta, id_producto, cantidad, precio FROM j ORDER BY g;

WITH serv AS (SELECT array_agg(id_servicio) AS a FROM servicio),
usu AS (SELECT array_agg(id_usuario) AS a FROM usuario),
off AS (SELECT COALESCE(MAX(id_venta), 0) AS o FROM venta),
s AS MATERIALIZED (
    SELECT g, off.o + g AS id_venta,
           serv.a[1 + floor(random() * array_length(serv.a, 1))::int] AS id_servicio,
           usu.a[1 + floor(random() * array_length(usu.a, 1))::int] AS solicitante,
           random() AS r_estado, random() AS r_fecha
    FROM generate_series(1, 5000) g, serv, usu, off
),
j AS MATERIALIZED (
    SELECT s.*, sv.precio, sv.id_usuario AS proveedor
    FROM s JOIN servicio sv ON sv.id_servicio = s.id_servicio
),
v AS (
    INSERT INTO venta (id_venta, id_usuario_comprador, id_usuario_vendedor, fecha_hora_venta, total, estado)
    SELECT id_venta, solicitante, proveedor,
           TIMESTAMP '2024-01-01' + r_fecha * INTERVAL '1055 days',
           precio,
           CASE WHEN r_estado < 0.70 THEN 'Completado' WHEN r_estado < 0.90 THEN 'Pendiente' ELSE 'Cancelado' END
    FROM j
)
INSERT INTO venta_servicio (id_venta, id_servicio, precio)
SELECT id_venta, id_servicio, precio FROM j ORDER BY g;

WITH usu AS (SELECT array_agg(id_usuario) AS a FROM usuario),
ev AS (SELECT array_agg(id_evento ORDER BY id_evento) AS a FROM evento),
base AS (
    SELECT usu.a[1 + floor(random() * array_length(usu.a, 1))::int] AS id_usuario,
           ev.a[1 + floor(array_length(ev.a, 1) * power(random(), 3))::int] AS id_evento,
           random() AS r_estado
    FROM generate_series(1, 12000) g, usu, ev
)
INSERT INTO usuario_evento (id_usuario, id_evento, estado_participacion)
SELECT DISTINCT ON (id_usuario, id_evento)
       id_usuario, id_evento,
       CASE WHEN r_estado < 0.75 THEN 'Confirmado' WHEN r_estado < 0.90 THEN 'Pendiente' ELSE 'Cancelado' END
FROM base
ORDER BY id_usuario, id_evento;

ALTER TABLE producto  ALTER COLUMN titulo          SET NOT NULL;
ALTER TABLE evento    ALTER COLUMN titulo          SET NOT NULL;
ALTER TABLE servicio  ALTER COLUMN nombre_servicio SET NOT NULL;

DO $$
DECLARE r record;
BEGIN
    FOR r IN SELECT table_name, column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND column_default LIKE 'nextval%'
    LOOP
        EXECUTE format(
            'SELECT setval(pg_get_serial_sequence(%L, %L), COALESCE((SELECT MAX(%I) FROM %I), 1), (SELECT COUNT(*) > 0 FROM %I))',
            'public.' || r.table_name, r.column_name, r.column_name, r.table_name, r.table_name);
    END LOOP;
END $$;

SELECT 'rol' AS tabla, COUNT(*) AS registros FROM rol
UNION ALL SELECT 'tipo_usuario',    COUNT(*) FROM tipo_usuario
UNION ALL SELECT 'tipo_servicio',   COUNT(*) FROM tipo_servicio
UNION ALL SELECT 'tipo_producto',   COUNT(*) FROM tipo_producto
UNION ALL SELECT 'tipo_evento',     COUNT(*) FROM tipo_evento
UNION ALL SELECT 'usuario',         COUNT(*) FROM usuario
UNION ALL SELECT 'perfil',          COUNT(*) FROM perfil
UNION ALL SELECT 'evento',          COUNT(*) FROM evento
UNION ALL SELECT 'servicio',        COUNT(*) FROM servicio
UNION ALL SELECT 'producto',        COUNT(*) FROM producto
UNION ALL SELECT 'venta',           COUNT(*) FROM venta
UNION ALL SELECT 'venta_producto',  COUNT(*) FROM venta_producto
UNION ALL SELECT 'venta_servicio',  COUNT(*) FROM venta_servicio
UNION ALL SELECT 'usuario_evento',  COUNT(*) FROM usuario_evento;

SELECT tu.id_tipo_usuario, tu.nombre_tipo, COUNT(u.id_usuario) AS total_usuarios
FROM tipo_usuario tu LEFT JOIN usuario u ON u.id_tipo_usuario = tu.id_tipo_usuario
GROUP BY tu.id_tipo_usuario, tu.nombre_tipo
ORDER BY tu.id_tipo_usuario;

--
-- 1.3- Respaldo Físico de la Base de Datos (AQUÍ O SE HACE NADA) - Se debe entregar el respaldo en archivo PLANO por aparte
--