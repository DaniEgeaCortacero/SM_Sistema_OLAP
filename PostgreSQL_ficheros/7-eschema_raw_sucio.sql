-- ==========================================================
-- SCHEMA RAW (datos sucios) - TorqueLab
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS raw;

-- ==========================================================
-- TABLA: ventas_sucias
-- Datos sin limpiar procedentes del OLTP o CSV
-- ==========================================================

CREATE TABLE IF NOT EXISTS raw.ventas_sucias (
    id_venta           INT,
    fecha              VARCHAR(50),      -- puede venir mal formateada
    id_cliente         INT,
    nombre             VARCHAR(100),
    apellido           VARCHAR(100),
    email              VARCHAR(150),
    ciudad             VARCHAR(100),
    id_producto        INT,
    producto           VARCHAR(100),
    categoria          VARCHAR(100),
    cantidad           INT
);

-- ==========================================================
-- INSERTS DE EJEMPLO (datos sucios)
-- ==========================================================

INSERT INTO raw.ventas_sucias VALUES
-- ✔ dato correcto
(1, '2024-01-10', 101, 'Juan', 'Perez', 'juan@mail.com', 'Madrid', 201, 'Turbo Kit', 'Motor', 2),

-- ❌ email inválido
(2, '2024-01-11', 102, 'Ana', 'Lopez', 'ana_mail.com', 'Barcelona', 202, 'Escape', 'Motor', 1),

-- ❌ fecha mal formateada
(3, '10/01/2024', 103, 'Luis', 'Garcia', 'luis@mail.com', 'Valencia', 203, 'Filtro', 'Mantenimiento', 3),

-- ❌ ciudad inconsistente
(4, '2024-01-12', 104, 'Marta', 'Sanchez', 'marta@mail.com', 'madrid ', 204, 'Aceite', 'mantenimiento', 1),

-- ❌ cantidad inválida
(5, '2024-01-13', 105, 'Carlos', 'Ruiz', 'carlos@mail.com', 'Sevilla', 205, 'Suspension', 'Chasis', 0),

-- ❌ duplicado
(6, '2024-01-10', 101, 'Juan', 'Perez', 'juan@mail.com', 'Madrid', 201, 'Turbo Kit', 'Motor', 2),

-- ❌ campos vacíos
(7, NULL, NULL, '', '', NULL, '', NULL, '', '', NULL),

-- ❌ categoría inconsistente
(8, '2024-01-14', 106, 'Elena', 'Diaz', 'elena@mail.com', 'Bilbao', 206, 'Frenos', 'freno', 1),

-- ❌ vocabulario incorrecto
(9, '2024-01-15', 107, 'Pablo', 'Moreno', 'pablo@mail.com', 'Zaragoza', 207, 'Neumáticos', '???', 4);