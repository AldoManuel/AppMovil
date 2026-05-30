# Asignación Docente-Alumno — Explicación a nivel de Base de Datos

## El problema central

Un docente necesita ver **solo los alumnos que tiene asignados**, agrupados por **grado + grupo**. Pero la asignación no es directa — un alumno pertenece a un `grado` y `grupo`, y un docente puede estar vinculado a esos alumnos de **dos formas distintas** dependiendo del modo global del sistema.

## Modelo de datos

```
usuario (id_usuario, nombre, apellido_paterno, apellido_materno, rol, ...)
  │
  ├── docente (id_docente PK→usuario, limite_alumnos)
  │     ├── docente_materia (N:M con materia)
  │     ├── docente_asignacion_grupo (AUTO)
  │     └── docente_asignacion_alumno (MANUAL)
  │
  └── alumno (id_alumno PK→usuario, id_grado, id_grupo)
        ├── grado (id_grado, nombre, nivel)
        ├── grupo (id_grupo, nombre)
        ├── docente_asignacion_alumno (N:M con docente)
        └── calificacion, asistencia, alumno_padre
```

### Tablas principales

```sql
-- Catálogos
grado     (id_grado, nombre)       -- "1° Primaria", "2° Primaria" ...
grupo     (id_grupo, nombre)       -- "A", "B", "C"
materia   (id_materia, nombre)     -- "Matematicas", "Historia" ...

-- Usuario base (polimórfico)
usuario   (id_usuario, nombre, apellidos, correo, rol, ...)

-- Extensiones de rol (1:1 con usuario)
docente   (id_docente → usuario, limite_alumnos DEFAULT 30)
alumno    (id_alumno → usuario, id_grado → grado, id_grupo → grupo)

-- Asignación de materias al docente
docente_materia (id_docente, id_materia)

-- Asignación docente → grupo entero (MODO AUTO)
docente_asignacion_grupo
  (id_docente, id_grado, id_grupo, id_materia, activo)

-- Asignación docente → alumno individual (MODO MANUAL)
docente_asignacion_alumno
  (id_docente, id_alumno, id_materia, activo)

-- Control del modo global
configuracion.modo_asignacion  ('AUTO' | 'MANUAL')
```

---

## Modo AUTO (asignación por grupo entero)

1. En `configuracion.modo_asignacion = 'AUTO'`
2. Se inserta un registro en `docente_asignacion_grupo`:
   ```sql
   (id_docente='X', id_grado=1, id_grupo=1, id_materia=3)
   ```
3. **Interpretación:** El docente X imparte la materia 3 a **todos** los alumnos que tengan `id_grado=1 AND id_grupo=1`.

4. Para obtener los alumnos del docente en la app:
   ```sql
   SELECT a.*, g.nombre AS grado, gr.nombre AS grupo
   FROM alumno a
   JOIN grado g       ON a.id_grado = g.id_grado
   JOIN grupo gr      ON a.id_grupo = gr.id_grupo
   JOIN docente_asignacion_grupo dag
        ON dag.id_grado = a.id_grado
       AND dag.id_grupo  = a.id_grupo
   WHERE dag.id_docente = 'X'
     AND dag.activo = true;
   ```
   Esto devuelve **todos los alumnos de ese grado+grupo** automáticamente, porque el join se hace contra `id_grado` e `id_grupo` del alumno, no contra su `id_alumno`.

---

## Modo MANUAL (asignación individual)

1. En `configuracion.modo_asignacion = 'MANUAL'`
2. Se inserta un registro en `docente_asignacion_alumno`:
   ```sql
   (id_docente='X', id_alumno='Y', id_materia=3)
   ```
3. **Interpretación:** El docente X imparte la materia 3 **específicamente** al alumno Y (independientemente de su grado/grupo).

4. Para obtener los alumnos en la app:
   ```sql
   SELECT a.*, g.nombre AS grado, gr.nombre AS grupo
   FROM alumno a
   JOIN grado g  ON a.id_grado = g.id_grado
   JOIN grupo gr ON a.id_grupo = gr.id_grupo
   JOIN docente_asignacion_alumno daa
        ON daa.id_alumno = a.id_alumno
   WHERE daa.id_docente = 'X'
     AND daa.activo = true;
   ```
   Aquí el join es contra `id_alumno`, por lo que solo aparecen los alumnos explícitamente asignados.

---

## Consulta unificada para la app del docente

Para la aplicación móvil del docente, se necesita mostrar **todos** sus alumnos (vengan de AUTO o MANUAL) **agrupados por grado+grupo**. La consulta real unifica ambos modos con `UNION`:

```sql
SELECT a.id_alumno,
       u.nombre,
       u.apellido_paterno,
       u.apellido_materno,
       g.nombre  AS grado,
       gr.nombre AS grupo,
       g.id_grado,
       gr.id_grupo
FROM alumno a
JOIN usuario u ON u.id_usuario = a.id_alumno
JOIN grado g   ON a.id_grado   = g.id_grado
JOIN grupo gr  ON a.id_grupo   = gr.id_grupo
WHERE a.id_alumno IN (
    -- Alumnos por asignación de grupo (AUTO)
    SELECT a2.id_alumno
    FROM alumno a2
    JOIN docente_asignacion_grupo dag
         ON dag.id_grado = a2.id_grado
        AND dag.id_grupo  = a2.id_grupo
    WHERE dag.id_docente = 'X'
      AND dag.activo = true

    UNION

    -- Alumnos por asignación individual (MANUAL)
    SELECT daa.id_alumno
    FROM docente_asignacion_alumno daa
    WHERE daa.id_docente = 'X'
      AND daa.activo = true
)
ORDER BY g.nivel, gr.nombre, u.apellido_paterno;
```

---

## Agrupación en el frontend

El resultado anterior se procesa en la app para agrupar visualmente por `(grado, grupo)`:

```
1° Primaria - A
  ├── Juan Pérez
  └── María López

2° Primaria - B
  └── Carlos García
```

Esto es posible porque **`alumno` siempre tiene `id_grado` e `id_grupo`**, independientemente del modo de asignación.

---

## Validación del límite de alumnos

Ambos modos validan el límite del docente (`docente.limite_alumnos`) antes de insertar:

```sql
-- Cálculo del total actual de alumnos del docente (ambos modos)
SELECT COUNT(DISTINCT alumno_id) INTO v_total FROM (
    SELECT a.id_alumno AS alumno_id
    FROM alumno a
    JOIN docente_asignacion_grupo dag
         ON dag.id_grado = a.id_grado AND dag.id_grupo = a.id_grupo
    WHERE dag.id_docente = p_id_docente AND dag.activo = true
    UNION
    SELECT daa.id_alumno
    FROM docente_asignacion_alumno daa
    WHERE daa.id_docente = p_id_docente AND daa.activo = true
) AS alumnos_unificados;

IF v_total >= (SELECT limite_alumnos FROM docente WHERE id_docente = p_id_docente) THEN
    RAISE EXCEPTION 'Límite de alumnos alcanzado';
END IF;
```

---

## Resumen

| Concepto | `docente_asignacion_grupo` (AUTO) | `docente_asignacion_alumno` (MANUAL) |
|---|---|---|
| Asigna a | Un grado+grupo+materia | Un alumno+materia específico |
| Afecta a | Todos los alumnos de ese grupo | Solo el alumno indicado |
| Join con alumno | Por `id_grado + id_grupo` | Por `id_alumno` |
| Agrupación en app | Natural por grado+grupo | También se agrupa porque `alumno` tiene `id_grado` e `id_grupo` |
| Caso de uso | Un maestro titular que ve a todo un salón | Tutorías o materias optativas con alumnos selectos |

**La clave está en que `alumno` ya contiene `id_grado` e `id_grupo`**, por lo que sin importar el modo de asignación, siempre puedes agrupar los alumnos del docente por su grado+grupo para mostrarlos ordenadamente en la app.
