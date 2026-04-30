BEGIN;

-- =========================================================
-- ETL OLAP - MODELO CONSTELACION
-- Carga dimensiones y hechos desde los esquemas OLTP hacia OLAP.
-- Requiere que existan previamente:
--   - esquemas OLTP
--   - esquema OLAP creado con olap_constelacion.sql
-- =========================================================

-- =========================================================
-- LIMPIEZA DE DATOS OLAP
-- =========================================================
TRUNCATE TABLE
    olap.fact_ventas,
    olap.fact_servicios,
    olap.dim_tiempo,
    olap.dim_cliente,
    olap.dim_empleado,
    olap.dim_vehiculo,
    olap.dim_servicio,
    olap.dim_componente
RESTART IDENTITY CASCADE;

-- =========================================================
-- DIMENSION TIEMPO
-- =========================================================
INSERT INTO olap.dim_tiempo (fecha, anio, trimestre, mes, dia)
SELECT
    f.fecha,
    EXTRACT(YEAR FROM f.fecha)::INTEGER AS anio,
    EXTRACT(QUARTER FROM f.fecha)::INTEGER AS trimestre,
    EXTRACT(MONTH FROM f.fecha)::INTEGER AS mes,
    EXTRACT(DAY FROM f.fecha)::INTEGER AS dia
FROM (
    SELECT DISTINCT p.fecha_pedido::DATE AS fecha
    FROM oltp_ventas.pedido p

    UNION

    SELECT DISTINCT p.fecha_pedido::DATE AS fecha
    FROM oltp_marketing.pedido p

    UNION

    SELECT DISTINCT p.fecha_pedido::DATE AS fecha
    FROM oltp_administracion.pedido p

    UNION

    SELECT DISTINCT s.fecha_apertura::DATE AS fecha
    FROM oltp_tecnico.servicio s

    UNION

    SELECT DISTINCT s.fecha_apertura::DATE AS fecha
    FROM oltp_administracion.servicio s

    UNION

    SELECT DISTINCT c.fecha AS fecha
    FROM oltp_tecnico.cita c
) f
WHERE f.fecha IS NOT NULL
ORDER BY f.fecha;

-- =========================================================
-- DIMENSION CLIENTE
-- Se añade una fila "Sin cliente" para servicios técnicos sin cliente
-- explícito en el OLTP técnico.
-- =========================================================
INSERT INTO olap.dim_cliente (id_cliente_oltp, origen_sistema, region, provincia, ciudad, nombre, apellidos)
VALUES (NULL, 'desconocido', NULL, NULL, NULL, 'Sin cliente', 'No identificado');

INSERT INTO olap.dim_cliente (id_cliente_oltp, origen_sistema, region, provincia, ciudad, nombre, apellidos)
SELECT c.id_cliente, 'oltp_ventas', c.region, c.provincia, c.ciudad, c.nombre, c.apellidos
FROM oltp_ventas.cliente c;

INSERT INTO olap.dim_cliente (id_cliente_oltp, origen_sistema, region, provincia, ciudad, nombre, apellidos)
SELECT c.id_cliente, 'oltp_marketing', c.region, c.provincia, c.ciudad, c.nombre, c.apellidos
FROM oltp_marketing.cliente c;

INSERT INTO olap.dim_cliente (id_cliente_oltp, origen_sistema, region, provincia, ciudad, nombre, apellidos)
SELECT c.id_cliente, 'oltp_administracion', c.region, c.provincia, c.ciudad, c.nombre, c.apellidos
FROM oltp_administracion.cliente c;

-- =========================================================
-- DIMENSION EMPLEADO
-- =========================================================
INSERT INTO olap.dim_empleado (id_empleado_oltp, origen_sistema, departamento, cargo, nombre_empleado)
SELECT
    e.id_empleado,
    'oltp_tecnico',
    'Taller',
    e.puesto,
    CONCAT(e.nombre, ' ', e.apellidos)
FROM oltp_tecnico.empleado e;

INSERT INTO olap.dim_empleado (id_empleado_oltp, origen_sistema, departamento, cargo, nombre_empleado)
SELECT
    e.id_empleado,
    'oltp_administracion',
    'Administracion',
    e.puesto,
    CONCAT(e.nombre, ' ', e.apellidos)
FROM oltp_administracion.empleado e;

INSERT INTO olap.dim_empleado (id_empleado_oltp, origen_sistema, departamento, cargo, nombre_empleado)
SELECT
    e.id_empleado,
    'oltp_rrhh',
    d.nombre,
    e.puesto,
    CONCAT(e.nombre, ' ', e.apellidos)
FROM oltp_rrhh.empleado e
JOIN oltp_rrhh.departamento d
    ON d.id_departamento = e.id_departamento;

-- =========================================================
-- DIMENSION VEHICULO
-- tipo_vehiculo y version se dejan a NULL porque no aparecen de forma
-- explícita en las tablas OLTP proporcionadas.
-- =========================================================
INSERT INTO olap.dim_vehiculo (id_vehiculo_oltp, origen_sistema, tipo_vehiculo, marca, modelo, version)
SELECT
    v.id_vehiculo,
    'oltp_tecnico',
    NULL,
    v.marca,
    v.modelo,
    NULL
FROM oltp_tecnico.vehiculo v;

INSERT INTO olap.dim_vehiculo (id_vehiculo_oltp, origen_sistema, tipo_vehiculo, marca, modelo, version)
SELECT
    v.id_vehiculo,
    'oltp_administracion',
    NULL,
    v.marca,
    v.modelo,
    NULL
FROM oltp_administracion.vehiculo v;

-- =========================================================
-- DIMENSION SERVICIO
-- =========================================================
INSERT INTO olap.dim_servicio (id_servicio_oltp, origen_sistema, tipo, descripcion)
SELECT s.id_servicio, 'oltp_tecnico', s.tipo, s.descripcion
FROM oltp_tecnico.servicio s;

INSERT INTO olap.dim_servicio (id_servicio_oltp, origen_sistema, tipo, descripcion)
SELECT s.id_servicio, 'oltp_administracion', s.tipo, s.descripcion
FROM oltp_administracion.servicio s;

-- =========================================================
-- DIMENSION COMPONENTE
-- En el diagrama solo se guardan marca y tipo_producto.
-- =========================================================
INSERT INTO olap.dim_componente (id_componente_oltp, origen_sistema, marca, tipo_producto)
SELECT c.id_componente, 'oltp_ventas', c.marca, c.tipo_producto
FROM oltp_ventas.componente c;

INSERT INTO olap.dim_componente (id_componente_oltp, origen_sistema, marca, tipo_producto)
SELECT c.id_componente, 'oltp_marketing', c.marca, c.tipo_producto
FROM oltp_marketing.componente c;

INSERT INTO olap.dim_componente (id_componente_oltp, origen_sistema, marca, tipo_producto)
SELECT c.id_componente, 'oltp_administracion', c.marca, c.tipo_producto
FROM oltp_administracion.componente c;

-- =========================================================
-- HECHO: FACT_VENTAS
-- precio     = subtotal de la línea
-- coste      = cantidad * precio_compra del componente
-- beneficio  = subtotal - coste
-- =========================================================
INSERT INTO olap.fact_ventas (id_fecha, id_cliente, id_componente, unidades, precio, coste, beneficio)
SELECT
    dt.id_fecha,
    dc.id_cliente_dw,
    dco.id_componente_dw,
    dp.cantidad,
    dp.subtotal AS precio,
    (dp.cantidad * c.precio_compra) AS coste,
    (dp.subtotal - (dp.cantidad * c.precio_compra)) AS beneficio
FROM oltp_ventas.detalle_pedido dp
JOIN oltp_ventas.pedido p
    ON p.id_pedido = dp.id_pedido
JOIN oltp_ventas.componente c
    ON c.id_componente = dp.id_componente
JOIN olap.dim_tiempo dt
    ON dt.fecha = p.fecha_pedido::DATE
JOIN olap.dim_cliente dc
    ON dc.id_cliente_oltp = p.id_cliente
   AND dc.origen_sistema = 'oltp_ventas'
JOIN olap.dim_componente dco
    ON dco.id_componente_oltp = c.id_componente
   AND dco.origen_sistema = 'oltp_ventas';

INSERT INTO olap.fact_ventas (id_fecha, id_cliente, id_componente, unidades, precio, coste, beneficio)
SELECT
    dt.id_fecha,
    dc.id_cliente_dw,
    dco.id_componente_dw,
    dp.cantidad,
    dp.subtotal AS precio,
    (dp.cantidad * c.precio_compra) AS coste,
    (dp.subtotal - (dp.cantidad * c.precio_compra)) AS beneficio
FROM oltp_marketing.detalle_pedido dp
JOIN oltp_marketing.pedido p
    ON p.id_pedido = dp.id_pedido
JOIN oltp_marketing.componente c
    ON c.id_componente = dp.id_componente
JOIN olap.dim_tiempo dt
    ON dt.fecha = p.fecha_pedido::DATE
JOIN olap.dim_cliente dc
    ON dc.id_cliente_oltp = p.id_cliente
   AND dc.origen_sistema = 'oltp_marketing'
JOIN olap.dim_componente dco
    ON dco.id_componente_oltp = c.id_componente
   AND dco.origen_sistema = 'oltp_marketing';

INSERT INTO olap.fact_ventas (id_fecha, id_cliente, id_componente, unidades, precio, coste, beneficio)
SELECT
    dt.id_fecha,
    dc.id_cliente_dw,
    dco.id_componente_dw,
    dp.cantidad,
    dp.subtotal AS precio,
    (dp.cantidad * c.precio_compra) AS coste,
    (dp.subtotal - (dp.cantidad * c.precio_compra)) AS beneficio
FROM oltp_administracion.detalle_pedido dp
JOIN oltp_administracion.pedido p
    ON p.id_pedido = dp.id_pedido
JOIN oltp_administracion.componente c
    ON c.id_componente = dp.id_componente
JOIN olap.dim_tiempo dt
    ON dt.fecha = p.fecha_pedido::DATE
JOIN olap.dim_cliente dc
    ON dc.id_cliente_oltp = p.id_cliente
   AND dc.origen_sistema = 'oltp_administracion'
JOIN olap.dim_componente dco
    ON dco.id_componente_oltp = c.id_componente
   AND dco.origen_sistema = 'oltp_administracion';

-- =========================================================
-- HECHO: FACT_SERVICIOS
-- precio         = importe cobrado al cliente (campo coste del OLTP)
-- coste          = coste interno estimado de componentes utilizados
-- beneficio      = precio - coste
-- duracion_horas = diferencia entre fecha_cierre y fecha_apertura
-- Para servicios de oltp_tecnico, el cliente se carga como "Sin cliente"
-- porque no existe relación explícita con cliente en ese esquema.
-- =========================================================
INSERT INTO olap.fact_servicios (
    id_servicio,
    id_fecha,
    id_vehiculo,
    id_cliente,
    id_empleado,
    precio,
    coste,
    beneficio,
    estado,
    duracion_horas
)
SELECT
    ds.id_servicio_dw,
    dt.id_fecha,
    dv.id_vehiculo_dw,
    dc.id_cliente_dw,
    de.id_empleado_dw,
    s.coste AS precio,
    COALESCE(comp.coste_componentes, 0) AS coste,
    s.coste - COALESCE(comp.coste_componentes, 0) AS beneficio,
    s.estado,
    CASE
        WHEN s.fecha_cierre IS NOT NULL
        THEN ROUND((EXTRACT(EPOCH FROM (s.fecha_cierre - s.fecha_apertura)) / 3600.0)::NUMERIC, 2)
        ELSE NULL
    END AS duracion_horas
FROM oltp_tecnico.servicio s
JOIN olap.dim_servicio ds
    ON ds.id_servicio_oltp = s.id_servicio
   AND ds.origen_sistema = 'oltp_tecnico'
JOIN olap.dim_tiempo dt
    ON dt.fecha = s.fecha_apertura::DATE
JOIN olap.dim_vehiculo dv
    ON dv.id_vehiculo_oltp = s.id_vehiculo
   AND dv.origen_sistema = 'oltp_tecnico'
JOIN olap.dim_cliente dc
    ON dc.origen_sistema = 'desconocido'
   AND dc.id_cliente_oltp IS NULL
JOIN olap.dim_empleado de
    ON de.id_empleado_oltp = s.id_empleado
   AND de.origen_sistema = 'oltp_tecnico'
LEFT JOIN (
    SELECT
        sc.id_servicio,
        SUM(sc.cantidad * c.precio_compra) AS coste_componentes
    FROM oltp_tecnico.servicio_componente sc
    JOIN oltp_tecnico.componente c
        ON c.id_componente = sc.id_componente
    GROUP BY sc.id_servicio
) comp
    ON comp.id_servicio = s.id_servicio;

INSERT INTO olap.fact_servicios (
    id_servicio,
    id_fecha,
    id_vehiculo,
    id_cliente,
    id_empleado,
    precio,
    coste,
    beneficio,
    estado,
    duracion_horas
)
SELECT
    ds.id_servicio_dw,
    dt.id_fecha,
    dv.id_vehiculo_dw,
    dc.id_cliente_dw,
    de.id_empleado_dw,
    s.coste AS precio,
    COALESCE(comp.coste_componentes, 0) AS coste,
    s.coste - COALESCE(comp.coste_componentes, 0) AS beneficio,
    s.estado,
    CASE
        WHEN s.fecha_cierre IS NOT NULL
        THEN ROUND((EXTRACT(EPOCH FROM (s.fecha_cierre - s.fecha_apertura)) / 3600.0)::NUMERIC, 2)
        ELSE NULL
    END AS duracion_horas
FROM oltp_administracion.servicio s
JOIN olap.dim_servicio ds
    ON ds.id_servicio_oltp = s.id_servicio
   AND ds.origen_sistema = 'oltp_administracion'
JOIN olap.dim_tiempo dt
    ON dt.fecha = s.fecha_apertura::DATE
JOIN olap.dim_vehiculo dv
    ON dv.id_vehiculo_oltp = s.id_vehiculo
   AND dv.origen_sistema = 'oltp_administracion'
JOIN olap.dim_cliente dc
    ON dc.id_cliente_oltp = s.id_cliente
   AND dc.origen_sistema = 'oltp_administracion'
JOIN olap.dim_empleado de
    ON de.id_empleado_oltp = s.id_empleado
   AND de.origen_sistema = 'oltp_administracion'
LEFT JOIN (
    SELECT
        sc.id_servicio,
        SUM(sc.cantidad * c.precio_compra) AS coste_componentes
    FROM oltp_administracion.servicio_componente sc
    JOIN oltp_administracion.componente c
        ON c.id_componente = sc.id_componente
    GROUP BY sc.id_servicio
) comp
    ON comp.id_servicio = s.id_servicio;

COMMIT;
