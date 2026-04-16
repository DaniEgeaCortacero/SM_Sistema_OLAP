-- =====================================================================
-- QUERIES DE DATA PROFILING – Dataset Meteorológico
-- Práctica 2 · Sistemas Multidimensionales UGR 2025/2026
--
-- INSTRUCCIONES PARA LOS ESTUDIANTES:
--   Ejecuta cada bloque, anota los resultados en tu informe de calidad
--   e identifica qué tipo de anomalía representa cada hallazgo.
-- =====================================================================

SET search_path TO meteo;

-- ─────────────────────────────────────────────────────────────────────
-- BLOQUE 1: Estadísticas generales
-- ─────────────────────────────────────────────────────────────────────

-- P01: Resumen general de la tabla
SELECT
    COUNT(*)                                                AS total_registros,
    COUNT(DISTINCT fecha)                                   AS dias_distintos,
    COUNT(DISTINCT ciudad)                                  AS ciudades_distintas,
    COUNT(DISTINCT estacion_id)                             AS estaciones_distintas,
    MIN(fecha)                                              AS fecha_min,
    MAX(fecha)                                              AS fecha_max
FROM observaciones_diarias;

-- P02: Porcentaje de nulos por columna
SELECT
    COUNT(*) FILTER (WHERE fecha IS NULL)
        AS nulos_fecha,
    ROUND(100.0 * COUNT(*) FILTER (WHERE temp_max IS NULL) / COUNT(*), 2)
        AS pct_nulos_temp_max,
    ROUND(100.0 * COUNT(*) FILTER (WHERE temp_min IS NULL) / COUNT(*), 2)
        AS pct_nulos_temp_min,
    ROUND(100.0 * COUNT(*) FILTER (WHERE temp_media IS NULL) / COUNT(*), 2)
        AS pct_nulos_temp_media,
    ROUND(100.0 * COUNT(*) FILTER (WHERE precipitacion_mm IS NULL) / COUNT(*), 2)
        AS pct_nulos_precip,
    ROUND(100.0 * COUNT(*) FILTER (WHERE humedad_pct IS NULL) / COUNT(*), 2)
        AS pct_nulos_humedad,
    ROUND(100.0 * COUNT(*) FILTER (WHERE condicion_climatica IS NULL) / COUNT(*), 2)
        AS pct_nulos_condicion
FROM observaciones_diarias;

-- ─────────────────────────────────────────────────────────────────────
-- BLOQUE 2: Anomalías de valores
-- ─────────────────────────────────────────────────────────────────────

-- P03: Valores imposibles en temperaturas (¿qué es -99.0?)
SELECT
    COUNT(*) FILTER (WHERE temp_max  = -99.0)  AS temp_max_error_sensor,
    COUNT(*) FILTER (WHERE temp_max  < -50)    AS temp_max_extrema_frio,
    COUNT(*) FILTER (WHERE temp_max  > 60)     AS temp_max_extrema_calor,
    COUNT(*) FILTER (WHERE temp_min  < -50)    AS temp_min_extrema_frio,
    COUNT(*) FILTER (WHERE temp_min  > 50)     AS temp_min_extrema_calor
FROM observaciones_diarias;

-- P04: Precipitación negativa (físicamente imposible)
SELECT observacion_id, fecha, ciudad, precipitacion_mm
FROM observaciones_diarias
WHERE precipitacion_mm < 0
ORDER BY precipitacion_mm;

-- P05: Humedad fuera de rango [0, 100]
SELECT observacion_id, fecha, ciudad, humedad_pct
FROM observaciones_diarias
WHERE humedad_pct < 0 OR humedad_pct > 100
ORDER BY humedad_pct DESC;

-- P06: Temperatura mínima mayor que la máxima (coherencia interna)
SELECT
    observacion_id, fecha, ciudad,
    temp_min, temp_max,
    temp_min - temp_max AS diferencia_invalida
FROM observaciones_diarias
WHERE temp_min > temp_max
  AND temp_max <> -99.0   -- Excluir errores de sensor ya detectados
ORDER BY diferencia_invalida DESC;

-- P07: Condición climática con valores inválidos
SELECT
    condicion_climatica,
    COUNT(*) AS ocurrencias
FROM observaciones_diarias
GROUP BY condicion_climatica
ORDER BY ocurrencias DESC;

-- ─────────────────────────────────────────────────────────────────────
-- BLOQUE 3: Anomalías de unicidad y duplicados
-- ─────────────────────────────────────────────────────────────────────

-- P08: Registros duplicados (misma fecha y ciudad)
SELECT
    fecha,
    ciudad,
    COUNT(*) AS registros_por_dia
FROM observaciones_diarias
WHERE temp_max IS NOT NULL  -- Excluir registros vacíos
GROUP BY fecha, ciudad
HAVING COUNT(*) > 1
ORDER BY registros_por_dia DESC, fecha;

-- P09: Número total de duplicados
SELECT
    SUM(registros_por_dia - 1) AS total_registros_duplicados_extra
FROM (
    SELECT fecha, ciudad, COUNT(*) AS registros_por_dia
    FROM observaciones_diarias
    WHERE temp_max IS NOT NULL
    GROUP BY fecha, ciudad
    HAVING COUNT(*) > 1
) sub;

-- ─────────────────────────────────────────────────────────────────────
-- BLOQUE 4: Anomalías de consistencia (nombres de ciudad)
-- ─────────────────────────────────────────────────────────────────────

-- P10: Variantes de nombres de ciudad (¿cuántas "versiones" de cada ciudad hay?)
SELECT
    LOWER(TRIM(ciudad)) AS ciudad_normalizada,
    COUNT(DISTINCT ciudad) AS variantes_encontradas,
    STRING_AGG(DISTINCT ciudad, ' | ' ORDER BY ciudad) AS listado_variantes,
    COUNT(*) AS total_registros
FROM observaciones_diarias
GROUP BY LOWER(TRIM(ciudad))
ORDER BY variantes_encontradas DESC, total_registros DESC;

-- P11: Registros con nombre de ciudad sospechoso (no en lista esperada)
SELECT DISTINCT ciudad
FROM observaciones_diarias
WHERE ciudad NOT IN (
    'Granada','Sevilla','Málaga','Madrid','Barcelona',
    'Valencia','Bilbao','Zaragoza','Murcia','Almería'
)
ORDER BY ciudad;

-- ─────────────────────────────────────────────────────────────────────
-- BLOQUE 5: Anomalías de integridad referencial
-- ─────────────────────────────────────────────────────────────────────

-- P12: Estaciones referenciadas en observaciones que NO existen en el catálogo
SELECT
    o.estacion_id,
    COUNT(*) AS observaciones_huerfanas
FROM observaciones_diarias o
LEFT JOIN estaciones_meteorologicas e ON o.estacion_id = e.estacion_id
WHERE e.estacion_id IS NULL
GROUP BY o.estacion_id
ORDER BY o.estacion_id;

-- P13: Estaciones del catálogo que NO tienen ninguna observación
SELECT
    e.estacion_id,
    e.nombre_estacion,
    e.ciudad,
    e.activa
FROM estaciones_meteorologicas e
LEFT JOIN observaciones_diarias o ON e.estacion_id = o.estacion_id
WHERE o.estacion_id IS NULL
ORDER BY e.estacion_id;

-- ─────────────────────────────────────────────────────────────────────
-- BLOQUE 6: Estadísticas descriptivas (para contextualizar outliers)
-- ─────────────────────────────────────────────────────────────────────

-- P14: Estadísticas por ciudad (solo registros válidos)
SELECT
    ciudad,
    COUNT(*)                              AS dias_con_datos,
    ROUND(AVG(temp_media), 1)             AS temp_media_promedio,
    MIN(temp_min)                         AS temp_minima_historica,
    MAX(temp_max)                         AS temp_maxima_historica,
    ROUND(AVG(precipitacion_mm), 2)       AS precipitacion_media_diaria,
    SUM(precipitacion_mm)                 AS precipitacion_total_mm,
    ROUND(AVG(humedad_pct), 1)            AS humedad_media_pct
FROM observaciones_diarias
WHERE temp_max <> -99.0               -- Excluir errores de sensor
  AND temp_max IS NOT NULL
  AND precipitacion_mm >= 0           -- Excluir precipitaciones negativas
  AND ciudad IN (
    'Granada','Sevilla','Málaga','Madrid','Barcelona',
    'Valencia','Bilbao','Zaragoza','Murcia','Almería'
  )                                   -- Solo ciudades con nombre correcto
GROUP BY ciudad
ORDER BY temp_media_promedio DESC;

-- P15: Resumen final del profiling (¿cuántas anomalías hay en total?)
SELECT
    'A1 – Errores de sensor (temp = -99)'         AS anomalia,
    COUNT(*) FILTER (WHERE temp_max = -99.0)       AS registros_afectados
FROM observaciones_diarias
UNION ALL
SELECT 'A2 – Precipitación negativa',
    COUNT(*) FILTER (WHERE precipitacion_mm < 0)
FROM observaciones_diarias
UNION ALL
SELECT 'A3 – Humedad fuera de rango [0,100]',
    COUNT(*) FILTER (WHERE humedad_pct < 0 OR humedad_pct > 100)
FROM observaciones_diarias
UNION ALL
SELECT 'A5 – temp_min > temp_max',
    COUNT(*) FILTER (WHERE temp_min > temp_max AND temp_max <> -99.0)
FROM observaciones_diarias
UNION ALL
SELECT 'A7 – Registros completamente vacíos',
    COUNT(*) FILTER (WHERE temp_max IS NULL AND temp_min IS NULL AND precipitacion_mm IS NULL)
FROM observaciones_diarias
UNION ALL
SELECT 'A9 – Condición climática inválida',
    COUNT(*) FILTER (WHERE condicion_climatica IN ('N/A','999','DESCONOCIDO','--','error','null'))
FROM observaciones_diarias;
