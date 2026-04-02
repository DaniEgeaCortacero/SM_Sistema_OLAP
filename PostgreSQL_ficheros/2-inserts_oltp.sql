BEGIN;

-- =========================================================
-- INSERTS OLTP_VENTAS
-- =========================================================
INSERT INTO oltp_ventas.cliente (dni, nombre, apellidos, email, telefono, pais, region, provincia, ciudad, direccion) VALUES
('12345678A', 'Carlos', 'Ruiz Gómez', 'carlos.ruiz@gmail.com', '600123111', 'España', 'Andalucía', 'Sevilla', 'Sevilla', 'Calle San Jacinto 14'),
('23456789B', 'Lucía', 'Martín Pérez', 'lucia.martin@gmail.com', '600123222', 'España', 'Madrid', 'Madrid', 'Madrid', 'Avenida de América 52'),
('34567890C', 'Javier', 'López Sánchez', 'javier.lopez@gmail.com', '600123333', 'España', 'Comunidad Valenciana', 'Valencia', 'Valencia', 'Calle Colón 8'),
('45678901D', 'Marta', 'Fernández Díaz', 'marta.fernandez@gmail.com', '600123444', 'España', 'Cataluña', 'Barcelona', 'Barcelona', 'Passeig de Gràcia 101'),
('56789012E', 'Álvaro', 'Navarro Torres', 'alvaro.navarro@gmail.com', '600123555', 'España', 'País Vasco', 'Vizcaya', 'Bilbao', 'Gran Vía 23');

INSERT INTO oltp_ventas.categoria_componente (nombre_categoria, descripcion) VALUES
('Motor', 'Piezas relacionadas con el sistema de motor y admisión'),
('Frenos', 'Componentes del sistema de frenado'),
('Suspensión', 'Piezas de suspensión y amortiguación'),
('Electrónica', 'Sensores, baterías y componentes electrónicos'),
('Escape', 'Sistemas de escape y accesorios deportivos');

INSERT INTO oltp_ventas.componente (nombre, descripcion, precio_venta, precio_compra, stock, stock_minimo, tipo_producto, marca, modelos_compatibles, id_categoria) VALUES
('Filtro de aceite Bosch P3254', 'Filtro de aceite para mantenimiento periódico', 18.90, 9.50, 45, 8, 'Recambio', 'Bosch', 'Seat León, VW Golf, Audi A3',
    (SELECT id_categoria FROM oltp_ventas.categoria_componente WHERE nombre_categoria = 'Motor')),
('Pastillas de freno delanteras Valeo 598764', 'Juego de pastillas delanteras de alto rendimiento', 64.90, 34.00, 30, 6, 'Recambio', 'Valeo', 'Renault Clio, Megane, Captur',
    (SELECT id_categoria FROM oltp_ventas.categoria_componente WHERE nombre_categoria = 'Frenos')),
('Amortiguador trasero Monroe OESpectrum', 'Amortiguador de gas para eje trasero', 119.00, 71.00, 18, 4, 'Recambio', 'Monroe', 'Ford Focus, Ford Mondeo',
    (SELECT id_categoria FROM oltp_ventas.categoria_componente WHERE nombre_categoria = 'Suspensión')),
('Batería Varta Blue Dynamic 74Ah', 'Batería de arranque 12V 74Ah', 129.90, 82.00, 12, 3, 'Recambio', 'Varta', 'BMW Serie 3, Audi A4, Mercedes Clase C',
    (SELECT id_categoria FROM oltp_ventas.categoria_componente WHERE nombre_categoria = 'Electrónica')),
('Escape deportivo Akrapovic Slip-On', 'Escape deportivo homologado de acero inoxidable', 599.00, 410.00, 6, 1, 'Tuning', 'Akrapovic', 'BMW M2, Toyota GR86, VW Golf GTI',
    (SELECT id_categoria FROM oltp_ventas.categoria_componente WHERE nombre_categoria = 'Escape'));

INSERT INTO oltp_ventas.pedido (fecha_pedido, estado, total, metodo_pago, direccion_envio, id_cliente) VALUES
('2026-03-10 10:15:00', 'Entregado', 37.80, 'Tarjeta', 'Calle San Jacinto 14, Sevilla',
    (SELECT id_cliente FROM oltp_ventas.cliente WHERE dni = '12345678A')),
('2026-03-12 12:40:00', 'Enviado', 64.90, 'PayPal', 'Avenida de América 52, Madrid',
    (SELECT id_cliente FROM oltp_ventas.cliente WHERE dni = '23456789B')),
('2026-03-15 16:20:00', 'Preparación', 119.00, 'Transferencia', 'Calle Colón 8, Valencia',
    (SELECT id_cliente FROM oltp_ventas.cliente WHERE dni = '34567890C')),
('2026-03-18 09:10:00', 'Entregado', 129.90, 'Tarjeta', 'Passeig de Gràcia 101, Barcelona',
    (SELECT id_cliente FROM oltp_ventas.cliente WHERE dni = '45678901D')),
('2026-03-20 18:05:00', 'Enviado', 599.00, 'Financiación', 'Gran Vía 23, Bilbao',
    (SELECT id_cliente FROM oltp_ventas.cliente WHERE dni = '56789012E'));

INSERT INTO oltp_ventas.detalle_pedido (cantidad, precio_unitario, subtotal, id_pedido, id_componente) VALUES
(2, 18.90, 37.80,
    (SELECT id_pedido FROM oltp_ventas.pedido WHERE fecha_pedido = '2026-03-10 10:15:00'),
    (SELECT id_componente FROM oltp_ventas.componente WHERE nombre = 'Filtro de aceite Bosch P3254')),
(1, 64.90, 64.90,
    (SELECT id_pedido FROM oltp_ventas.pedido WHERE fecha_pedido = '2026-03-12 12:40:00'),
    (SELECT id_componente FROM oltp_ventas.componente WHERE nombre = 'Pastillas de freno delanteras Valeo 598764')),
(1, 119.00, 119.00,
    (SELECT id_pedido FROM oltp_ventas.pedido WHERE fecha_pedido = '2026-03-15 16:20:00'),
    (SELECT id_componente FROM oltp_ventas.componente WHERE nombre = 'Amortiguador trasero Monroe OESpectrum')),
(1, 129.90, 129.90,
    (SELECT id_pedido FROM oltp_ventas.pedido WHERE fecha_pedido = '2026-03-18 09:10:00'),
    (SELECT id_componente FROM oltp_ventas.componente WHERE nombre = 'Batería Varta Blue Dynamic 74Ah')),
(1, 599.00, 599.00,
    (SELECT id_pedido FROM oltp_ventas.pedido WHERE fecha_pedido = '2026-03-20 18:05:00'),
    (SELECT id_componente FROM oltp_ventas.componente WHERE nombre = 'Escape deportivo Akrapovic Slip-On'));

-- =========================================================
-- INSERTS OLTP_MARKETING
-- =========================================================
INSERT INTO oltp_marketing.cliente (dni, nombre, apellidos, email, telefono, pais, region, provincia, ciudad, direccion) VALUES
('67890123F', 'Sergio', 'Morales Cano', 'sergio.morales@gmail.com', '611200111', 'España', 'Andalucía', 'Málaga', 'Málaga', 'Calle Larios 22'),
('78901234G', 'Elena', 'Prieto Ramos', 'elena.prieto@gmail.com', '611200222', 'España', 'Galicia', 'A Coruña', 'A Coruña', 'Rúa Real 15'),
('89012345H', 'Pablo', 'Castro Gil', 'pablo.castro@gmail.com', '611200333', 'España', 'Aragón', 'Zaragoza', 'Zaragoza', 'Paseo Independencia 44'),
('90123456I', 'Nuria', 'Ortega León', 'nuria.ortega@gmail.com', '611200444', 'España', 'Murcia', 'Murcia', 'Murcia', 'Gran Vía Escultor Salzillo 7'),
('01234567J', 'Diego', 'Santos Vega', 'diego.santos@gmail.com', '611200555', 'España', 'Castilla y León', 'Valladolid', 'Valladolid', 'Calle Santiago 31');

INSERT INTO oltp_marketing.categoria_componente (nombre_categoria, descripcion) VALUES
('Motor', 'Productos destacados del área de motor'),
('Frenos', 'Campañas sobre seguridad y frenado'),
('Suspensión', 'Promociones de confort y estabilidad'),
('Electrónica', 'Productos tecnológicos y eléctricos'),
('Escape', 'Accesorios de alto rendimiento');

INSERT INTO oltp_marketing.componente (nombre, descripcion, precio_venta, precio_compra, stock, stock_minimo, tipo_producto, marca, modelos_compatibles, id_categoria) VALUES
('Kit de admisión K&N 57S', 'Kit de admisión directa para mejora de respuesta', 289.00, 190.00, 10, 2, 'Tuning', 'K&N', 'VW Golf GTI, Seat León Cupra',
    (SELECT id_categoria FROM oltp_marketing.categoria_componente WHERE nombre_categoria = 'Motor')),
('Discos de freno Brembo Max', 'Discos ventilados para conducción deportiva', 199.00, 132.00, 16, 4, 'Recambio', 'Brembo', 'Audi A4, A5, VW Passat',
    (SELECT id_categoria FROM oltp_marketing.categoria_componente WHERE nombre_categoria = 'Frenos')),
('Muelles deportivos Eibach Pro-Kit', 'Muelles de rebaje para mejor estabilidad', 245.00, 160.00, 9, 2, 'Tuning', 'Eibach', 'BMW Serie 1, Serie 3',
    (SELECT id_categoria FROM oltp_marketing.categoria_componente WHERE nombre_categoria = 'Suspensión')),
('Sensor de aparcamiento Bosch', 'Sensor ultrasónico de asistencia al aparcamiento', 49.90, 24.00, 35, 5, 'Accesorio', 'Bosch', 'Universal',
    (SELECT id_categoria FROM oltp_marketing.categoria_componente WHERE nombre_categoria = 'Electrónica')),
('Cola de escape decorativa Remus', 'Embellecedor de escape en acero inoxidable', 89.90, 51.00, 20, 3, 'Accesorio', 'Remus', 'Universal',
    (SELECT id_categoria FROM oltp_marketing.categoria_componente WHERE nombre_categoria = 'Escape'));

INSERT INTO oltp_marketing.pedido (fecha_pedido, estado, total, metodo_pago, direccion_envio, id_cliente) VALUES
('2026-03-08 11:30:00', 'Entregado', 289.00, 'Tarjeta', 'Calle Larios 22, Málaga',
    (SELECT id_cliente FROM oltp_marketing.cliente WHERE dni = '67890123F')),
('2026-03-11 13:50:00', 'Entregado', 199.00, 'Tarjeta', 'Rúa Real 15, A Coruña',
    (SELECT id_cliente FROM oltp_marketing.cliente WHERE dni = '78901234G')),
('2026-03-14 17:10:00', 'Enviado', 245.00, 'PayPal', 'Paseo Independencia 44, Zaragoza',
    (SELECT id_cliente FROM oltp_marketing.cliente WHERE dni = '89012345H')),
('2026-03-17 10:00:00', 'Preparación', 49.90, 'Transferencia', 'Gran Vía Escultor Salzillo 7, Murcia',
    (SELECT id_cliente FROM oltp_marketing.cliente WHERE dni = '90123456I')),
('2026-03-21 19:25:00', 'Enviado', 89.90, 'Tarjeta', 'Calle Santiago 31, Valladolid',
    (SELECT id_cliente FROM oltp_marketing.cliente WHERE dni = '01234567J'));

INSERT INTO oltp_marketing.detalle_pedido (cantidad, precio_unitario, subtotal, id_pedido, id_componente) VALUES
(1, 289.00, 289.00,
    (SELECT id_pedido FROM oltp_marketing.pedido WHERE fecha_pedido = '2026-03-08 11:30:00'),
    (SELECT id_componente FROM oltp_marketing.componente WHERE nombre = 'Kit de admisión K&N 57S')),
(1, 199.00, 199.00,
    (SELECT id_pedido FROM oltp_marketing.pedido WHERE fecha_pedido = '2026-03-11 13:50:00'),
    (SELECT id_componente FROM oltp_marketing.componente WHERE nombre = 'Discos de freno Brembo Max')),
(1, 245.00, 245.00,
    (SELECT id_pedido FROM oltp_marketing.pedido WHERE fecha_pedido = '2026-03-14 17:10:00'),
    (SELECT id_componente FROM oltp_marketing.componente WHERE nombre = 'Muelles deportivos Eibach Pro-Kit')),
(1, 49.90, 49.90,
    (SELECT id_pedido FROM oltp_marketing.pedido WHERE fecha_pedido = '2026-03-17 10:00:00'),
    (SELECT id_componente FROM oltp_marketing.componente WHERE nombre = 'Sensor de aparcamiento Bosch')),
(1, 89.90, 89.90,
    (SELECT id_pedido FROM oltp_marketing.pedido WHERE fecha_pedido = '2026-03-21 19:25:00'),
    (SELECT id_componente FROM oltp_marketing.componente WHERE nombre = 'Cola de escape decorativa Remus'));

-- =========================================================
-- INSERTS OLTP_TECNICO
-- =========================================================
INSERT INTO oltp_tecnico.vehiculo (matricula, marca, modelo, anio, num_bastidor) VALUES
('1234KLM', 'Seat', 'León FR', 2020, 'VSSZZZKLZLR012345'),
('2345MNP', 'Volkswagen', 'Golf GTI', 2019, 'WVWZZZAUZKW123456'),
('3456PQR', 'BMW', '320d', 2021, 'WBA8C11050FK23456'),
('4567STU', 'Audi', 'A3 Sportback', 2018, 'WAUZZZ8V0JA345678'),
('5678VWX', 'Ford', 'Focus ST-Line', 2022, 'WF0NXXGCHNCD45678');

INSERT INTO oltp_tecnico.cita (fecha, hora, motivo, estado, id_vehiculo) VALUES
('2026-03-25', '09:00:00', 'Cambio de aceite y filtros', 'Completada',
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '1234KLM')),
('2026-03-26', '10:30:00', 'Revisión de frenos', 'Completada',
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '2345MNP')),
('2026-03-27', '12:00:00', 'Sustitución de amortiguadores', 'Pendiente',
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '3456PQR')),
('2026-03-28', '16:00:00', 'Diagnóstico electrónico', 'Confirmada',
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '4567STU')),
('2026-03-29', '08:30:00', 'Montaje de escape deportivo', 'Confirmada',
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '5678VWX'));

INSERT INTO oltp_tecnico.empleado (nombre, apellidos, telefono, email, puesto) VALUES
('Iván', 'Romero Vidal', '622300111', 'ivan.romero@torquelab.com', 'Mecánico'),
('Raúl', 'Herrera Nieto', '622300222', 'raul.herrera@torquelab.com', 'Mecánico'),
('Sonia', 'Campos Ruiz', '622300333', 'sonia.campos@torquelab.com', 'Jefa de taller'),
('Adrián', 'Peña Soto', '622300444', 'adrian.pena@torquelab.com', 'Electromecánico'),
('Cristina', 'Molina Vera', '622300555', 'cristina.molina@torquelab.com', 'Recepción técnica');

INSERT INTO oltp_tecnico.servicio (fecha_apertura, fecha_cierre, tipo, descripcion, estado, kilometraje, coste, id_vehiculo, id_empleado) VALUES
('2026-03-25 09:15:00', '2026-03-25 11:00:00', 'Mantenimiento', 'Cambio de aceite, filtro de aceite y revisión general', 'Finalizado', 58420, 89.90,
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '1234KLM'),
    (SELECT id_empleado FROM oltp_tecnico.empleado WHERE email = 'ivan.romero@torquelab.com')),
('2026-03-26 10:45:00', '2026-03-26 13:00:00', 'Reparación', 'Sustitución de pastillas de freno delanteras', 'Finalizado', 73110, 149.90,
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '2345MNP'),
    (SELECT id_empleado FROM oltp_tecnico.empleado WHERE email = 'raul.herrera@torquelab.com')),
('2026-03-27 12:15:00', NULL, 'Reparación', 'Cambio de amortiguadores traseros', 'En proceso', 45200, 240.00,
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '3456PQR'),
    (SELECT id_empleado FROM oltp_tecnico.empleado WHERE email = 'sonia.campos@torquelab.com')),
('2026-03-28 16:10:00', NULL, 'Diagnóstico', 'Revisión de sensores de aparcamiento y batería', 'Pendiente', 66890, 65.00,
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '4567STU'),
    (SELECT id_empleado FROM oltp_tecnico.empleado WHERE email = 'adrian.pena@torquelab.com')),
('2026-03-29 08:45:00', NULL, 'Instalación', 'Instalación de escape deportivo homologado', 'Pendiente', 18450, 320.00,
    (SELECT id_vehiculo FROM oltp_tecnico.vehiculo WHERE matricula = '5678VWX'),
    (SELECT id_empleado FROM oltp_tecnico.empleado WHERE email = 'ivan.romero@torquelab.com'));

INSERT INTO oltp_tecnico.categoria_componente (nombre_categoria, descripcion) VALUES
('Motor', 'Componentes usados en operaciones de motor'),
('Frenos', 'Material de frenado para taller'),
('Suspensión', 'Elementos de suspensión y amortiguación'),
('Electrónica', 'Baterías, sensores y diagnosis'),
('Escape', 'Sistemas de escape para taller');

INSERT INTO oltp_tecnico.componente (nombre, descripcion, precio_venta, precio_compra, stock, stock_minimo, tipo_producto, marca, modelos_compatibles, id_categoria) VALUES
('Aceite 5W30 Castrol 5L', 'Aceite sintético para mantenimientos', 42.00, 24.00, 25, 5, 'Consumible', 'Castrol', 'Universal',
    (SELECT id_categoria FROM oltp_tecnico.categoria_componente WHERE nombre_categoria = 'Motor')),
('Juego de pastillas Brembo P85020', 'Pastillas delanteras para turismo', 69.90, 38.00, 20, 4, 'Recambio', 'Brembo', 'VW Golf, Audi A3',
    (SELECT id_categoria FROM oltp_tecnico.categoria_componente WHERE nombre_categoria = 'Frenos')),
('Amortiguador Sachs Super Touring', 'Amortiguador trasero de sustitución', 115.00, 70.00, 14, 3, 'Recambio', 'Sachs', 'BMW Serie 3',
    (SELECT id_categoria FROM oltp_tecnico.categoria_componente WHERE nombre_categoria = 'Suspensión')),
('Batería Bosch S4 70Ah', 'Batería de reemplazo 12V', 124.00, 79.00, 10, 2, 'Recambio', 'Bosch', 'Audi A3, Seat León',
    (SELECT id_categoria FROM oltp_tecnico.categoria_componente WHERE nombre_categoria = 'Electrónica')),
('Silencioso trasero Remus', 'Tramo final de escape homologado', 355.00, 240.00, 5, 1, 'Tuning', 'Remus', 'Ford Focus ST-Line',
    (SELECT id_categoria FROM oltp_tecnico.categoria_componente WHERE nombre_categoria = 'Escape'));

INSERT INTO oltp_tecnico.servicio_componente (cantidad, precio_unitario, id_servicio, id_componente) VALUES
(1, 42.00,
    (SELECT id_servicio FROM oltp_tecnico.servicio WHERE fecha_apertura = '2026-03-25 09:15:00'),
    (SELECT id_componente FROM oltp_tecnico.componente WHERE nombre = 'Aceite 5W30 Castrol 5L')),
(1, 69.90,
    (SELECT id_servicio FROM oltp_tecnico.servicio WHERE fecha_apertura = '2026-03-26 10:45:00'),
    (SELECT id_componente FROM oltp_tecnico.componente WHERE nombre = 'Juego de pastillas Brembo P85020')),
(2, 115.00,
    (SELECT id_servicio FROM oltp_tecnico.servicio WHERE fecha_apertura = '2026-03-27 12:15:00'),
    (SELECT id_componente FROM oltp_tecnico.componente WHERE nombre = 'Amortiguador Sachs Super Touring')),
(1, 124.00,
    (SELECT id_servicio FROM oltp_tecnico.servicio WHERE fecha_apertura = '2026-03-28 16:10:00'),
    (SELECT id_componente FROM oltp_tecnico.componente WHERE nombre = 'Batería Bosch S4 70Ah')),
(1, 355.00,
    (SELECT id_servicio FROM oltp_tecnico.servicio WHERE fecha_apertura = '2026-03-29 08:45:00'),
    (SELECT id_componente FROM oltp_tecnico.componente WHERE nombre = 'Silencioso trasero Remus'));

-- =========================================================
-- INSERTS OLTP_RRHH
-- =========================================================
INSERT INTO oltp_rrhh.departamento (nombre, descripcion) VALUES
('Taller', 'Departamento encargado de reparaciones y mantenimiento'),
('Ventas', 'Gestión de ventas de productos y atención comercial'),
('Administración', 'Facturación, compras y control administrativo'),
('Marketing', 'Promoción de productos y campañas comerciales'),
('Recursos Humanos', 'Gestión de personal, contratos y nóminas');

INSERT INTO oltp_rrhh.empleado (nombre, apellidos, dni, telefono, email, puesto, salario, fecha_contratacion, id_departamento) VALUES
('Pedro', 'Sánchez López', '11111111H', '633400111', 'pedro.sanchez@torquelab.com', 'Mecánico', 1850.00, '2022-01-10',
    (SELECT id_departamento FROM oltp_rrhh.departamento WHERE nombre = 'Taller')),
('Laura', 'Díaz Romero', '22222222J', '633400222', 'laura.diaz@torquelab.com', 'Comercial', 1700.00, '2021-06-15',
    (SELECT id_departamento FROM oltp_rrhh.departamento WHERE nombre = 'Ventas')),
('Jorge', 'Navarro Ruiz', '33333333K', '633400333', 'jorge.navarro@torquelab.com', 'Administrativo', 1650.00, '2020-03-20',
    (SELECT id_departamento FROM oltp_rrhh.departamento WHERE nombre = 'Administración')),
('Elena', 'Torres Gil', '44444444L', '633400444', 'elena.torres@torquelab.com', 'Especialista Marketing', 1750.00, '2023-02-01',
    (SELECT id_departamento FROM oltp_rrhh.departamento WHERE nombre = 'Marketing')),
('Miguel', 'Castro Peña', '55555555M', '633400555', 'miguel.castro@torquelab.com', 'Técnico RRHH', 1800.00, '2022-09-05',
    (SELECT id_departamento FROM oltp_rrhh.departamento WHERE nombre = 'Recursos Humanos'));

INSERT INTO oltp_rrhh.contrato (tipo_contrato, fecha_inicio, fecha_fin, jornada, salario_base, id_empleado) VALUES
('Indefinido', '2022-01-10', NULL, 'Completa', 1850.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '11111111H')),
('Indefinido', '2021-06-15', NULL, 'Completa', 1700.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '22222222J')),
('Indefinido', '2020-03-20', NULL, 'Completa', 1650.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '33333333K')),
('Temporal', '2023-02-01', '2026-12-31', 'Completa', 1750.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '44444444L')),
('Indefinido', '2022-09-05', NULL, 'Completa', 1800.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '55555555M'));

INSERT INTO oltp_rrhh.nomina (mes, anio, salario_base, complementos, deducciones, salario_neto, id_empleado) VALUES
(3, 2026, 1850.00, 150.00, 320.00, 1680.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '11111111H')),
(3, 2026, 1700.00, 120.00, 285.00, 1535.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '22222222J')),
(3, 2026, 1650.00, 100.00, 270.00, 1480.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '33333333K')),
(3, 2026, 1750.00, 140.00, 300.00, 1590.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '44444444L')),
(3, 2026, 1800.00, 130.00, 310.00, 1620.00,
    (SELECT id_empleado FROM oltp_rrhh.empleado WHERE dni = '55555555M'));

-- =========================================================
-- INSERTS OLTP_ADMINISTRACION
-- =========================================================
INSERT INTO oltp_administracion.proveedor (nombre, cif, telefono, email, pais, region, provincia, ciudad, direccion) VALUES
('Bosch Automotive España', 'A12345678', '644500111', 'ventas@bosch-auto.es', 'España', 'Madrid', 'Madrid', 'Madrid', 'Calle Alcalá 250'),
('Valeo Service España', 'B23456789', '644500222', 'contacto@valeo.es', 'España', 'Cataluña', 'Barcelona', 'Barcelona', 'Carrer de Mallorca 325'),
('Brembo Ibérica', 'C34567890', '644500333', 'info@brembo.es', 'España', 'Comunidad Valenciana', 'Valencia', 'Valencia', 'Avenida del Puerto 17'),
('Varta Battery Solutions', 'D45678901', '644500444', 'comercial@varta.es', 'España', 'País Vasco', 'Álava', 'Vitoria-Gasteiz', 'Calle Portal de Gamarra 9'),
('Akrapovic Performance Parts', 'E56789012', '644500555', 'sales@akrapovic.eu', 'Eslovenia', 'Upper Carniola', 'Kranj', 'Kranj', 'Malo Hudo 8a');

INSERT INTO oltp_administracion.cliente (dni, nombre, apellidos, email, telefonocontacto, pais, region, provincia, ciudad, direccion) VALUES
('66666666N', 'Juan', 'Pérez Molina', 'juan.perez@gmail.com', '655600111', 'España', 'Andalucía', 'Cádiz', 'Jerez de la Frontera', 'Avenida Europa 12'),
('77777777P', 'María', 'López Serrano', 'maria.lopez@gmail.com', '655600222', 'España', 'Madrid', 'Madrid', 'Madrid', 'Calle Goya 77'),
('88888888Q', 'Luis', 'García Torres', 'luis.garcia@gmail.com', '655600333', 'España', 'Comunidad Valenciana', 'Alicante', 'Alicante', 'Avenida Maisonnave 14'),
('99999999R', 'Ana', 'Martínez Vega', 'ana.martinez@gmail.com', '655600444', 'España', 'Cataluña', 'Barcelona', 'Sabadell', 'Carrer de Gràcia 56'),
('10101010S', 'Carlos', 'Ruiz Navarro', 'carlos.ruiz2@gmail.com', '655600555', 'España', 'Galicia', 'Pontevedra', 'Vigo', 'Rúa Urzáiz 91');

INSERT INTO oltp_administracion.empleado (nombre, apellidos, dni, telefono, email, puesto, salario, fecha_contratacion) VALUES
('Raúl', 'Jiménez Soto', '12121212T', '666700111', 'raul.jimenez@torquelab.com', 'Jefe de taller', 2400.00, '2020-05-11'),
('Patricia', 'Moreno Gil', '13131313V', '666700222', 'patricia.moreno@torquelab.com', 'Administrativa', 1650.00, '2021-09-01'),
('Sergio', 'Domínguez León', '14141414W', '666700333', 'sergio.dominguez@torquelab.com', 'Asesor de servicio', 1800.00, '2022-02-14'),
('Noelia', 'Rubio Campos', '15151515X', '666700444', 'noelia.rubio@torquelab.com', 'Responsable compras', 1900.00, '2019-11-21'),
('David', 'Herrero Ruiz', '16161616Y', '666700555', 'david.herrero@torquelab.com', 'Mecánico', 1750.00, '2023-04-03');

INSERT INTO oltp_administracion.vehiculo (matricula, marca, modelo, anio, num_bastidor, id_cliente) VALUES
('6789BCD', 'Seat', 'Ibiza', 2019, 'VSSZZZKJZKR567890',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '66666666N')),
('7890CDF', 'Volkswagen', 'Polo', 2020, 'WVWZZZAWZLU678901',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '77777777P')),
('8901DFG', 'Peugeot', '308', 2021, 'VF3LPHNSMMS789012',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '88888888Q')),
('9012FGH', 'Audi', 'A1', 2018, 'WAUZZZGB0JN890123',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '99999999R')),
('0123GHI', 'BMW', '118i', 2022, 'WBA7K11090V901234',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '10101010S'));

INSERT INTO oltp_administracion.servicio (fecha_apertura, fecha_cierre, tipo, descripcion, estado, kilometraje, coste, id_vehiculo, id_cliente, id_empleado) VALUES
('2026-03-05 08:30:00', '2026-03-05 11:00:00', 'Mantenimiento', 'Revisión anual con cambio de aceite y filtros', 'Finalizado', 52300, 129.90,
    (SELECT id_vehiculo FROM oltp_administracion.vehiculo WHERE matricula = '6789BCD'),
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '66666666N'),
    (SELECT id_empleado FROM oltp_administracion.empleado WHERE dni = '12121212T')),
('2026-03-09 10:00:00', '2026-03-09 13:20:00', 'Reparación', 'Cambio de frenos delanteros', 'Finalizado', 61450, 189.00,
    (SELECT id_vehiculo FROM oltp_administracion.vehiculo WHERE matricula = '7890CDF'),
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '77777777P'),
    (SELECT id_empleado FROM oltp_administracion.empleado WHERE dni = '16161616Y')),
('2026-03-13 09:15:00', NULL, 'Diagnóstico', 'Comprobación de testigo motor encendido', 'En proceso', 40210, 75.00,
    (SELECT id_vehiculo FROM oltp_administracion.vehiculo WHERE matricula = '8901DFG'),
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '88888888Q'),
    (SELECT id_empleado FROM oltp_administracion.empleado WHERE dni = '14141414W')),
('2026-03-16 15:00:00', '2026-03-16 17:10:00', 'Instalación', 'Montaje de batería nueva', 'Finalizado', 70120, 155.00,
    (SELECT id_vehiculo FROM oltp_administracion.vehiculo WHERE matricula = '9012FGH'),
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '99999999R'),
    (SELECT id_empleado FROM oltp_administracion.empleado WHERE dni = '16161616Y')),
('2026-03-22 11:40:00', NULL, 'Instalación', 'Instalación de escape deportivo', 'Pendiente', 18500, 320.00,
    (SELECT id_vehiculo FROM oltp_administracion.vehiculo WHERE matricula = '0123GHI'),
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '10101010S'),
    (SELECT id_empleado FROM oltp_administracion.empleado WHERE dni = '12121212T'));

INSERT INTO oltp_administracion.categoria_componente (nombre_categoria, descripcion) VALUES
('Motor', 'Categoría de componentes de motor'),
('Frenos', 'Categoría de elementos de frenado'),
('Suspensión', 'Categoría de suspensión y amortiguación'),
('Electrónica', 'Categoría de componentes eléctricos'),
('Escape', 'Categoría de sistemas de escape');

INSERT INTO oltp_administracion.orden_compra (fecha, estado, total, id_proveedor) VALUES
('2026-03-01 09:00:00', 'Recibida', 240.00,
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'A12345678')),
('2026-03-03 10:30:00', 'Recibida', 340.00,
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'B23456789')),
('2026-03-06 12:15:00', 'Pendiente', 280.00,
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'C34567890')),
('2026-03-08 16:20:00', 'Recibida', 316.00,
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'D45678901')),
('2026-03-12 11:10:00', 'Pendiente', 820.00,
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'E56789012'));

INSERT INTO oltp_administracion.componente (nombre, descripcion, precio_venta, precio_compra, stock, stock_minimo, tipo_producto, marca, modelos_compatibles, id_proveedor, id_categoria) VALUES
('Filtro de aire Bosch S3491', 'Filtro de aire para mantenimiento de motor', 24.00, 12.00, 40, 8, 'Recambio', 'Bosch', 'Seat Ibiza, VW Polo, Skoda Fabia',
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'A12345678'),
    (SELECT id_categoria FROM oltp_administracion.categoria_componente WHERE nombre_categoria = 'Motor')),
('Juego de pastillas Valeo 301245', 'Pastillas de freno delanteras para turismo', 68.00, 34.00, 28, 6, 'Recambio', 'Valeo', 'VW Polo, Seat Ibiza, Audi A1',
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'B23456789'),
    (SELECT id_categoria FROM oltp_administracion.categoria_componente WHERE nombre_categoria = 'Frenos')),
('Amortiguador delantero Brembo Touring', 'Amortiguador delantero de sustitución', 140.00, 84.00, 15, 3, 'Recambio', 'Brembo', 'Peugeot 308, Citroën C4',
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'C34567890'),
    (SELECT id_categoria FROM oltp_administracion.categoria_componente WHERE nombre_categoria = 'Suspensión')),
('Batería Varta Silver Dynamic 77Ah', 'Batería premium para vehículos compactos y berlina', 158.00, 79.00, 10, 2, 'Recambio', 'Varta', 'Audi A1, BMW Serie 1, VW Golf',
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'D45678901'),
    (SELECT id_categoria FROM oltp_administracion.categoria_componente WHERE nombre_categoria = 'Electrónica')),
('Escape deportivo Akrapovic Evolution Line', 'Sistema de escape deportivo homologado', 820.00, 410.00, 4, 1, 'Tuning', 'Akrapovic', 'BMW 118i, Toyota GR86',
    (SELECT id_proveedor FROM oltp_administracion.proveedor WHERE cif = 'E56789012'),
    (SELECT id_categoria FROM oltp_administracion.categoria_componente WHERE nombre_categoria = 'Escape'));

INSERT INTO oltp_administracion.detalle_orden_compra (cantidad, precio_unitario, subtotal, id_orden_compra, id_componente) VALUES
(20, 12.00, 240.00,
    (SELECT id_orden_compra FROM oltp_administracion.orden_compra WHERE fecha = '2026-03-01 09:00:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Filtro de aire Bosch S3491')),
(10, 34.00, 340.00,
    (SELECT id_orden_compra FROM oltp_administracion.orden_compra WHERE fecha = '2026-03-03 10:30:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Juego de pastillas Valeo 301245')),
(2, 140.00, 280.00,
    (SELECT id_orden_compra FROM oltp_administracion.orden_compra WHERE fecha = '2026-03-06 12:15:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Amortiguador delantero Brembo Touring')),
(4, 79.00, 316.00,
    (SELECT id_orden_compra FROM oltp_administracion.orden_compra WHERE fecha = '2026-03-08 16:20:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Batería Varta Silver Dynamic 77Ah')),
(1, 820.00, 820.00,
    (SELECT id_orden_compra FROM oltp_administracion.orden_compra WHERE fecha = '2026-03-12 11:10:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Escape deportivo Akrapovic Evolution Line'));

INSERT INTO oltp_administracion.servicio_componente (cantidad, precio_unitario, id_servicio, id_componente) VALUES
(1, 24.00,
    (SELECT id_servicio FROM oltp_administracion.servicio WHERE fecha_apertura = '2026-03-05 08:30:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Filtro de aire Bosch S3491')),
(1, 68.00,
    (SELECT id_servicio FROM oltp_administracion.servicio WHERE fecha_apertura = '2026-03-09 10:00:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Juego de pastillas Valeo 301245')),
(1, 140.00,
    (SELECT id_servicio FROM oltp_administracion.servicio WHERE fecha_apertura = '2026-03-13 09:15:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Amortiguador delantero Brembo Touring')),
(1, 158.00,
    (SELECT id_servicio FROM oltp_administracion.servicio WHERE fecha_apertura = '2026-03-16 15:00:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Batería Varta Silver Dynamic 77Ah')),
(1, 820.00,
    (SELECT id_servicio FROM oltp_administracion.servicio WHERE fecha_apertura = '2026-03-22 11:40:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Escape deportivo Akrapovic Evolution Line'));

INSERT INTO oltp_administracion.pedido (fecha_pedido, estado, total, metodo_pago, direccion_envio, id_cliente) VALUES
('2026-03-04 14:20:00', 'Entregado', 24.00, 'Tarjeta', 'Avenida Europa 12, Jerez de la Frontera',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '66666666N')),
('2026-03-07 18:10:00', 'Entregado', 68.00, 'Bizum', 'Calle Goya 77, Madrid',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '77777777P')),
('2026-03-11 12:35:00', 'Enviado', 140.00, 'Transferencia', 'Avenida Maisonnave 14, Alicante',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '88888888Q')),
('2026-03-15 17:50:00', 'Entregado', 158.00, 'Tarjeta', 'Carrer de Gràcia 56, Sabadell',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '99999999R')),
('2026-03-19 09:40:00', 'Preparación', 820.00, 'Financiación', 'Rúa Urzáiz 91, Vigo',
    (SELECT id_cliente FROM oltp_administracion.cliente WHERE dni = '10101010S'));

INSERT INTO oltp_administracion.detalle_pedido (cantidad, precio_unitario, subtotal, id_pedido, id_componente) VALUES
(1, 24.00, 24.00,
    (SELECT id_pedido FROM oltp_administracion.pedido WHERE fecha_pedido = '2026-03-04 14:20:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Filtro de aire Bosch S3491')),
(1, 68.00, 68.00,
    (SELECT id_pedido FROM oltp_administracion.pedido WHERE fecha_pedido = '2026-03-07 18:10:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Juego de pastillas Valeo 301245')),
(1, 140.00, 140.00,
    (SELECT id_pedido FROM oltp_administracion.pedido WHERE fecha_pedido = '2026-03-11 12:35:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Amortiguador delantero Brembo Touring')),
(1, 158.00, 158.00,
    (SELECT id_pedido FROM oltp_administracion.pedido WHERE fecha_pedido = '2026-03-15 17:50:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Batería Varta Silver Dynamic 77Ah')),
(1, 820.00, 820.00,
    (SELECT id_pedido FROM oltp_administracion.pedido WHERE fecha_pedido = '2026-03-19 09:40:00'),
    (SELECT id_componente FROM oltp_administracion.componente WHERE nombre = 'Escape deportivo Akrapovic Evolution Line'));

COMMIT;