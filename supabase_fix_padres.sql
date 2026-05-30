-- ============================================================
-- Fix: Crear funciones RPC faltantes para padres
-- 1. obtener_padres_con_hijos
-- 2. registrar_padre_con_hijos
-- 3. actualizar_padre_con_hijos
-- ============================================================
-- Ejecutar en: https://supabase.com/dashboard/project/felrasjmigeewkxadjow/sql/new
-- ============================================================

-- 1. Obtener padres con sus hijos
CREATE OR REPLACE FUNCTION obtener_padres_con_hijos()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT JSON_AGG(
    JSON_BUILD_OBJECT(
      'id_padre', u.id_usuario,
      'nombre', u.nombre,
      'apellido_paterno', u.apellido_paterno,
      'apellido_materno', u.apellido_materno,
      'correo', u.correo,
      'telefono', u.telefono,
      'activo', u.activo,
      'hijos', COALESCE((
        SELECT JSON_AGG(
          JSON_BUILD_OBJECT(
            'id_alumno', a.id_alumno,
            'nombre', a.nombre,
            'apellido_paterno', a.apellido_paterno,
            'apellido_materno', a.apellido_materno,
            'parentesco', a.parentesco,
            'grado', g.nombre,
            'grupo', gr.nombre
          )
        )
        FROM alumnos a
        LEFT JOIN grados g ON a.id_grado = g.id_grado
        LEFT JOIN grupos gr ON a.id_grupo = gr.id_grupo
        WHERE a.id_padre = u.id_usuario
      ), '[]'::JSON)
    )
  ) INTO result
  FROM usuarios u
  WHERE u.rol = 'PADRE'
  ORDER BY u.nombre;

  RETURN COALESCE(result, '[]'::JSON);
END;
$$;

-- 2. Registrar padre con hijos
CREATE OR REPLACE FUNCTION registrar_padre_con_hijos(
  p_nombre TEXT, p_apellido_paterno TEXT, p_apellido_materno TEXT,
  p_correo TEXT, p_telefono TEXT, p_contrasena TEXT, p_hijos JSONB
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  nuevo_id INT;
  hijo JSON;
BEGIN
  INSERT INTO usuarios (nombre, apellido_paterno, apellido_materno, correo, telefono, contrasena, rol)
  VALUES (p_nombre, p_apellido_paterno, p_apellido_materno, p_correo, p_telefono, p_contrasena, 'PADRE')
  RETURNING id_usuario INTO nuevo_id;

  FOR hijo IN SELECT * FROM JSONB_ARRAY_ELEMENTS(p_hijos)
  LOOP
    INSERT INTO alumnos (nombre, apellido_paterno, apellido_materno, parentesco, id_padre)
    VALUES (
      hijo->>'nombre',
      hijo->>'apellidoPaterno',
      hijo->>'apellidoMaterno',
      hijo->>'parentesco',
      nuevo_id
    );
  END LOOP;

  RETURN JSON_BUILD_OBJECT('success', true, 'id_usuario', nuevo_id);
END;
$$;

-- 3. Actualizar padre con hijos
CREATE OR REPLACE FUNCTION actualizar_padre_con_hijos(
  p_id_padre INT, p_nombre TEXT, p_apellido_paterno TEXT, p_apellido_materno TEXT,
  p_correo TEXT, p_telefono TEXT, p_direccion TEXT, p_hijos JSONB
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  hijo JSON;
  grado_id INT;
  grupo_id INT;
BEGIN
  UPDATE usuarios
  SET nombre = p_nombre, apellido_paterno = p_apellido_paterno,
      apellido_materno = p_apellido_materno, correo = p_correo, telefono = p_telefono
  WHERE id_usuario = p_id_padre;

  DELETE FROM alumnos WHERE id_padre = p_id_padre;

  FOR hijo IN SELECT * FROM JSONB_ARRAY_ELEMENTS(p_hijos)
  LOOP
    grado_id := NULLIF((hijo->>'id_grado')::INT, 0);
    grupo_id := NULLIF((hijo->>'id_grupo')::INT, 0);

    INSERT INTO alumnos (id_alumno, nombre, apellido_paterno, apellido_materno,
                         parentesco, id_grado, id_grupo, id_padre)
    VALUES (
      NULLIF(hijo->>'id_alumno', '')::INT,
      hijo->>'nombre',
      hijo->>'apellidoPaterno',
      hijo->>'apellidoMaterno',
      hijo->>'parentesco',
      grado_id,
      grupo_id,
      p_id_padre
    );
  END LOOP;

  RETURN JSON_BUILD_OBJECT('success', true);
END;
$$;
