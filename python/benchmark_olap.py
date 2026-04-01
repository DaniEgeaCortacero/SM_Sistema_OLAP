import psycopg2
import time
import statistics

conn = psycopg2.connect(
    host="localhost",
    database="torquelab",
    user="admin",
    password="admin123"
)

cur = conn.cursor()

# ==========================================================
# QUERY 1
# Ingreso por producto/categoría
# OLTP vs STAR-like vs SNOW-like
# ==========================================================

query1_oltp = """
SELECT
    cc.nombre_categoria,
    SUM(x.subtotal) AS ingreso_total
FROM (
    SELECT dp.id_componente, dp.subtotal, 'ventas' AS origen
    FROM oltp_ventas.detalle_pedido dp

    UNION ALL

    SELECT dp.id_componente, dp.subtotal, 'marketing' AS origen
    FROM oltp_marketing.detalle_pedido dp

    UNION ALL

    SELECT dp.id_componente, dp.subtotal, 'administracion' AS origen
    FROM oltp_administracion.detalle_pedido dp
) x
JOIN (
    SELECT c.id_componente, cc.nombre_categoria, 'ventas' AS origen
    FROM oltp_ventas.componente c
    LEFT JOIN oltp_ventas.categoria_componente cc
        ON c.id_categoria = cc.id_categoria

    UNION ALL

    SELECT c.id_componente, cc.nombre_categoria, 'marketing' AS origen
    FROM oltp_marketing.componente c
    LEFT JOIN oltp_marketing.categoria_componente cc
        ON c.id_categoria = cc.id_categoria

    UNION ALL

    SELECT c.id_componente, cc.nombre_categoria, 'administracion' AS origen
    FROM oltp_administracion.componente c
    LEFT JOIN oltp_administracion.categoria_componente cc
        ON c.id_categoria = cc.id_categoria
) cc
    ON x.id_componente = cc.id_componente
   AND x.origen = cc.origen
GROUP BY cc.nombre_categoria;
"""

# STAR-like: una sola dimensión de producto
query1_star = """
SELECT
    dc.tipo_producto,
    SUM(fv.precio) AS ingreso_total
FROM olap.fact_ventas fv
JOIN olap.dim_componente dc
    ON fv.id_componente = dc.id_componente_dw
GROUP BY dc.tipo_producto;
"""

# SNOW-like: dimensión producto + dimensión categoría
query1_snow = """
SELECT
    cat.nombre_categoria,
    SUM(fv.precio) AS ingreso_total
FROM olap.fact_ventas fv
JOIN olap.dim_componente dc
    ON fv.id_componente = dc.id_componente_dw
JOIN olap.dim_categoria_componente cat
    ON dc.id_categoria_dw = cat.id_categoria_dw
GROUP BY cat.nombre_categoria;
"""

# ==========================================================
# QUERY 2
# Ingreso mensual
# ==========================================================

query2_oltp = """
SELECT
    EXTRACT(YEAR FROM t.fecha_pedido)::int AS anio,
    EXTRACT(MONTH FROM t.fecha_pedido)::int AS mes,
    SUM(t.subtotal) AS ingreso_mensual
FROM (
    SELECT p.fecha_pedido, dp.subtotal
    FROM oltp_ventas.pedido p
    JOIN oltp_ventas.detalle_pedido dp ON p.id_pedido = dp.id_pedido

    UNION ALL

    SELECT p.fecha_pedido, dp.subtotal
    FROM oltp_marketing.pedido p
    JOIN oltp_marketing.detalle_pedido dp ON p.id_pedido = dp.id_pedido

    UNION ALL

    SELECT p.fecha_pedido, dp.subtotal
    FROM oltp_administracion.pedido p
    JOIN oltp_administracion.detalle_pedido dp ON p.id_pedido = dp.id_pedido
) t
GROUP BY
    EXTRACT(YEAR FROM t.fecha_pedido),
    EXTRACT(MONTH FROM t.fecha_pedido)
ORDER BY anio, mes;
"""

query2_star = """
SELECT
    dt.anio,
    dt.mes,
    SUM(fv.precio) AS ingreso_mensual
FROM olap.fact_ventas fv
JOIN olap.dim_tiempo dt
    ON fv.id_fecha = dt.id_fecha
GROUP BY dt.anio, dt.mes
ORDER BY dt.anio, dt.mes;
"""

# En esta consulta snow y star son casi iguales
query2_snow = """
SELECT
    dt.anio,
    dt.mes,
    SUM(fv.precio) AS ingreso_mensual
FROM olap.fact_ventas fv
JOIN olap.dim_tiempo dt
    ON fv.id_fecha = dt.id_fecha
GROUP BY dt.anio, dt.mes
ORDER BY dt.anio, dt.mes;
"""

# ==========================================================
# QUERY 3
# Beneficio por producto/categoría
# ==========================================================

query3_oltp = """
SELECT
    cc.nombre_categoria,
    SUM(x.beneficio) AS beneficio_total
FROM (
    SELECT
        dp.id_componente,
        (dp.subtotal - (dp.cantidad * c.precio_compra)) AS beneficio,
        'ventas' AS origen
    FROM oltp_ventas.detalle_pedido dp
    JOIN oltp_ventas.componente c
        ON dp.id_componente = c.id_componente

    UNION ALL

    SELECT
        dp.id_componente,
        (dp.subtotal - (dp.cantidad * c.precio_compra)) AS beneficio,
        'marketing' AS origen
    FROM oltp_marketing.detalle_pedido dp
    JOIN oltp_marketing.componente c
        ON dp.id_componente = c.id_componente

    UNION ALL

    SELECT
        dp.id_componente,
        (dp.subtotal - (dp.cantidad * c.precio_compra)) AS beneficio,
        'administracion' AS origen
    FROM oltp_administracion.detalle_pedido dp
    JOIN oltp_administracion.componente c
        ON dp.id_componente = c.id_componente
) x
JOIN (
    SELECT c.id_componente, cc.nombre_categoria, 'ventas' AS origen
    FROM oltp_ventas.componente c
    LEFT JOIN oltp_ventas.categoria_componente cc
        ON c.id_categoria = cc.id_categoria

    UNION ALL

    SELECT c.id_componente, cc.nombre_categoria, 'marketing' AS origen
    FROM oltp_marketing.componente c
    LEFT JOIN oltp_marketing.categoria_componente cc
        ON c.id_categoria = cc.id_categoria

    UNION ALL

    SELECT c.id_componente, cc.nombre_categoria, 'administracion' AS origen
    FROM oltp_administracion.componente c
    LEFT JOIN oltp_administracion.categoria_componente cc
        ON c.id_categoria = cc.id_categoria
) cc
    ON x.id_componente = cc.id_componente
   AND x.origen = cc.origen
GROUP BY cc.nombre_categoria;
"""

query3_star = """
SELECT
    dc.tipo_producto,
    SUM(fv.beneficio) AS beneficio_total
FROM olap.fact_ventas fv
JOIN olap.dim_componente dc
    ON fv.id_componente = dc.id_componente_dw
GROUP BY dc.tipo_producto;
"""

query3_snow = """
SELECT
    cat.nombre_categoria,
    SUM(fv.beneficio) AS beneficio_total
FROM olap.fact_ventas fv
JOIN olap.dim_componente dc
    ON fv.id_componente = dc.id_componente_dw
JOIN olap.dim_categoria_componente cat
    ON dc.id_categoria_dw = cat.id_categoria_dw
GROUP BY cat.nombre_categoria;
"""

def medir(query, repeticiones=20):
    tiempos = []
    for _ in range(repeticiones):
        inicio = time.perf_counter()
        cur.execute(query)
        cur.fetchall()
        fin = time.perf_counter()
        tiempos.append(fin - inicio)
    return tiempos

def promedio_ms(tiempos):
    return statistics.mean(tiempos) * 1000

def mejora_porcentual(star_ms, snow_ms):
    if snow_ms == 0:
        return 0
    return ((snow_ms - star_ms) / snow_ms) * 100

def mostrar_resultados(nombre, oltp_times, star_times, snow_times):
    oltp_ms = promedio_ms(oltp_times)
    star_ms = promedio_ms(star_times)
    snow_ms = promedio_ms(snow_times)
    mejora = mejora_porcentual(star_ms, snow_ms)

    print(f"\n===== {nombre} =====")
    print(f"OLTP      : {oltp_ms:.3f} ms")
    print(f"STAR-like : {star_ms:.3f} ms")
    print(f"SNOW-like : {snow_ms:.3f} ms")
    print(f"Mejora STAR vs SNOW: {mejora:.2f}%")

print("Ejecutando Query 1...")
q1_oltp = medir(query1_oltp)
q1_star = medir(query1_star)
q1_snow = medir(query1_snow)
mostrar_resultados("QUERY 1 - Ingreso por producto/categoría", q1_oltp, q1_star, q1_snow)

print("\nEjecutando Query 2...")
q2_oltp = medir(query2_oltp)
q2_star = medir(query2_star)
q2_snow = medir(query2_snow)
mostrar_resultados("QUERY 2 - Ingreso mensual", q2_oltp, q2_star, q2_snow)

print("\nEjecutando Query 3...")
q3_oltp = medir(query3_oltp)
q3_star = medir(query3_star)
q3_snow = medir(query3_snow)
mostrar_resultados("QUERY 3 - Beneficio por producto/categoría", q3_oltp, q3_star, q3_snow)

print("\n\n================ TABLA FINAL ================")
print(f"{'Consulta':<12}{'Star (ms)':>12}{'Snowflake (ms)':>18}{'Mejora':>12}")
print("-" * 56)

for nombre, star_t, snow_t in [
    ("Query 1", q1_star, q1_snow),
    ("Query 2", q2_star, q2_snow),
    ("Query 3", q3_star, q3_snow),
]:
    star_ms = promedio_ms(star_t)
    snow_ms = promedio_ms(snow_t)
    mejora = mejora_porcentual(star_ms, snow_ms)
    print(f"{nombre:<12}{star_ms:>12.3f}{snow_ms:>18.3f}{mejora:>11.2f}%")

cur.close()
conn.close()