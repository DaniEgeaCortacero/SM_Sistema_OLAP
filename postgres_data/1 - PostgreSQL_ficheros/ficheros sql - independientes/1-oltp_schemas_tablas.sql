BEGIN;

DROP SCHEMA IF EXISTS oltp_administracion CASCADE;
DROP SCHEMA IF EXISTS oltp_tecnico CASCADE;
DROP SCHEMA IF EXISTS oltp_ventas CASCADE;
DROP SCHEMA IF EXISTS oltp_marketing CASCADE;
DROP SCHEMA IF EXISTS oltp_rrhh CASCADE;

CREATE SCHEMA oltp_administracion;
CREATE SCHEMA oltp_tecnico;
CREATE SCHEMA oltp_ventas;
CREATE SCHEMA oltp_marketing;
CREATE SCHEMA oltp_rrhh;

-- =========================================================
-- OLTP_VENTAS
-- =========================================================
CREATE TABLE oltp_ventas.cliente (
    id_cliente           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni                  VARCHAR(20) NOT NULL UNIQUE,
    nombre               VARCHAR(80) NOT NULL,
    apellidos            VARCHAR(120) NOT NULL,
    email                VARCHAR(150),
    telefono             VARCHAR(25),
    pais                 VARCHAR(80),
    region               VARCHAR(80),
    provincia            VARCHAR(80),
    ciudad               VARCHAR(80),
    direccion            VARCHAR(200),
    CONSTRAINT ventas_cliente_email_chk CHECK (email IS NULL OR position('@' in email) > 1)
);

CREATE TABLE oltp_ventas.categoria_componente (
    id_categoria         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_categoria     VARCHAR(100) NOT NULL,
    descripcion          TEXT
);

CREATE TABLE oltp_ventas.componente (
    id_componente        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(120) NOT NULL,
    descripcion          TEXT,
    precio_venta         NUMERIC(12,2) NOT NULL DEFAULT 0,
    precio_compra        NUMERIC(12,2) NOT NULL DEFAULT 0,
    stock                INTEGER NOT NULL DEFAULT 0,
    stock_minimo         INTEGER NOT NULL DEFAULT 0,
    tipo_producto        VARCHAR(80),
    marca                VARCHAR(80),
    modelos_compatibles  TEXT,
    id_categoria         BIGINT,
    CONSTRAINT ventas_componente_precio_venta_chk CHECK (precio_venta >= 0),
    CONSTRAINT ventas_componente_precio_compra_chk CHECK (precio_compra >= 0),
    CONSTRAINT ventas_componente_stock_chk CHECK (stock >= 0),
    CONSTRAINT ventas_componente_stock_minimo_chk CHECK (stock_minimo >= 0),
    CONSTRAINT fk_ventas_componente_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES oltp_ventas.categoria_componente (id_categoria)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE oltp_ventas.pedido (
    id_pedido            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_pedido         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado               VARCHAR(40) NOT NULL,
    total                NUMERIC(12,2) NOT NULL DEFAULT 0,
    metodo_pago          VARCHAR(50),
    direccion_envio      VARCHAR(200),
    id_cliente           BIGINT NOT NULL,
    CONSTRAINT ventas_pedido_total_chk CHECK (total >= 0),
    CONSTRAINT fk_ventas_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES oltp_ventas.cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_ventas.detalle_pedido (
    id_detalle           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad             INTEGER NOT NULL,
    precio_unitario      NUMERIC(12,2) NOT NULL,
    subtotal             NUMERIC(12,2) NOT NULL,
    id_pedido            BIGINT NOT NULL,
    id_componente        BIGINT NOT NULL,
    CONSTRAINT ventas_detalle_pedido_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT ventas_detalle_pedido_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT ventas_detalle_pedido_subtotal_chk CHECK (subtotal >= 0),
    CONSTRAINT fk_ventas_detalle_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES oltp_ventas.pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_ventas_detalle_pedido_componente
        FOREIGN KEY (id_componente)
        REFERENCES oltp_ventas.componente (id_componente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_ventas_detalle_pedido UNIQUE (id_pedido, id_componente)
);

-- =========================================================
-- OLTP_MARKETING
-- =========================================================
CREATE TABLE oltp_marketing.cliente (
    id_cliente           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni                  VARCHAR(20) NOT NULL UNIQUE,
    nombre               VARCHAR(80) NOT NULL,
    apellidos            VARCHAR(120) NOT NULL,
    email                VARCHAR(150),
    telefono             VARCHAR(25),
    pais                 VARCHAR(80),
    region               VARCHAR(80),
    provincia            VARCHAR(80),
    ciudad               VARCHAR(80),
    direccion            VARCHAR(200),
    CONSTRAINT marketing_cliente_email_chk CHECK (email IS NULL OR position('@' in email) > 1)
);

CREATE TABLE oltp_marketing.categoria_componente (
    id_categoria         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_categoria     VARCHAR(100) NOT NULL,
    descripcion          TEXT
);

CREATE TABLE oltp_marketing.componente (
    id_componente        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(120) NOT NULL,
    descripcion          TEXT,
    precio_venta         NUMERIC(12,2) NOT NULL DEFAULT 0,
    precio_compra        NUMERIC(12,2) NOT NULL DEFAULT 0,
    stock                INTEGER NOT NULL DEFAULT 0,
    stock_minimo         INTEGER NOT NULL DEFAULT 0,
    tipo_producto        VARCHAR(80),
    marca                VARCHAR(80),
    modelos_compatibles  TEXT,
    id_categoria         BIGINT,
    CONSTRAINT marketing_componente_precio_venta_chk CHECK (precio_venta >= 0),
    CONSTRAINT marketing_componente_precio_compra_chk CHECK (precio_compra >= 0),
    CONSTRAINT marketing_componente_stock_chk CHECK (stock >= 0),
    CONSTRAINT marketing_componente_stock_minimo_chk CHECK (stock_minimo >= 0),
    CONSTRAINT fk_marketing_componente_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES oltp_marketing.categoria_componente (id_categoria)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE oltp_marketing.pedido (
    id_pedido            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_pedido         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado               VARCHAR(40) NOT NULL,
    total                NUMERIC(12,2) NOT NULL DEFAULT 0,
    metodo_pago          VARCHAR(50),
    direccion_envio      VARCHAR(200),
    id_cliente           BIGINT NOT NULL,
    CONSTRAINT marketing_pedido_total_chk CHECK (total >= 0),
    CONSTRAINT fk_marketing_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES oltp_marketing.cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_marketing.detalle_pedido (
    id_detalle           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad             INTEGER NOT NULL,
    precio_unitario      NUMERIC(12,2) NOT NULL,
    subtotal             NUMERIC(12,2) NOT NULL,
    id_pedido            BIGINT NOT NULL,
    id_componente        BIGINT NOT NULL,
    CONSTRAINT marketing_detalle_pedido_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT marketing_detalle_pedido_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT marketing_detalle_pedido_subtotal_chk CHECK (subtotal >= 0),
    CONSTRAINT fk_marketing_detalle_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES oltp_marketing.pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_marketing_detalle_pedido_componente
        FOREIGN KEY (id_componente)
        REFERENCES oltp_marketing.componente (id_componente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_marketing_detalle_pedido UNIQUE (id_pedido, id_componente)
);

-- =========================================================
-- OLTP_TECNICO
-- =========================================================
CREATE TABLE oltp_tecnico.vehiculo (
    id_vehiculo          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula            VARCHAR(20) NOT NULL UNIQUE,
    marca                VARCHAR(60) NOT NULL,
    modelo               VARCHAR(80) NOT NULL,
    anio                 INTEGER NOT NULL,
    num_bastidor         VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT tecnico_vehiculo_anio_chk CHECK (anio BETWEEN 1900 AND 2100)
);

CREATE TABLE oltp_tecnico.cita (
    id_cita              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha                DATE NOT NULL,
    hora                 TIME NOT NULL,
    motivo               VARCHAR(200),
    estado               VARCHAR(40) NOT NULL,
    id_vehiculo          BIGINT NOT NULL,
    CONSTRAINT fk_tecnico_cita_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES oltp_tecnico.vehiculo (id_vehiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_tecnico.empleado (
    id_empleado          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(80) NOT NULL,
    apellidos            VARCHAR(120) NOT NULL,
    telefono             VARCHAR(25),
    email                VARCHAR(150),
    puesto               VARCHAR(80) NOT NULL,
    CONSTRAINT tecnico_empleado_email_chk CHECK (email IS NULL OR position('@' in email) > 1)
);

CREATE TABLE oltp_tecnico.servicio (
    id_servicio          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_apertura       TIMESTAMP NOT NULL,
    fecha_cierre         TIMESTAMP,
    tipo                 VARCHAR(80) NOT NULL,
    descripcion          TEXT,
    estado               VARCHAR(40) NOT NULL,
    kilometraje          INTEGER,
    coste                NUMERIC(12,2) NOT NULL DEFAULT 0,
    id_vehiculo          BIGINT NOT NULL,
    id_empleado          BIGINT NOT NULL,
    CONSTRAINT tecnico_servicio_coste_chk CHECK (coste >= 0),
    CONSTRAINT tecnico_servicio_kilometraje_chk CHECK (kilometraje IS NULL OR kilometraje >= 0),
    CONSTRAINT tecnico_servicio_fechas_chk CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura),
    CONSTRAINT fk_tecnico_servicio_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES oltp_tecnico.vehiculo (id_vehiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_tecnico_servicio_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES oltp_tecnico.empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_tecnico.categoria_componente (
    id_categoria         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_categoria     VARCHAR(100) NOT NULL,
    descripcion          TEXT
);

CREATE TABLE oltp_tecnico.componente (
    id_componente        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(120) NOT NULL,
    descripcion          TEXT,
    precio_venta         NUMERIC(12,2) NOT NULL DEFAULT 0,
    precio_compra        NUMERIC(12,2) NOT NULL DEFAULT 0,
    stock                INTEGER NOT NULL DEFAULT 0,
    stock_minimo         INTEGER NOT NULL DEFAULT 0,
    tipo_producto        VARCHAR(80),
    marca                VARCHAR(80),
    modelos_compatibles  TEXT,
    id_categoria         BIGINT,
    CONSTRAINT tecnico_componente_precio_venta_chk CHECK (precio_venta >= 0),
    CONSTRAINT tecnico_componente_precio_compra_chk CHECK (precio_compra >= 0),
    CONSTRAINT tecnico_componente_stock_chk CHECK (stock >= 0),
    CONSTRAINT tecnico_componente_stock_minimo_chk CHECK (stock_minimo >= 0),
    CONSTRAINT fk_tecnico_componente_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES oltp_tecnico.categoria_componente (id_categoria)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE oltp_tecnico.servicio_componente (
    id_servicio_componente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad               INTEGER NOT NULL,
    precio_unitario        NUMERIC(12,2) NOT NULL,
    id_servicio            BIGINT NOT NULL,
    id_componente          BIGINT NOT NULL,
    CONSTRAINT tecnico_servicio_componente_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT tecnico_servicio_componente_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT fk_tecnico_servicio_componente_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES oltp_tecnico.servicio (id_servicio)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_tecnico_servicio_componente_componente
        FOREIGN KEY (id_componente)
        REFERENCES oltp_tecnico.componente (id_componente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_tecnico_servicio_componente UNIQUE (id_servicio, id_componente)
);

-- =========================================================
-- OLTP_RRHH
-- =========================================================
CREATE TABLE oltp_rrhh.departamento (
    id_departamento      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(100) NOT NULL,
    descripcion          TEXT
);

CREATE TABLE oltp_rrhh.empleado (
    id_empleado          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(80) NOT NULL,
    apellidos            VARCHAR(120) NOT NULL,
    dni                  VARCHAR(20) NOT NULL UNIQUE,
    telefono             VARCHAR(25),
    email                VARCHAR(150),
    puesto               VARCHAR(80) NOT NULL,
    salario              NUMERIC(12,2) NOT NULL DEFAULT 0,
    fecha_contratacion   DATE NOT NULL,
    id_departamento      BIGINT NOT NULL,
    CONSTRAINT rrhh_empleado_salario_chk CHECK (salario >= 0),
    CONSTRAINT rrhh_empleado_email_chk CHECK (email IS NULL OR position('@' in email) > 1),
    CONSTRAINT fk_rrhh_empleado_departamento
        FOREIGN KEY (id_departamento)
        REFERENCES oltp_rrhh.departamento (id_departamento)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_rrhh.contrato (
    id_contrato          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_contrato        VARCHAR(80) NOT NULL,
    fecha_inicio         DATE NOT NULL,
    fecha_fin            DATE,
    jornada              VARCHAR(50),
    salario_base         NUMERIC(12,2) NOT NULL DEFAULT 0,
    id_empleado          BIGINT NOT NULL,
    CONSTRAINT rrhh_contrato_salario_base_chk CHECK (salario_base >= 0),
    CONSTRAINT rrhh_contrato_fechas_chk CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT fk_rrhh_contrato_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES oltp_rrhh.empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_rrhh.nomina (
    id_nomina            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mes                  INTEGER NOT NULL,
    anio                 INTEGER NOT NULL,
    salario_base         NUMERIC(12,2) NOT NULL DEFAULT 0,
    complementos         NUMERIC(12,2) NOT NULL DEFAULT 0,
    deducciones          NUMERIC(12,2) NOT NULL DEFAULT 0,
    salario_neto         NUMERIC(12,2) NOT NULL DEFAULT 0,
    id_empleado          BIGINT NOT NULL,
    CONSTRAINT rrhh_nomina_mes_chk CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT rrhh_nomina_salario_base_chk CHECK (salario_base >= 0),
    CONSTRAINT rrhh_nomina_complementos_chk CHECK (complementos >= 0),
    CONSTRAINT rrhh_nomina_deducciones_chk CHECK (deducciones >= 0),
    CONSTRAINT rrhh_nomina_salario_neto_chk CHECK (salario_neto >= 0),
    CONSTRAINT fk_rrhh_nomina_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES oltp_rrhh.empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================================
-- OLTP_ADMINISTRACION
-- =========================================================
CREATE TABLE oltp_administracion.proveedor (
    id_proveedor         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(120) NOT NULL,
    cif                  VARCHAR(20) NOT NULL UNIQUE,
    telefono             VARCHAR(25),
    email                VARCHAR(150),
    pais                 VARCHAR(80),
    region               VARCHAR(80),
    provincia            VARCHAR(80),
    ciudad               VARCHAR(80),
    direccion            VARCHAR(200),
    CONSTRAINT admin_proveedor_email_chk CHECK (email IS NULL OR position('@' in email) > 1)
);

CREATE TABLE oltp_administracion.cliente (
    id_cliente           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni                  VARCHAR(20) NOT NULL UNIQUE,
    nombre               VARCHAR(80) NOT NULL,
    apellidos            VARCHAR(120) NOT NULL,
    email                VARCHAR(150),
    telefonocontacto     VARCHAR(25),
    pais                 VARCHAR(80),
    region               VARCHAR(80),
    provincia            VARCHAR(80),
    ciudad               VARCHAR(80),
    direccion            VARCHAR(200),
    CONSTRAINT admin_cliente_email_chk CHECK (email IS NULL OR position('@' in email) > 1)
);

CREATE TABLE oltp_administracion.empleado (
    id_empleado          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(80) NOT NULL,
    apellidos            VARCHAR(120) NOT NULL,
    dni                  VARCHAR(20) NOT NULL UNIQUE,
    telefono             VARCHAR(25),
    email                VARCHAR(150),
    puesto               VARCHAR(80) NOT NULL,
    salario              NUMERIC(12,2) NOT NULL DEFAULT 0,
    fecha_contratacion   DATE NOT NULL,
    CONSTRAINT admin_empleado_salario_chk CHECK (salario >= 0),
    CONSTRAINT admin_empleado_email_chk CHECK (email IS NULL OR position('@' in email) > 1)
);

CREATE TABLE oltp_administracion.vehiculo (
    id_vehiculo          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula            VARCHAR(20) NOT NULL UNIQUE,
    marca                VARCHAR(60) NOT NULL,
    modelo               VARCHAR(80) NOT NULL,
    anio                 INTEGER NOT NULL,
    num_bastidor         VARCHAR(50) NOT NULL UNIQUE,
    id_cliente           BIGINT NOT NULL,
    CONSTRAINT admin_vehiculo_anio_chk CHECK (anio BETWEEN 1900 AND 2100),
    CONSTRAINT fk_admin_vehiculo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES oltp_administracion.cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_administracion.servicio (
    id_servicio          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_apertura       TIMESTAMP NOT NULL,
    fecha_cierre         TIMESTAMP,
    tipo                 VARCHAR(80) NOT NULL,
    descripcion          TEXT,
    estado               VARCHAR(40) NOT NULL,
    kilometraje          INTEGER,
    coste                NUMERIC(12,2) NOT NULL DEFAULT 0,
    id_vehiculo          BIGINT NOT NULL,
    id_cliente           BIGINT NOT NULL,
    id_empleado          BIGINT NOT NULL,
    CONSTRAINT admin_servicio_coste_chk CHECK (coste >= 0),
    CONSTRAINT admin_servicio_kilometraje_chk CHECK (kilometraje IS NULL OR kilometraje >= 0),
    CONSTRAINT admin_servicio_fechas_chk CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura),
    CONSTRAINT fk_admin_servicio_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES oltp_administracion.vehiculo (id_vehiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_admin_servicio_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES oltp_administracion.cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_admin_servicio_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES oltp_administracion.empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_administracion.categoria_componente (
    id_categoria         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_categoria     VARCHAR(100) NOT NULL,
    descripcion          TEXT
);

CREATE TABLE oltp_administracion.orden_compra (
    id_orden_compra      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha                TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado               VARCHAR(40) NOT NULL,
    total                NUMERIC(12,2) NOT NULL DEFAULT 0,
    id_proveedor         BIGINT NOT NULL,
    CONSTRAINT admin_orden_compra_total_chk CHECK (total >= 0),
    CONSTRAINT fk_admin_orden_compra_proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES oltp_administracion.proveedor (id_proveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_administracion.componente (
    id_componente        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre               VARCHAR(120) NOT NULL,
    descripcion          TEXT,
    precio_venta         NUMERIC(12,2) NOT NULL DEFAULT 0,
    precio_compra        NUMERIC(12,2) NOT NULL DEFAULT 0,
    stock                INTEGER NOT NULL DEFAULT 0,
    stock_minimo         INTEGER NOT NULL DEFAULT 0,
    tipo_producto        VARCHAR(80),
    marca                VARCHAR(80),
    modelos_compatibles  TEXT,
    id_proveedor         BIGINT NOT NULL,
    id_categoria         BIGINT,
    CONSTRAINT admin_componente_precio_venta_chk CHECK (precio_venta >= 0),
    CONSTRAINT admin_componente_precio_compra_chk CHECK (precio_compra >= 0),
    CONSTRAINT admin_componente_stock_chk CHECK (stock >= 0),
    CONSTRAINT admin_componente_stock_minimo_chk CHECK (stock_minimo >= 0),
    CONSTRAINT fk_admin_componente_proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES oltp_administracion.proveedor (id_proveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_admin_componente_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES oltp_administracion.categoria_componente (id_categoria)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE oltp_administracion.detalle_orden_compra (
    id_detalle_compra    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad             INTEGER NOT NULL,
    precio_unitario      NUMERIC(12,2) NOT NULL,
    subtotal             NUMERIC(12,2) NOT NULL,
    id_orden_compra      BIGINT NOT NULL,
    id_componente        BIGINT NOT NULL,
    CONSTRAINT admin_detalle_orden_compra_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT admin_detalle_orden_compra_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT admin_detalle_orden_compra_subtotal_chk CHECK (subtotal >= 0),
    CONSTRAINT fk_admin_detalle_orden_compra_orden
        FOREIGN KEY (id_orden_compra)
        REFERENCES oltp_administracion.orden_compra (id_orden_compra)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_admin_detalle_orden_compra_componente
        FOREIGN KEY (id_componente)
        REFERENCES oltp_administracion.componente (id_componente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_admin_detalle_orden_compra UNIQUE (id_orden_compra, id_componente)
);

CREATE TABLE oltp_administracion.servicio_componente (
    id_servicio_componente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad               INTEGER NOT NULL,
    precio_unitario        NUMERIC(12,2) NOT NULL,
    id_servicio            BIGINT NOT NULL,
    id_componente          BIGINT NOT NULL,
    CONSTRAINT admin_servicio_componente_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT admin_servicio_componente_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT fk_admin_servicio_componente_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES oltp_administracion.servicio (id_servicio)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_admin_servicio_componente_componente
        FOREIGN KEY (id_componente)
        REFERENCES oltp_administracion.componente (id_componente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_admin_servicio_componente UNIQUE (id_servicio, id_componente)
);

CREATE TABLE oltp_administracion.pedido (
    id_pedido            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_pedido         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado               VARCHAR(40) NOT NULL,
    total                NUMERIC(12,2) NOT NULL DEFAULT 0,
    metodo_pago          VARCHAR(50),
    direccion_envio      VARCHAR(200),
    id_cliente           BIGINT NOT NULL,
    CONSTRAINT admin_pedido_total_chk CHECK (total >= 0),
    CONSTRAINT fk_admin_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES oltp_administracion.cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE oltp_administracion.detalle_pedido (
    id_detalle           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad             INTEGER NOT NULL,
    precio_unitario      NUMERIC(12,2) NOT NULL,
    subtotal             NUMERIC(12,2) NOT NULL,
    id_pedido            BIGINT NOT NULL,
    id_componente        BIGINT NOT NULL,
    CONSTRAINT admin_detalle_pedido_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT admin_detalle_pedido_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT admin_detalle_pedido_subtotal_chk CHECK (subtotal >= 0),
    CONSTRAINT fk_admin_detalle_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES oltp_administracion.pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_admin_detalle_pedido_componente
        FOREIGN KEY (id_componente)
        REFERENCES oltp_administracion.componente (id_componente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_admin_detalle_pedido UNIQUE (id_pedido, id_componente)
);

-- =========================================================
-- INDICES BASICOS
-- =========================================================
CREATE INDEX idx_ventas_pedido_cliente ON oltp_ventas.pedido (id_cliente);
CREATE INDEX idx_ventas_detalle_pedido_pedido ON oltp_ventas.detalle_pedido (id_pedido);
CREATE INDEX idx_ventas_detalle_pedido_componente ON oltp_ventas.detalle_pedido (id_componente);
CREATE INDEX idx_ventas_componente_categoria ON oltp_ventas.componente (id_categoria);

CREATE INDEX idx_marketing_pedido_cliente ON oltp_marketing.pedido (id_cliente);
CREATE INDEX idx_marketing_detalle_pedido_pedido ON oltp_marketing.detalle_pedido (id_pedido);
CREATE INDEX idx_marketing_detalle_pedido_componente ON oltp_marketing.detalle_pedido (id_componente);
CREATE INDEX idx_marketing_componente_categoria ON oltp_marketing.componente (id_categoria);

CREATE INDEX idx_tecnico_cita_vehiculo ON oltp_tecnico.cita (id_vehiculo);
CREATE INDEX idx_tecnico_servicio_vehiculo ON oltp_tecnico.servicio (id_vehiculo);
CREATE INDEX idx_tecnico_servicio_empleado ON oltp_tecnico.servicio (id_empleado);
CREATE INDEX idx_tecnico_servicio_componente_servicio ON oltp_tecnico.servicio_componente (id_servicio);
CREATE INDEX idx_tecnico_servicio_componente_componente ON oltp_tecnico.servicio_componente (id_componente);
CREATE INDEX idx_tecnico_componente_categoria ON oltp_tecnico.componente (id_categoria);

CREATE INDEX idx_rrhh_empleado_departamento ON oltp_rrhh.empleado (id_departamento);
CREATE INDEX idx_rrhh_contrato_empleado ON oltp_rrhh.contrato (id_empleado);
CREATE INDEX idx_rrhh_nomina_empleado ON oltp_rrhh.nomina (id_empleado);

CREATE INDEX idx_admin_vehiculo_cliente ON oltp_administracion.vehiculo (id_cliente);
CREATE INDEX idx_admin_servicio_vehiculo ON oltp_administracion.servicio (id_vehiculo);
CREATE INDEX idx_admin_servicio_cliente ON oltp_administracion.servicio (id_cliente);
CREATE INDEX idx_admin_servicio_empleado ON oltp_administracion.servicio (id_empleado);
CREATE INDEX idx_admin_orden_compra_proveedor ON oltp_administracion.orden_compra (id_proveedor);
CREATE INDEX idx_admin_componente_proveedor ON oltp_administracion.componente (id_proveedor);
CREATE INDEX idx_admin_componente_categoria ON oltp_administracion.componente (id_categoria);
CREATE INDEX idx_admin_detalle_orden_compra_orden ON oltp_administracion.detalle_orden_compra (id_orden_compra);
CREATE INDEX idx_admin_detalle_orden_compra_componente ON oltp_administracion.detalle_orden_compra (id_componente);
CREATE INDEX idx_admin_servicio_componente_servicio ON oltp_administracion.servicio_componente (id_servicio);
CREATE INDEX idx_admin_servicio_componente_componente ON oltp_administracion.servicio_componente (id_componente);
CREATE INDEX idx_admin_pedido_cliente ON oltp_administracion.pedido (id_cliente);
CREATE INDEX idx_admin_detalle_pedido_pedido ON oltp_administracion.detalle_pedido (id_pedido);
CREATE INDEX idx_admin_detalle_pedido_componente ON oltp_administracion.detalle_pedido (id_componente);

COMMIT;
