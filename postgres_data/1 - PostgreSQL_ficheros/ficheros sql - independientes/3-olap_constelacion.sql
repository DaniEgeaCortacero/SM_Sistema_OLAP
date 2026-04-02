BEGIN;

DROP SCHEMA IF EXISTS olap CASCADE;
CREATE SCHEMA olap;

-- =========================================================
-- MODELO OLAP EN CONSTELACION
-- Basado en los esquemas OLTP proporcionados y en el diagrama
-- de dimensiones y hechos compartidos.
-- =========================================================

-- =========================================================
-- DIMENSIONES
-- =========================================================

CREATE TABLE olap.dim_tiempo (
    id_fecha        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha           DATE NOT NULL UNIQUE,
    anio            INTEGER NOT NULL,
    trimestre       INTEGER NOT NULL,
    mes             INTEGER NOT NULL,
    dia             INTEGER NOT NULL,
    CONSTRAINT dim_tiempo_anio_chk CHECK (anio BETWEEN 1900 AND 2100),
    CONSTRAINT dim_tiempo_trimestre_chk CHECK (trimestre BETWEEN 1 AND 4),
    CONSTRAINT dim_tiempo_mes_chk CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT dim_tiempo_dia_chk CHECK (dia BETWEEN 1 AND 31)
);

CREATE TABLE olap.dim_cliente (
    id_cliente_dw    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente_oltp  BIGINT,
    origen_sistema   VARCHAR(50),
    region           VARCHAR(80),
    provincia        VARCHAR(80),
    ciudad           VARCHAR(80),
    nombre           VARCHAR(80) NOT NULL,
    apellidos        VARCHAR(120) NOT NULL
);

CREATE TABLE olap.dim_empleado (
    id_empleado_dw    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empleado_oltp  BIGINT,
    origen_sistema    VARCHAR(50),
    departamento      VARCHAR(100),
    cargo             VARCHAR(80),
    nombre_empleado   VARCHAR(200) NOT NULL
);

CREATE TABLE olap.dim_vehiculo (
    id_vehiculo_dw    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_vehiculo_oltp  BIGINT,
    origen_sistema    VARCHAR(50),
    tipo_vehiculo     VARCHAR(80),
    marca             VARCHAR(60) NOT NULL,
    modelo            VARCHAR(80) NOT NULL,
    version           VARCHAR(80)
);

CREATE TABLE olap.dim_servicio (
    id_servicio_dw    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_servicio_oltp  BIGINT,
    origen_sistema    VARCHAR(50),
    tipo              VARCHAR(80) NOT NULL,
    descripcion       TEXT
);

CREATE TABLE olap.dim_componente (
    id_componente_dw    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_componente_oltp  BIGINT,
    origen_sistema      VARCHAR(50),
    marca               VARCHAR(80),
    tipo_producto       VARCHAR(80)
);

-- =========================================================
-- HECHOS
-- =========================================================

CREATE TABLE olap.fact_ventas (
    id_fact_venta      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_fecha           BIGINT NOT NULL,
    id_cliente         BIGINT NOT NULL,
    id_componente      BIGINT NOT NULL,
    unidades           INTEGER NOT NULL,
    precio             NUMERIC(12,2) NOT NULL,
    coste              NUMERIC(12,2) NOT NULL,
    beneficio          NUMERIC(12,2) NOT NULL,
    CONSTRAINT fact_ventas_unidades_chk CHECK (unidades > 0),
    CONSTRAINT fact_ventas_precio_chk CHECK (precio >= 0),
    CONSTRAINT fact_ventas_coste_chk CHECK (coste >= 0),
    CONSTRAINT fact_ventas_beneficio_chk CHECK (beneficio >= -999999999.99),
    CONSTRAINT fk_fact_ventas_tiempo
        FOREIGN KEY (id_fecha)
        REFERENCES olap.dim_tiempo (id_fecha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_fact_ventas_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES olap.dim_cliente (id_cliente_dw)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_fact_ventas_componente
        FOREIGN KEY (id_componente)
        REFERENCES olap.dim_componente (id_componente_dw)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE olap.fact_servicios (
    id_fact_servicio   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_servicio        BIGINT NOT NULL,
    id_fecha           BIGINT NOT NULL,
    id_vehiculo        BIGINT NOT NULL,
    id_cliente         BIGINT NOT NULL,
    id_empleado        BIGINT NOT NULL,
    precio             NUMERIC(12,2) NOT NULL,
    coste              NUMERIC(12,2) NOT NULL,
    beneficio          NUMERIC(12,2) NOT NULL,
    estado             VARCHAR(40),
    duracion_horas     NUMERIC(10,2),
    CONSTRAINT fact_servicios_precio_chk CHECK (precio >= 0),
    CONSTRAINT fact_servicios_coste_chk CHECK (coste >= 0),
    CONSTRAINT fact_servicios_duracion_chk CHECK (duracion_horas IS NULL OR duracion_horas >= 0),
    CONSTRAINT fk_fact_servicios_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES olap.dim_servicio (id_servicio_dw)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_fact_servicios_tiempo
        FOREIGN KEY (id_fecha)
        REFERENCES olap.dim_tiempo (id_fecha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_fact_servicios_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES olap.dim_vehiculo (id_vehiculo_dw)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_fact_servicios_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES olap.dim_cliente (id_cliente_dw)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_fact_servicios_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES olap.dim_empleado (id_empleado_dw)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================================
-- INDICES BASICOS
-- =========================================================
CREATE INDEX idx_fact_ventas_fecha       ON olap.fact_ventas (id_fecha);
CREATE INDEX idx_fact_ventas_cliente     ON olap.fact_ventas (id_cliente);
CREATE INDEX idx_fact_ventas_componente  ON olap.fact_ventas (id_componente);

CREATE INDEX idx_fact_servicios_servicio ON olap.fact_servicios (id_servicio);
CREATE INDEX idx_fact_servicios_fecha    ON olap.fact_servicios (id_fecha);
CREATE INDEX idx_fact_servicios_vehiculo ON olap.fact_servicios (id_vehiculo);
CREATE INDEX idx_fact_servicios_cliente  ON olap.fact_servicios (id_cliente);
CREATE INDEX idx_fact_servicios_empleado ON olap.fact_servicios (id_empleado);

COMMIT;
