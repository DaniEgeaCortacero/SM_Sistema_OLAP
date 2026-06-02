/* Eliminación de indices y vistas en caso de implementación previa */

DROP INDEX IF EXISTS olap.idx_fact_ventas_cliente;
DROP INDEX IF EXISTS olap.idx_dim_cliente_ubicacion;

DROP INDEX IF EXISTS olap.idx_fact_ventas_componente;
DROP INDEX IF EXISTS olap.idx_dim_componente_tipo;
DROP INDEX IF EXISTS olap.idx_dim_componente_tipo_nombre;

DROP INDEX IF EXISTS olap.idx_fact_ventas_fecha;
DROP INDEX IF EXISTS olap.idx_dim_tiempo_fecha;

DROP INDEX IF EXISTS olap.idx_fact_servicios_servicio;
DROP INDEX IF EXISTS olap.idx_dim_servicio_tipo;

DROP MATERIALIZED VIEW IF EXISTS olap.mv_servicios_por_vehiculo;
DROP MATERIALIZED VIEW IF EXISTS olap.mv_personalizaciones_demandadas;
DROP MATERIALIZED VIEW IF EXISTS olap.mv_beneficios_mensuales_ventas;



CREATE INDEX idx_fact_ventas_cliente
ON olap.fact_ventas(id_cliente);

CREATE INDEX idx_dim_cliente_ubicacion
ON olap.dim_cliente(region, provincia, ciudad);


CREATE MATERIALIZED VIEW olap.mv_servicios_por_vehiculo AS
SELECT 
    dv.tipo_vehiculo,
    dv.marca,
    dv.modelo,
    dv.version,
    COUNT(*) AS total_servicios
FROM olap.fact_servicios fs
JOIN olap.dim_vehiculo dv
    ON fs.id_vehiculo = dv.id_vehiculo_dw
GROUP BY 
    dv.tipo_vehiculo,
    dv.marca,
    dv.modelo,
    dv.version;


CREATE INDEX idx_fact_ventas_componente
ON olap.fact_ventas(id_componente);

CREATE INDEX idx_dim_componente_tipo
ON olap.dim_componente(tipo_componente);

CREATE INDEX idx_dim_componente_tipo_nombre
ON olap.dim_componente(tipo_componente, nombre);


CREATE MATERIALIZED VIEW olap.mv_personalizaciones_demandadas AS
SELECT 
    dc.tipo_componente,
    dc.nombre,
    SUM(fv.unidades) AS total_demandado,
    SUM(fv.precio * fv.unidades) AS ingresos_totales,
    SUM(fv.beneficio) AS beneficio_total
FROM olap.fact_ventas fv
JOIN olap.dim_componente dc
    ON fv.id_componente = dc.id_componente_dw
WHERE dc.tipo_componente IN ('Cosmetico', 'Accesorio', 'Tuning')
GROUP BY 
    dc.tipo_componente,
    dc.nombre;


CREATE INDEX idx_fact_ventas_fecha
ON olap.fact_ventas(id_fecha);

CREATE INDEX idx_dim_tiempo_fecha
ON olap.dim_tiempo(id_fecha);


CREATE MATERIALIZED VIEW olap.mv_beneficios_mensuales_ventas AS
SELECT 
    df.anio,
    df.mes,
    SUM(fv.beneficio) AS beneficio_total
FROM olap.fact_ventas fv
JOIN olap.dim_tiempo df
    ON fv.id_fecha = df.id_fecha
GROUP BY 
    df.anio,
    df.mes;


CREATE INDEX idx_fact_servicios_servicio
ON olap.fact_servicios(id_servicio);

CREATE INDEX idx_dim_servicio_tipo
ON olap.dim_servicio(tipo);



-- REFRESH MATERIALIZED VIEW olap.mv_servicios_por_vehiculo;
-- REFRESH MATERIALIZED VIEW olap.mv_personalizaciones_demandadas;
-- REFRESH MATERIALIZED VIEW olap.mv_beneficios_mensuales_ventas;

