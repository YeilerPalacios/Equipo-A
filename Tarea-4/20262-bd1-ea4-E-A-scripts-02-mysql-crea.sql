--
-- Scripst de Creación de la Base de Datos - SGBD MySQL
--
-- Todas las instrucciones se DEBEN EJECUTAR EN SECUENCIA SIN ERRORES
-- NOTA: Ojo con las tablas relacionadas. Primero las independientes y después las dependientes
--

--
-- Creación de las tablas
-- 

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(30) NOT NULL,
    descripcion VARCHAR(255),
    CONSTRAINT uk_rol_nombre_rol UNIQUE (nombre_rol)
) ENGINE=InnoDB;

CREATE TABLE tipo_usuario (
    id_tipo_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    CONSTRAINT uk_tipo_usuario_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB;

CREATE TABLE interes (
    id_interes INT AUTO_INCREMENT PRIMARY KEY,
    nombre_interes VARCHAR(50) NOT NULL,
    CONSTRAINT uk_interes_nombre_interes UNIQUE (nombre_interes)
) ENGINE=InnoDB;

CREATE TABLE habilidad (
    id_habilidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_habilidad VARCHAR(50) NOT NULL,
    CONSTRAINT uk_habilidad_nombre_habilidad UNIQUE (nombre_habilidad)
) ENGINE=InnoDB;

CREATE TABLE tipo_servicio (
    id_tipo_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    CONSTRAINT uk_tipo_servicio_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB;

CREATE TABLE tipo_producto (
    id_tipo_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    CONSTRAINT uk_tipo_producto_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB;

CREATE TABLE tipo_evento (
    id_tipo_evento INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    CONSTRAINT uk_tipo_evento_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB;

CREATE TABLE etiqueta (
    id_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_etiqueta VARCHAR(50) NOT NULL,
    CONSTRAINT uk_etiqueta_nombre_etiqueta UNIQUE (nombre_etiqueta)
) ENGINE=InnoDB;

CREATE TABLE chat (
    id_chat INT AUTO_INCREMENT PRIMARY KEY,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    id_tipo_usuario INT NOT NULL,
    nombre_completo VARCHAR(120) NOT NULL,
    nombre_usuario VARCHAR(50) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    CONSTRAINT uk_usuario_nombre_usuario UNIQUE (nombre_usuario),
    CONSTRAINT uk_usuario_correo UNIQUE (correo),
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol (id_rol),
    CONSTRAINT fk_usuario_tipo_usuario FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario (id_tipo_usuario)
) ENGINE=InnoDB;

CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    foto_perfil_url VARCHAR(255),
    biografia VARCHAR(500),
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_perfil_id_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE publicacion (
    id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    contenido_texto VARCHAR(1000),
    contenido_multimedia VARCHAR(255),
    fecha_hora_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_publicacion VARCHAR(20) NOT NULL,
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_publicacion_estado CHECK (estado_publicacion IN ('PUBLICADO', 'OCULTO', 'ELIMINADO'))
) ENGINE=InnoDB;

CREATE TABLE comentario (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_usuario INT NOT NULL,
    contenido_comentario VARCHAR(500) NOT NULL,
    fecha_hora_comentario DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_comentario_padre INT,
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion),
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_comentario_padre FOREIGN KEY (id_comentario_padre) REFERENCES comentario (id_comentario)
) ENGINE=InnoDB;

CREATE TABLE grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_creador INT NOT NULL,
    nombre_grupo VARCHAR(80) NOT NULL,
    CONSTRAINT fk_grupo_usuario_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE servicio (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_servicio INT NOT NULL,
    id_usuario INT NOT NULL,
    precio DECIMAL(10,2),
    CONSTRAINT fk_servicio_tipo_servicio FOREIGN KEY (id_tipo_servicio) REFERENCES tipo_servicio (id_tipo_servicio),
    CONSTRAINT fk_servicio_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_producto INT NOT NULL,
    id_usuario INT NOT NULL,
    precio DECIMAL(10,2),
    CONSTRAINT fk_producto_tipo_producto FOREIGN KEY (id_tipo_producto) REFERENCES tipo_producto (id_tipo_producto),
    CONSTRAINT fk_producto_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE evento (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_evento INT NOT NULL,
    id_usuario_organizador INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    lugar VARCHAR(150),
    CONSTRAINT fk_evento_tipo_evento FOREIGN KEY (id_tipo_evento) REFERENCES tipo_evento (id_tipo_evento),
    CONSTRAINT fk_evento_usuario_organizador FOREIGN KEY (id_usuario_organizador) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE mensaje (
    id_mensaje INT AUTO_INCREMENT PRIMARY KEY,
    id_chat INT NOT NULL,
    id_usuario_emisor INT NOT NULL,
    contenido_mensaje VARCHAR(500) NOT NULL,
    fecha_hora_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mensaje_chat FOREIGN KEY (id_chat) REFERENCES chat (id_chat),
    CONSTRAINT fk_mensaje_usuario_emisor FOREIGN KEY (id_usuario_emisor) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE resena (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_autor INT NOT NULL,
    id_servicio INT,
    id_producto INT,
    id_evento INT,
    calificacion INT NOT NULL,
    comentario_resena VARCHAR(500),
    CONSTRAINT fk_resena_usuario_autor FOREIGN KEY (id_usuario_autor) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_resena_servicio FOREIGN KEY (id_servicio) REFERENCES servicio (id_servicio),
    CONSTRAINT fk_resena_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
    CONSTRAINT fk_resena_evento FOREIGN KEY (id_evento) REFERENCES evento (id_evento),
    CONSTRAINT ck_resena_calificacion CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT ck_resena_un_solo_destino CHECK ((CASE WHEN id_servicio IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN id_producto IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN id_evento IS NOT NULL THEN 1 ELSE 0 END) = 1)
) ENGINE=InnoDB;

CREATE TABLE notificacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_destino INT NOT NULL,
    id_publicacion INT,
    id_comentario INT,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_hora_notificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notificacion_usuario_destino FOREIGN KEY (id_usuario_destino) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_notificacion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion),
    CONSTRAINT fk_notificacion_comentario FOREIGN KEY (id_comentario) REFERENCES comentario (id_comentario)
) ENGINE=InnoDB;

CREATE TABLE venta (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_comprador INT NOT NULL,
    id_usuario_vendedor INT NOT NULL,
    fecha_hora_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_venta_usuario_comprador FOREIGN KEY (id_usuario_comprador) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_venta_usuario_vendedor FOREIGN KEY (id_usuario_vendedor) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE seguidor (
    id_seguidor INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_seguidor INT NOT NULL,
    id_usuario_seguido INT NOT NULL,
    CONSTRAINT fk_seguidor_usuario_seguidor FOREIGN KEY (id_usuario_seguidor) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_seguidor_usuario_seguido FOREIGN KEY (id_usuario_seguido) REFERENCES usuario (id_usuario),
    CONSTRAINT uk_seguidor_par UNIQUE (id_usuario_seguidor, id_usuario_seguido)
) ENGINE=InnoDB;

CREATE TABLE usuario_interes (
    id_usuario_interes INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_interes INT NOT NULL,
    CONSTRAINT fk_usuario_interes_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_usuario_interes_interes FOREIGN KEY (id_interes) REFERENCES interes (id_interes),
    CONSTRAINT uk_usuario_interes_par UNIQUE (id_usuario, id_interes)
) ENGINE=InnoDB;

CREATE TABLE usuario_habilidad (
    id_usuario_habilidad INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_habilidad INT NOT NULL,
    CONSTRAINT fk_usuario_habilidad_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_usuario_habilidad_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad (id_habilidad),
    CONSTRAINT uk_usuario_habilidad_par UNIQUE (id_usuario, id_habilidad)
) ENGINE=InnoDB;

CREATE TABLE usuario_grupo (
    id_usuario_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    CONSTRAINT fk_usuario_grupo_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_usuario_grupo_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo),
    CONSTRAINT uk_usuario_grupo_par UNIQUE (id_usuario, id_grupo)
) ENGINE=InnoDB;

CREATE TABLE usuario_evento (
    id_usuario_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_evento INT NOT NULL,
    CONSTRAINT fk_usuario_evento_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_usuario_evento_evento FOREIGN KEY (id_evento) REFERENCES evento (id_evento),
    CONSTRAINT uk_usuario_evento_par UNIQUE (id_usuario, id_evento)
) ENGINE=InnoDB;

CREATE TABLE publicacion_etiqueta (
    id_publicacion_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_etiqueta INT NOT NULL,
    CONSTRAINT fk_publicacion_etiqueta_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion),
    CONSTRAINT fk_publicacion_etiqueta_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES etiqueta (id_etiqueta),
    CONSTRAINT uk_publicacion_etiqueta_par UNIQUE (id_publicacion, id_etiqueta)
) ENGINE=InnoDB;

CREATE TABLE chat_usuario (
    id_chat_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_chat INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT fk_chat_usuario_chat FOREIGN KEY (id_chat) REFERENCES chat (id_chat),
    CONSTRAINT fk_chat_usuario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT uk_chat_usuario_par UNIQUE (id_chat, id_usuario)
) ENGINE=InnoDB;

CREATE TABLE venta_producto (
    id_venta_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_venta_producto_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
    CONSTRAINT fk_venta_producto_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
    CONSTRAINT uk_venta_producto_par UNIQUE (id_venta, id_producto)
) ENGINE=InnoDB;

CREATE TABLE venta_servicio (
    id_venta_servicio INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_servicio INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_venta_servicio_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
    CONSTRAINT fk_venta_servicio_servicio FOREIGN KEY (id_servicio) REFERENCES servicio (id_servicio),
    CONSTRAINT uk_venta_servicio_par UNIQUE (id_venta, id_servicio)
) ENGINE=InnoDB;

CREATE TABLE venta_evento (
    id_venta_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_evento INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_venta_evento_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
    CONSTRAINT fk_venta_evento_evento FOREIGN KEY (id_evento) REFERENCES evento (id_evento),
    CONSTRAINT uk_venta_evento_par UNIQUE (id_venta, id_evento)
) ENGINE=InnoDB;
