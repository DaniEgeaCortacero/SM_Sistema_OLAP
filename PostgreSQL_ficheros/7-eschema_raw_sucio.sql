-- ==========================================================
-- SCHEMA RAW (datos sucios) - TorqueLab
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS raw;

DROP TABLE IF EXISTS raw.ventas_sucias;

CREATE TABLE raw.ventas_sucias (
    id_venta           INT,
    fecha              VARCHAR(50),
    id_cliente         INT,
    nombre             VARCHAR(100),
    apellido           VARCHAR(100),
    email              VARCHAR(150),
    ciudad             VARCHAR(100),
    id_producto        INT,
    producto           VARCHAR(100),
    categoria          VARCHAR(100),
    cantidad           INT,
    precio             VARCHAR(50),
    coste              VARCHAR(50)
);

-- ==========================================================
-- DATOS SUCIOS ADAPTADOS A LAS DIMENSIONES OLAP
-- id_cliente coincide con olap.dim_cliente.id_cliente_dw
-- id_producto coincide con olap.dim_componente.id_componente_dw
-- fecha coincide con olap.dim_tiempo.fecha
-- ==========================================================

INSERT INTO raw.ventas_sucias VALUES

-- ✔ datos correctos
(1, '2026-03-10 10:15:00', 2, 'Juan', 'Perez', 'juan@mail.com', 'Madrid', 1, 'Turbo Kit', 'Motor', 2, '37.80', '19.00'),
(2, '2026-03-12 12:00:00', 3, 'Ana', 'Lopez', 'ana@mail.com', 'Barcelona', 2, 'Escape', 'Motor', 1, '64.90', '34.00'),

-- ❌ email inválido, pero puede seguir cargando en fact si no filtras email
(3, '2026-03-15 09:30:00', 4, 'Luis', 'Garcia', 'luis_mail.com', 'Valencia', 3, 'Filtro', 'Mantenimiento', 1, '119.00', '71.00'),

-- ❌ fecha mal formateada, debe descartarse
(4, '15/03/2026', 5, 'Marta', 'Sanchez', 'marta@mail.com', 'Madrid', 4, 'Aceite', 'Mantenimiento', 1, '129.90', '82.00'),

-- ❌ ciudad inconsistente, debe limpiarse
(5, '2026-03-19 18:00:00', 6, 'Carlos', 'Ruiz', 'carlos@mail.com', 'madrid ', 5, 'Suspension', 'Chasis', 1, '599.00', '410.00'),

-- ❌ cantidad inválida, debe descartarse
(6, '2026-03-08 11:00:00', 7, 'Elena', 'Diaz', 'elena@mail.com', 'Bilbao', 6, 'Frenos', 'Freno', 0, '289.00', '190.00'),

-- ❌ duplicado exacto de la venta 1, debe eliminarse
(7, '2026-03-10 10:15:00', 2, 'Juan', 'Perez', 'juan@mail.com', 'Madrid', 1, 'Turbo Kit', 'Motor', 2, '37.80', '19.00'),

-- ❌ campos vacíos, debe descartarse
(8, NULL, NULL, '', '', NULL, '', NULL, '', '', NULL, NULL, NULL),

-- ❌ categoría inconsistente, debe descartarse si categoria = NULL
(9, '2026-03-13 16:00:00', 10, 'Pablo', 'Moreno', 'pablo@mail.com', 'Zaragoza', 9, 'Neumaticos', '???', 1, '49.90', '24.00'),

-- ❌ precio mal formado, debe descartarse
(10, '2026-03-17 10:00:00', 11, 'Laura', 'Fernandez', 'laura@mail.com', 'Sevilla', 10, 'Bateria', 'Motor', 1, 'abc', '51.00'),

-- ❌ coste nulo, debe descartarse
(11, '2026-03-04 09:00:00', 12, 'Diego', 'Martinez', 'diego@mail.com', 'Valencia', 11, 'Radiador', 'Motor', 1, '24.00', NULL),

-- ✔ más datos correctos
(12, '2026-03-06 14:30:00', 13, 'Sara', 'Gomez', 'sara@mail.com', 'Madrid', 12, 'Amortiguador', 'Chasis', 1, '68.00', '34.00'),
(13, '2026-03-10 17:45:00', 14, 'Jorge', 'Navarro', 'jorge@mail.com', 'Barcelona', 13, 'Filtro Aire', 'Mantenimiento', 1, '140.00', '84.00'),

-- ❌ espacios en strings, pero debería limpiarse y cargarse
(14, '2026-03-15 13:00:00', 15, '  Lucia ', '  Torres ', 'lucia@mail.com', ' Bilbao ', 14, ' Frenos ', 'freno', 1, '158.00', '79.00'),

-- ❌ mayúsculas/minúsculas inconsistentes, pero debería limpiarse y cargarse
(15, '2026-03-19 11:30:00', 16, 'Alberto', 'Vega', 'alberto@mail.com', 'MADRID', 15, 'Aceite', 'mantenimiento', 1, '820.00', '410.00'),

-- ❌ cantidad negativa, debe descartarse
(16, '2026-03-22 10:00:00', 14, 'Raul', 'Santos', 'raul@mail.com', 'Sevilla', 13, 'Turbo', 'Motor', -2, '200.00', '150.00');