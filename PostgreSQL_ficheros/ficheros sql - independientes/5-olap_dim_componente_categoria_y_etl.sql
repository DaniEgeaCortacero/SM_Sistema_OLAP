BEGIN;

-- =========================================================
-- AJUSTE DEL MODELO OLAP (SNOWFLAKE PARCIAL)
-- Se añade:
--   1) olap.dim_categoria_componente
--   2) columna nombre en olap.dim_componente
--   3) columna id_categoria_dw en olap.dim_componente
--   4) FK dim_componente -> dim_categoria_componente
--   5) ETL de carga para ambas dimensiones
-- =========================================================

CREATE SCHEMA IF NOT EXISTS olap;

-- =========================================================
-- 1) CREAR DIMENSION DE CATEGORIA DE COMPONENTE
-- =========================================================
CREATE TABLE IF NOT EXISTS olap.dim_categoria_componente (
    id_categoria_dw      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_categoria_oltp    BIGINT,
    origen_sistema       VARCHAR(50) NOT NULL,
    nombre_categoria     VARCHAR(100) NOT NULL,
    descripcion          TEXT
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_categoria_componente_origen_oltp
    ON olap.dim_categoria_componente (origen_sistema, id_categoria_oltp);

CREATE INDEX IF NOT EXISTS idx_dim_categoria_componente_nombre
    ON olap.dim_categoria_componente (nombre_categoria);

-- =========================================================
-- 2) MODIFICAR DIM_COMPONENTE
-- dim_componente ya existía con:
--   id_componente_dw, id_componente_oltp, origen_sistema, marca, tipo_producto
-- Se añaden nombre e id_categoria_dw
-- =========================================================
ALTER TABLE olap.dim_componente
ADD COLUMN IF NOT EXISTS nombre VARCHAR(120);

ALTER TABLE olap.dim_componente
ADD COLUMN IF NOT EXISTS id_categoria_dw BIGINT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_dim_componente_categoria'
    ) THEN
        ALTER TABLE olap.dim_componente
        ADD CONSTRAINT fk_dim_componente_categoria
        FOREIGN KEY (id_categoria_dw)
        REFERENCES olap.dim_categoria_componente(id_categoria_dw)
        ON UPDATE CASCADE
        ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_dim_componente_nombre
    ON olap.dim_componente (nombre);

CREATE INDEX IF NOT EXISTS idx_dim_componente_categoria
    ON olap.dim_componente (id_categoria_dw);

-- =========================================================
-- 3) LIMPIEZA DE DIMENSIONES PARA RECARGA
-- =========================================================
TRUNCATE TABLE olap.dim_componente RESTART IDENTITY CASCADE;
TRUNCATE TABLE olap.dim_categoria_componente RESTART IDENTITY CASCADE;

-- =========================================================
-- 4) ETL - CARGA DE DIM_CATEGORIA_COMPONENTE
-- =========================================================
INSERT INTO olap.dim_categoria_componente (
    id_categoria_oltp,
    origen_sistema,
    nombre_categoria,
    descripcion
)
SELECT
    c.id_categoria,
    'oltp_ventas',
    c.nombre_categoria,
    c.descripcion
FROM oltp_ventas.categoria_componente c

UNION ALL

SELECT
    c.id_categoria,
    'oltp_marketing',
    c.nombre_categoria,
    c.descripcion
FROM oltp_marketing.categoria_componente c

UNION ALL

SELECT
    c.id_categoria,
    'oltp_tecnico',
    c.nombre_categoria,
    c.descripcion
FROM oltp_tecnico.categoria_componente c

UNION ALL

SELECT
    c.id_categoria,
    'oltp_administracion',
    c.nombre_categoria,
    c.descripcion
FROM oltp_administracion.categoria_componente c;

-- =========================================================
-- 5) ETL - CARGA DE DIM_COMPONENTE
-- =========================================================
INSERT INTO olap.dim_componente (
    id_componente_oltp,
    origen_sistema,
    nombre,
    marca,
    tipo_producto,
    id_categoria_dw
)
SELECT
    c.id_componente,
    'oltp_ventas',
    c.nombre,
    c.marca,
    c.tipo_producto,
    dc.id_categoria_dw
FROM oltp_ventas.componente c
LEFT JOIN olap.dim_categoria_componente dc
       ON dc.origen_sistema = 'oltp_ventas'
      AND dc.id_categoria_oltp = c.id_categoria

UNION ALL

SELECT
    c.id_componente,
    'oltp_marketing',
    c.nombre,
    c.marca,
    c.tipo_producto,
    dc.id_categoria_dw
FROM oltp_marketing.componente c
LEFT JOIN olap.dim_categoria_componente dc
       ON dc.origen_sistema = 'oltp_marketing'
      AND dc.id_categoria_oltp = c.id_categoria

UNION ALL

SELECT
    c.id_componente,
    'oltp_tecnico',
    c.nombre,
    c.marca,
    c.tipo_producto,
    dc.id_categoria_dw
FROM oltp_tecnico.componente c
LEFT JOIN olap.dim_categoria_componente dc
       ON dc.origen_sistema = 'oltp_tecnico'
      AND dc.id_categoria_oltp = c.id_categoria

UNION ALL

SELECT
    c.id_componente,
    'oltp_administracion',
    c.nombre,
    c.marca,
    c.tipo_producto,
    dc.id_categoria_dw
FROM oltp_administracion.componente c
LEFT JOIN olap.dim_categoria_componente dc
       ON dc.origen_sistema = 'oltp_administracion'
      AND dc.id_categoria_oltp = c.id_categoria;

COMMIT;