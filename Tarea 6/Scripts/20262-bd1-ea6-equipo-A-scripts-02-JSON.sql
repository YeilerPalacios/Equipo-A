--
-- Scripts - Enunciados DML para Manipulación de Datos Semi-Estructurados (JSON)
-- Manipulación de Campo JSON (Perfil Profesional y Competencias)
--

UPDATE perfil
SET informacion_profesional = '{
        "resumen_profesional": "Ingeniero en formación con énfasis en bases de datos y desarrollo de software.",
        "skills": ["SQL", "PostgreSQL", "Python", "Modelado de datos"],
        "areas_interes": ["Bases de datos", "Inteligencia artificial", "Analítica de datos"],
        "idiomas": [
            {"idioma": "Español", "nivel": "Nativo"},
            {"idioma": "Inglés",  "nivel": "B2"}
        ],
        "proyectos_destacados": [
            {"nombre": "Red Social Pascualina", "anio": 2026, "rol": "Diseñador de base de datos"},
            {"nombre": "Sistema de inventarios", "anio": 2025, "rol": "Desarrollador"}
        ]
    }'::jsonb,
    fecha_actualizacion = CURRENT_TIMESTAMP
WHERE id_usuario = 1;

UPDATE perfil p
SET informacion_profesional = jsonb_build_object(
        'resumen_profesional',
            'Miembro de la comunidad Pascualina con interés en ' ||
            (ARRAY['bases de datos','desarrollo web','ciencia de datos','redes y telecomunicaciones',
                   'automatización industrial','emprendimiento'])[1 + floor(random() * 6)::int],
        'skills',
            (SELECT jsonb_agg(x)
             FROM (SELECT x FROM unnest(ARRAY['SQL','Python','Java','JavaScript','PostgreSQL','Excel',
                                              'Power BI','Git','Docker','Linux','Redes','AutoCAD']) AS x
                   ORDER BY random() + 0 * p.id_perfil LIMIT 4) t),
        'areas_interes',
            (SELECT jsonb_agg(x)
             FROM (SELECT x FROM unnest(ARRAY['Bases de datos','Inteligencia artificial','Ciberseguridad',
                                              'Desarrollo móvil','Analítica de datos','Internet de las cosas',
                                              'Emprendimiento','Robótica']) AS x
                   ORDER BY random() + 0 * p.id_perfil LIMIT 2) t),
        'idiomas',
            jsonb_build_array(
                jsonb_build_object('idioma', 'Español', 'nivel', 'Nativo'),
                jsonb_build_object('idioma', 'Inglés',
                                   'nivel', (ARRAY['A2','B1','B2','C1'])[1 + floor(random() * 4)::int])),
        'proyectos_destacados',
            jsonb_build_array(
                jsonb_build_object('nombre', 'Proyecto de aula ' || (1 + floor(random() * 50)::int),
                                   'anio', 2022 + floor(random() * 5)::int,
                                   'rol', (ARRAY['Líder','Desarrollador','Analista','Diseñador'])[1 + floor(random() * 4)::int]))
    ),
    fecha_actualizacion = CURRENT_TIMESTAMP
WHERE p.informacion_profesional IS NULL;

SELECT COUNT(*) AS perfiles_con_json FROM perfil WHERE informacion_profesional IS NOT NULL;

SELECT u.id_usuario,
       u.nombre_completo,
       p.informacion_profesional ->> 'resumen_profesional'            AS resumen,
       p.informacion_profesional -> 'skills'                           AS skills,
       p.informacion_profesional -> 'skills' ->> 0                     AS primera_skill,
       jsonb_array_length(p.informacion_profesional -> 'skills')       AS total_skills,
       p.informacion_profesional #>> '{idiomas,1,idioma}'              AS segundo_idioma,
       p.informacion_profesional #>> '{idiomas,1,nivel}'               AS nivel_segundo_idioma,
       p.informacion_profesional #>> '{proyectos_destacados,0,nombre}' AS primer_proyecto
FROM perfil p
JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.id_usuario <= 5
ORDER BY u.id_usuario;

SELECT u.id_usuario, u.nombre_completo,
       p.informacion_profesional ->> 'resumen_profesional' AS resumen
FROM perfil p
JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.informacion_profesional @> '{"skills": ["SQL"]}'
  AND p.informacion_profesional #>> '{idiomas,1,nivel}' IN ('B2', 'C1')
ORDER BY u.id_usuario
LIMIT 10;

SELECT skill, COUNT(*) AS usuarios
FROM perfil p, jsonb_array_elements_text(p.informacion_profesional -> 'skills') AS skill
GROUP BY skill
ORDER BY usuarios DESC;

UPDATE perfil
SET informacion_profesional =
        jsonb_set(
            jsonb_set(informacion_profesional,
                      '{skills}', (informacion_profesional -> 'skills') || '"Git"'::jsonb),
            '{idiomas,1,nivel}', '"C1"'),
    fecha_actualizacion = CURRENT_TIMESTAMP
WHERE id_usuario = 1;

SELECT informacion_profesional -> 'skills'            AS skills,
       informacion_profesional #>> '{idiomas,1,nivel}' AS nivel_ingles
FROM perfil WHERE id_usuario = 1;

UPDATE perfil
SET informacion_profesional = (informacion_profesional #- '{skills,0}') - 'areas_interes',
    fecha_actualizacion = CURRENT_TIMESTAMP
WHERE id_usuario = 1;

SELECT jsonb_pretty(informacion_profesional) AS documento_json FROM perfil WHERE id_usuario = 1;