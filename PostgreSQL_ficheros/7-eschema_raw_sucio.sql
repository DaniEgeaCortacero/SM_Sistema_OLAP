-- ==========================================================
-- SCHEMA RAW (datos sucios) - TorqueLab
-- Nuevos datos, distintos a los ya cargados en fact_ventas
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

INSERT INTO raw.ventas_sucias VALUES

-- ==========================================================
-- DATOS CORRECTOS NUEVOS
-- ==========================================================

(101, '2026-03-05 09:15:00', 2,  'Juan',    'Perez',     'juan@mail.com',      'Madrid',    2,  'Escape',        'Motor',         1, '64.90',  '34.00'),
(102, '2026-03-07 11:20:00', 3,  'Ana',     'Lopez',     'ana@mail.com',       'Barcelona', 3,  'Filtro',        'Mantenimiento', 1, '119.00', '71.00'),
(103, '2026-03-08 16:45:00', 4,  'Luis',    'Garcia',    'luis@mail.com',      'Valencia',  4,  'Aceite',        'Mantenimiento', 1, '129.90', '82.00'),
(104, '2026-03-09 10:30:00', 5,  'Marta',   'Sanchez',   'marta@mail.com',     'Madrid',    5,  'Suspension',    'Chasis',        1, '599.00', '410.00'),
(105, '2026-03-10 18:10:00', 6,  'Carlos',  'Ruiz',      'carlos@mail.com',    'Madrid',    6,  'Frenos',        'Freno',         1, '289.00', '190.00'),

(106, '2026-03-11 12:00:00', 7,  'Elena',   'Diaz',      'elena@mail.com',     'Bilbao',    7,  'Pastillas',     'Frenos',        1, '199.00', '132.00'),
(107, '2026-03-12 13:25:00', 8,  'Mario',   'Ortega',    'mario@mail.com',     'Sevilla',   8,  'Discos Freno',  'Freno',         1, '245.00', '160.00'),
(108, '2026-03-13 17:40:00', 9,  'Nuria',   'Castro',    'nuria@mail.com',     'Valencia',  9,  'Neumaticos',    'Chasis',        1, '49.90',  '24.00'),
(109, '2026-03-14 09:50:00', 10, 'Pablo',   'Moreno',    'pablo@mail.com',     'Zaragoza',  10, 'Bateria',       'Motor',         1, '89.90',  '51.00'),
(110, '2026-03-15 15:10:00', 11, 'Laura',   'Fernandez', 'laura@mail.com',     'Sevilla',   11, 'Radiador',      'Motor',         1, '24.00',  '12.00'),

(111, '2026-03-16 10:35:00', 12, 'Diego',   'Martinez',  'diego@mail.com',     'Valencia',  12, 'Amortiguador',  'Chasis',        1, '68.00',  '34.00'),
(112, '2026-03-17 14:00:00', 13, 'Sara',    'Gomez',     'sara@mail.com',      'Madrid',    13, 'Filtro Aire',   'Mantenimiento', 1, '140.00', '84.00'),
(113, '2026-03-18 19:20:00', 14, 'Jorge',   'Navarro',   'jorge@mail.com',     'Barcelona', 14, 'Frenos',        'Freno',         1, '158.00', '79.00'),
(114, '2026-03-19 11:10:00', 15, 'Lucia',   'Torres',    'lucia@mail.com',     'Bilbao',    15, 'Aceite',        'Mantenimiento', 1, '820.00', '410.00'),
(115, '2026-03-20 16:30:00', 16, 'Alberto', 'Vega',      'alberto@mail.com',   'Madrid',    1,  'Turbo Kit',     'Motor',         1, '37.80',  '19.00'),

(116, '2026-03-21 10:10:00', 2,  'Juan',    'Perez',     'juan@mail.com',      'Madrid',    5,  'Suspension',    'Chasis',        1, '599.00', '410.00'),
(117, '2026-03-22 12:45:00', 3,  'Ana',     'Lopez',     'ana@mail.com',       'Barcelona', 6,  'Frenos',        'Frenos',        1, '289.00', '190.00'),
(118, '2026-03-05 17:15:00', 4,  'Luis',    'Garcia',    'luis@mail.com',      'Valencia',  7,  'Pastillas',     'Freno',         1, '199.00', '132.00'),
(119, '2026-03-07 19:30:00', 5,  'Marta',   'Sanchez',   'marta@mail.com',     'Madrid',    8,  'Discos Freno',  'Freno',         1, '245.00', '160.00'),
(120, '2026-03-08 08:40:00', 6,  'Carlos',  'Ruiz',      'carlos@mail.com',    'Madrid',    9,  'Neumaticos',    'Chasis',        1, '49.90',  '24.00'),

-- ==========================================================
-- CASOS SUCIOS PARA PROBAR EL ETL
-- ==========================================================

-- fecha mal formateada: descartar
(121, '21/03/2026', 7, 'Elena', 'Diaz', 'elena@mail.com', 'Bilbao', 10, 'Bateria', 'Motor', 1, '89.90', '51.00'),

-- cantidad 0: descartar
(122, '2026-03-12 12:00:00', 8, 'Mario', 'Ortega', 'mario@mail.com', 'Sevilla', 11, 'Radiador', 'Motor', 0, '24.00', '12.00'),

-- campos vacíos: descartar
(123, NULL, NULL, '', '', NULL, '', NULL, '', '', NULL, NULL, NULL),

-- categoría desconocida: descartar si en JS pones categoria = null
(124, '2026-03-14 13:00:00', 9, 'Nuria', 'Castro', 'nuria@mail.com', 'Valencia', 12, 'Amortiguador', '???', 1, '68.00', '34.00'),

-- precio mal formado: descartar
(125, '2026-03-16 09:00:00', 10, 'Pablo', 'Moreno', 'pablo@mail.com', 'Zaragoza', 13, 'Filtro Aire', 'Mantenimiento', 1, 'abc', '84.00'),

-- coste nulo: descartar
(126, '2026-03-18 18:00:00', 11, 'Laura', 'Fernandez', 'laura@mail.com', 'Sevilla', 14, 'Frenos', 'Freno', 1, '158.00', NULL),

-- duplicado exacto de la 101: se elimina si deduplicas por contenido
(127, '2026-03-05 09:15:00', 2, 'Juan', 'Perez', 'juan@mail.com', 'Madrid', 2, 'Escape', 'Motor', 1, '64.90', '34.00'),

-- FK cliente inexistente: log huérfanas
(128, '2026-03-20 10:00:00', 99, 'Cliente', 'Fantasma', 'fantasma@mail.com', 'Madrid', 1, 'Turbo Kit', 'Motor', 1, '37.80', '19.00'),

-- FK componente inexistente: log huérfanas
(129, '2026-03-20 10:00:00', 16, 'Alberto', 'Vega', 'alberto@mail.com', 'Madrid', 99, 'Producto Fantasma', 'Motor', 1, '100.00', '70.00'),

-- fecha inexistente si dim_tiempo no tiene 2026-04-01: log huérfanas
(130, '2026-04-01 10:00:00', 3, 'Ana', 'Lopez', 'ana@mail.com', 'Barcelona', 2, 'Escape', 'Motor', 1, '64.90', '34.00');