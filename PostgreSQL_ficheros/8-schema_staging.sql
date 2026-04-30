CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.ventas_clean;

CREATE TABLE staging.ventas_clean (
    id_venta        INT,
    fecha           DATE,
    id_fecha        BIGINT,
    id_cliente      BIGINT,
    id_componente   BIGINT,
    unidades        INT,
    precio          NUMERIC(12,2),
    coste           NUMERIC(12,2),
    beneficio       NUMERIC(12,2)
);

DROP TABLE IF EXISTS staging.log_fk_huerfanas;

CREATE TABLE staging.log_fk_huerfanas (
    id_venta        INT,
    fecha           DATE,
    id_cliente      BIGINT,
    id_producto     BIGINT,
    lkp_fecha       BIGINT,
    lkp_cliente     BIGINT,
    lkp_componente  BIGINT,
    motivo          VARCHAR(200)
);