-- ==========================================================
-- SISTEMA DE GESTIÓN EDUCATIVA (TaskTracker)
-- Script de creación de base de datos
-- Versión: 1.0
-- Motor: PostgreSQL 15+ (Supabase)
-- ==========================================================
-- USO: Ejecutar en SQL Editor de Supabase
-- ==========================================================

-- ==========================================================
-- EXTENSIÓN PARA UUID Y CONTRASEÑAS
-- ==========================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================================
-- 1. TABLAS CATÁLOGO
-- ==========================================================

-- 1.1 Grados escolares (1° a 6° Primaria)
CREATE TABLE public.grado (
  id_grado SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  nivel INTEGER NOT NULL CHECK (nivel BETWEEN 1 AND 6)
);

-- 1.2 Grupos (A, B, C)
CREATE TABLE public.grupo (
  id_grupo SERIAL PRIMARY KEY,
  nombre VARCHAR(10) NOT NULL UNIQUE
);

-- 1.3 Materias / Asignaturas
CREATE TABLE public.materia (
  id_materia SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE
);

-- ==========================================================
-- 2. TABLA PRINCIPAL DE USUARIOS
-- ==========================================================
-- Solo ADMIN, DOCENTE y PADRE tienen contraseña e inician sesión.
-- ALUMNO existe solo como perfil sin acceso al sistema.
CREATE TABLE public.usuario (
  id_usuario UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido_paterno VARCHAR(100),
  apellido_materno VARCHAR(100),
  correo VARCHAR(150) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  rol VARCHAR(20) NOT NULL CHECK (rol IN ('ADMIN', 'DOCENTE', 'PADRE', 'ALUMNO')),
  activo BOOLEAN DEFAULT true,
  ultimo_acceso TIMESTAMP,
  contrasena VARCHAR(255),
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- 3. TABLAS POR ROL
-- ==========================================================

-- 3.1 Docente — extiende usuario con rol DOCENTE
CREATE TABLE public.docente (
  id_docente UUID PRIMARY KEY REFERENCES public.usuario(id_usuario),
  experiencia INTEGER DEFAULT 0
);

-- 3.2 Relación N:M Docente ↔ Materia
CREATE TABLE public.docente_materia (
  id_docente UUID REFERENCES public.docente(id_docente),
  id_materia INTEGER REFERENCES public.materia(id_materia),
  PRIMARY KEY (id_docente, id_materia)
);

-- 3.3 Padre — extiende usuario con rol PADRE
CREATE TABLE public.padre (
  id_padre UUID PRIMARY KEY REFERENCES public.usuario(id_usuario),
  direccion VARCHAR(255)
);

-- 3.4 Alumno — extiende usuario con rol ALUMNO (sin login)
CREATE TABLE public.alumno (
  id_alumno UUID PRIMARY KEY REFERENCES public.usuario(id_usuario),
  id_grupo INTEGER REFERENCES public.grupo(id_grupo),
  promedio DECIMAL(4,2) DEFAULT 0.00
);

-- 3.5 Relación N:M Alumno ↔ Padre (con parentesco)
CREATE TABLE public.alumno_padre (
  id_alumno UUID REFERENCES public.alumno(id_alumno),
  id_padre UUID REFERENCES public.padre(id_padre),
  parentesco VARCHAR(20) NOT NULL CHECK (parentesco IN ('MADRE', 'PADRE', 'TUTOR')),
  PRIMARY KEY (id_alumno, id_padre)
);

-- ==========================================================
-- 4. TABLAS DE ACTIVIDAD ACADÉMICA
-- ==========================================================

-- 4.1 Calificaciones por alumno, materia y periodo
CREATE TABLE public.calificacion (
  id_calificacion SERIAL PRIMARY KEY,
  id_alumno UUID REFERENCES public.alumno(id_alumno),
  id_materia INTEGER REFERENCES public.materia(id_materia),
  calificacion DECIMAL(4,2) NOT NULL CHECK (calificacion BETWEEN 0 AND 10),
  periodo VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id_alumno, id_materia, periodo)
);

-- 4.2 Asistencia diaria por alumno
CREATE TABLE public.asistencia (
  id_asistencia SERIAL PRIMARY KEY,
  id_alumno UUID REFERENCES public.alumno(id_alumno),
  fecha DATE NOT NULL,
  presente BOOLEAN DEFAULT true,
  justificacion TEXT,
  UNIQUE (id_alumno, fecha)
);

-- ==========================================================
-- 5. TABLAS DE ACTIVIDAD DEL SISTEMA
-- ==========================================================

-- 5.1 Eventos del calendario escolar
CREATE TABLE public.evento (
  id_evento SERIAL PRIMARY KEY,
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT,
  tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('EVENTO_ESCOLAR', 'EXAMEN', 'PROYECTO', 'FECHA_IMPORTANTE')),
  fecha DATE NOT NULL,
  hora TIME,
  color VARCHAR(30),
  id_creador UUID REFERENCES public.usuario(id_usuario),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5.2 Notificaciones del sistema
CREATE TABLE public.notificacion (
  id_notificacion SERIAL PRIMARY KEY,
  id_usuario UUID REFERENCES public.usuario(id_usuario),
  tipo VARCHAR(30) NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  cuerpo TEXT,
  leida BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5.3 Bitácora de actividad reciente
CREATE TABLE public.actividad (
  id_actividad SERIAL PRIMARY KEY,
  id_usuario UUID REFERENCES public.usuario(id_usuario),
  accion VARCHAR(200) NOT NULL,
  entidad_tipo VARCHAR(30),
  entidad_id UUID,
  estado VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- 6. CONFIGURACIÓN POR USUARIO
-- ==========================================================

CREATE TABLE public.configuracion (
  id_configuracion SERIAL PRIMARY KEY,
  id_usuario UUID REFERENCES public.usuario(id_usuario) UNIQUE,
  tema VARCHAR(10) DEFAULT 'light' CHECK (tema IN ('light', 'dark')),
  sidebar_colapsada BOOLEAN DEFAULT false,
  idioma VARCHAR(20) DEFAULT 'Español',
  notificaciones_email BOOLEAN DEFAULT true,
  notificaciones_push BOOLEAN DEFAULT false,
  registros_por_pagina INTEGER DEFAULT 25 CHECK (registros_por_pagina IN (10, 25, 50, 100)),
  formato_fecha VARCHAR(20) DEFAULT 'DD/MM/AAAA',
  zona_horaria VARCHAR(50) DEFAULT 'America/Mexico_City'
);

-- ==========================================================
-- 7. ÍNDICES
-- ==========================================================

CREATE INDEX IF NOT EXISTS idx_usuario_correo ON public.usuario(correo);
CREATE INDEX IF NOT EXISTS idx_usuario_rol ON public.usuario(rol);
CREATE INDEX IF NOT EXISTS idx_usuario_activo ON public.usuario(activo);
CREATE INDEX IF NOT EXISTS idx_alumno_grupo ON public.alumno(id_grupo);
CREATE INDEX IF NOT EXISTS idx_evento_fecha ON public.evento(fecha);
CREATE INDEX IF NOT EXISTS idx_notificacion_usuario_leida ON public.notificacion(id_usuario, leida);
CREATE INDEX IF NOT EXISTS idx_actividad_fecha ON public.actividad(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calificacion_alumno ON public.calificacion(id_alumno);
CREATE INDEX IF NOT EXISTS idx_asistencia_alumno_fecha ON public.asistencia(id_alumno, fecha);

-- ==========================================================
-- 8. DATOS INICIALES — CATÁLOGOS
-- ==========================================================

-- 8.1 Grados
INSERT INTO public.grado (nombre, nivel) VALUES
  ('1° Primaria', 1),
  ('2° Primaria', 2),
  ('3° Primaria', 3),
  ('4° Primaria', 4),
  ('5° Primaria', 5),
  ('6° Primaria', 6);

-- 8.2 Grupos
INSERT INTO public.grupo (nombre) VALUES
  ('A'),
  ('B'),
  ('C');

-- 8.3 Materias
INSERT INTO public.materia (nombre) VALUES
  ('Matemáticas'),
  ('Historia'),
  ('Ciencias Naturales'),
  ('Educación Física'),
  ('Lengua y Literatura'),
  ('Inglés');

-- ==========================================================
-- 9. DATOS INICIALES — USUARIOS Y ROLES
-- ==========================================================
-- Solo ADMIN, DOCENTE y PADRE tienen contraseña (pueden iniciar sesión).
-- ALUMNO tiene contrasena = NULL (sin acceso al sistema).

-- 9.1 ADMIN
INSERT INTO public.usuario (id_usuario, nombre, apellido_paterno, correo, telefono, rol, activo, contrasena)
VALUES (
  'a0000000-0000-0000-0000-000000000001',
  'Admin', 'Principal', NULL,
  'admin@institucion.edu', '+52 555 000 0000',
  'ADMIN', true,
  crypt('admin123', gen_salt('bf'))
);

-- 9.2 DOCENTES
INSERT INTO public.usuario (id_usuario, nombre, apellido_paterno, apellido_materno, correo, telefono, rol, activo, contrasena)
VALUES
  ('a0000000-0000-0000-0000-000000000002', 'María',   'García',   'López',  'maria.garcia@institucion.edu',    '+52 555 123 4567', 'DOCENTE', true,  crypt('docente123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000003', 'Carlos',  'Hernández', 'Ruiz',   'carlos.hernandez@institucion.edu', '+52 555 234 5678', 'DOCENTE', true,  crypt('docente123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000004', 'Ana',     'Rodríguez', 'Pérez',   'ana.rodriguez@institucion.edu',    '+52 555 345 6789', 'DOCENTE', true,  crypt('docente123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000005', 'Jorge',   'Mendoza',   'Solís',   'jorge.mendoza@institucion.edu',    '+52 555 456 7890', 'DOCENTE', false, crypt('docente123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000006', 'Laura',   'Gómez',    'Castillo', 'laura.gomez@institucion.edu',     '+52 555 567 8901', 'DOCENTE', true,  crypt('docente123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000007', 'Roberto', 'Flores',   'Nava',    'roberto.flores@institucion.edu',   '+52 555 678 9012', 'DOCENTE', true,  crypt('docente123', gen_salt('bf')));

-- 9.3 PADRES
INSERT INTO public.usuario (id_usuario, nombre, apellido_paterno, apellido_materno, correo, telefono, rol, activo, contrasena)
VALUES
  ('a0000000-0000-0000-0000-000000000008', 'Ana',     'Martínez', 'Torres',   'ana.martinez@email.com',     '+52 555 111 2233', 'PADRE', true,  crypt('padre123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000009', 'Laura',   'Díaz',     'Flores',   'laura.diaz@email.com',       '+52 555 222 3344', 'PADRE', true,  crypt('padre123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000010', 'Roberto', 'Hernández','Ruiz',     'roberto.hernandez@email.com','+52 555 333 4455', 'PADRE', true,  crypt('padre123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000011', 'María',   'Torres',   'García',   'maria.torres@email.com',     '+52 555 444 5566', 'PADRE', false, crypt('padre123', gen_salt('bf'))),
  ('a0000000-0000-0000-0000-000000000012', 'José Luis','Mendoza', NULL,       'jose.mendoza@email.com',     '+52 555 555 6677', 'PADRE', true,  crypt('padre123', gen_salt('bf')));

-- 9.4 ALUMNOS (sin contraseña — no inician sesión)
INSERT INTO public.usuario (id_usuario, nombre, apellido_paterno, correo, rol, activo, contrasena)
VALUES
  ('a0000000-0000-0000-0000-000000000013', 'Diego',   'Martínez',  'diego.martinez@alumno.edu',  'ALUMNO', true,  NULL),
  ('a0000000-0000-0000-0000-000000000014', 'Sofía',   'Díaz',      'sofia.diaz@alumno.edu',      'ALUMNO', true,  NULL),
  ('a0000000-0000-0000-0000-000000000015', 'Carlos',  'Hernández', 'carlos.hernandez@alumno.edu', 'ALUMNO', true,  NULL),
  ('a0000000-0000-0000-0000-000000000016', 'Ana',     'Torres',    'ana.torres@alumno.edu',      'ALUMNO', false, NULL),
  ('a0000000-0000-0000-0000-000000000017', 'Luis',    'Díaz',      'luis.diaz@alumno.edu',       'ALUMNO', true,  NULL),
  ('a0000000-0000-0000-0000-000000000018', 'Pedro',   'Mendoza',   'pedro.mendoza@alumno.edu',   'ALUMNO', true,  NULL),
  ('a0000000-0000-0000-0000-000000000019', 'Pedro',   'Sánchez',   'pedro.sanchez@email.com',    'ALUMNO', false, NULL);

-- ==========================================================
-- 10. DATOS INICIALES — TABLAS POR ROL
-- ==========================================================

-- 10.1 Docentes (experiencia en años)
INSERT INTO public.docente (id_docente, experiencia) VALUES
  ('a0000000-0000-0000-0000-000000000002', 6),
  ('a0000000-0000-0000-0000-000000000003', 8),
  ('a0000000-0000-0000-0000-000000000004', 4),
  ('a0000000-0000-0000-0000-000000000005', 10),
  ('a0000000-0000-0000-0000-000000000006', 5),
  ('a0000000-0000-0000-0000-000000000007', 7);

-- 10.2 Relación Docente ↔ Materia
INSERT INTO public.docente_materia (id_docente, id_materia) VALUES
  ('a0000000-0000-0000-0000-000000000002', 1),  -- María García -> Matemáticas
  ('a0000000-0000-0000-0000-000000000003', 2),  -- Carlos Hernández -> Historia
  ('a0000000-0000-0000-0000-000000000004', 3),  -- Ana Rodríguez -> Ciencias Naturales
  ('a0000000-0000-0000-0000-000000000005', 4),  -- Jorge Mendoza -> Educación Física
  ('a0000000-0000-0000-0000-000000000006', 5),  -- Laura Gómez -> Lengua y Literatura
  ('a0000000-0000-0000-0000-000000000007', 6);  -- Roberto Flores -> Inglés

-- 10.3 Padres
INSERT INTO public.padre (id_padre) VALUES
  ('a0000000-0000-0000-0000-000000000008'),
  ('a0000000-0000-0000-0000-000000000009'),
  ('a0000000-0000-0000-0000-000000000010'),
  ('a0000000-0000-0000-0000-000000000011'),
  ('a0000000-0000-0000-0000-000000000012');

-- 10.4 Alumnos (asignación a grupos y promedios)
INSERT INTO public.alumno (id_alumno, id_grupo, promedio) VALUES
  ('a0000000-0000-0000-0000-000000000013', 1, 9.2),  -- Diego Martínez  -> 4° Primaria, Grupo A
  ('a0000000-0000-0000-0000-000000000014', 2, 8.8),  -- Sofía Díaz      -> 5° Primaria, Grupo B
  ('a0000000-0000-0000-0000-000000000015', 1, 7.5),  -- Carlos Hernández -> 3° Primaria, Grupo A
  ('a0000000-0000-0000-0000-000000000016', 3, 6.1),  -- Ana Torres      -> 6° Primaria, Grupo C
  ('a0000000-0000-0000-0000-000000000017', 1, 9.5),  -- Luis Díaz       -> 2° Primaria, Grupo A
  ('a0000000-0000-0000-0000-000000000018', 2, 8.0);  -- Pedro Mendoza   -> 1° Primaria, Grupo B

-- 10.5 Relación Alumno ↔ Padre (con parentesco)
INSERT INTO public.alumno_padre (id_alumno, id_padre, parentesco) VALUES
  ('a0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000008', 'MADRE'),  -- Diego  <-> Ana Martínez
  ('a0000000-0000-0000-0000-000000000014', 'a0000000-0000-0000-0000-000000000009', 'MADRE'),  -- Sofía  <-> Laura Díaz
  ('a0000000-0000-0000-0000-000000000017', 'a0000000-0000-0000-0000-000000000009', 'MADRE'),  -- Luis   <-> Laura Díaz
  ('a0000000-0000-0000-0000-000000000015', 'a0000000-0000-0000-0000-000000000010', 'PADRE'),  -- Carlos <-> Roberto Hernández
  ('a0000000-0000-0000-0000-000000000016', 'a0000000-0000-0000-0000-000000000011', 'MADRE'),  -- Ana    <-> María Torres
  ('a0000000-0000-0000-0000-000000000018', 'a0000000-0000-0000-0000-000000000012', 'PADRE');  -- Pedro  <-> José Luis Mendoza

-- ==========================================================
-- 11. DATOS INICIALES — EVENTOS DEL CALENDARIO
-- ==========================================================

INSERT INTO public.evento (titulo, descripcion, tipo, fecha, hora, color, id_creador) VALUES
  ('Entrega de Matemáticas',   'Álgebra Lineal',                            'EXAMEN',           '2026-05-11', '10:00', 'event-blue',   'a0000000-0000-0000-0000-000000000001'),
  ('Junta de Padres',          '3° Primaria A',                             'EVENTO_ESCOLAR',   '2026-05-13', '16:00', 'event-green',  'a0000000-0000-0000-0000-000000000001'),
  ('Examen de Historia',       'Revolución Mexicana',                       'EXAMEN',           '2026-05-15', '09:00', 'event-purple', 'a0000000-0000-0000-0000-000000000001'),
  ('Proyecto de Ciencias',     'Proyecto Final',                            'PROYECTO',         '2026-05-21', NULL,   'event-yellow', 'a0000000-0000-0000-0000-000000000001'),
  ('Fin de Mes',               'Cierre de calificaciones',                  'FECHA_IMPORTANTE', '2026-05-29', NULL,   'event-red',    'a0000000-0000-0000-0000-000000000001');

-- ==========================================================
-- 12. DATOS INICIALES — NOTIFICACIONES
-- ==========================================================

INSERT INTO public.notificacion (id_usuario, tipo, titulo, cuerpo, leida, created_at) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'usuario',      'Nuevo registro',        'El padre Roberto Hernández se registró en la plataforma',           false, CURRENT_TIMESTAMP - INTERVAL '1 day'),
  ('a0000000-0000-0000-0000-000000000001', 'sistema',      'Actualización del sistema', 'Nueva versión disponible con mejoras en el rendimiento general',    true,  CURRENT_TIMESTAMP - INTERVAL '3 days'),
  ('a0000000-0000-0000-0000-000000000001', 'reporte',      'Reporte disponible',    'El reporte de rendimiento mensual ya está listo para descargar',     true,  CURRENT_TIMESTAMP - INTERVAL '5 days'),
  ('a0000000-0000-0000-0000-000000000001', 'mantenimiento', 'Mantenimiento programado', 'El sistema estará en mantenimiento el sábado de 2:00 a 4:00 AM',    true,  CURRENT_TIMESTAMP - INTERVAL '7 days');

-- ==========================================================
-- 13. DATOS INICIALES — ACTIVIDAD RECIENTE
-- ==========================================================

INSERT INTO public.actividad (id_usuario, accion, entidad_tipo, entidad_id, estado, created_at) VALUES
  ('a0000000-0000-0000-0000-000000000008', 'Actualizó perfil',          'usuario', 'a0000000-0000-0000-0000-000000000008', 'Completado', CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '16 hours' - INTERVAL '30 minutes'),
  ('a0000000-0000-0000-0000-000000000001', 'Registró nuevo alumno',     'alumno',  NULL,                                      'Pendiente',  CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '14 hours' - INTERVAL '20 minutes'),
  ('a0000000-0000-0000-0000-000000000009', 'Solicitó revisión',         'usuario', 'a0000000-0000-0000-0000-000000000009', 'Inactivo',   CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '11 hours' - INTERVAL '10 minutes');

-- ==========================================================
-- 14. DATOS INICIALES — CALIFICACIONES (6 alumnos × 6 materias)
-- ==========================================================

-- Diego Martínez (id_alumno = ...013)
INSERT INTO public.calificacion (id_alumno, id_materia, calificacion, periodo) VALUES
  ('a0000000-0000-0000-0000-000000000013', 1, 9.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000013', 2, 9.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000013', 3, 9.2, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000013', 4, 9.8, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000013', 5, 8.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000013', 6, 9.0, 'Bimestre 1');

-- Sofía Díaz (id_alumno = ...014)
INSERT INTO public.calificacion (id_alumno, id_materia, calificacion, periodo) VALUES
  ('a0000000-0000-0000-0000-000000000014', 1, 8.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000014', 2, 9.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000014', 3, 9.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000014', 4, 8.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000014', 5, 9.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000014', 6, 8.5, 'Bimestre 1');

-- Carlos Hernández (id_alumno = ...015)
INSERT INTO public.calificacion (id_alumno, id_materia, calificacion, periodo) VALUES
  ('a0000000-0000-0000-0000-000000000015', 1, 7.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000015', 2, 8.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000015', 3, 7.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000015', 4, 8.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000015', 5, 7.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000015', 6, 7.0, 'Bimestre 1');

-- Ana Torres (id_alumno = ...016)
INSERT INTO public.calificacion (id_alumno, id_materia, calificacion, periodo) VALUES
  ('a0000000-0000-0000-0000-000000000016', 1, 6.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000016', 2, 6.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000016', 3, 5.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000016', 4, 7.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000016', 5, 6.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000016', 6, 5.5, 'Bimestre 1');

-- Luis Díaz (id_alumno = ...017)
INSERT INTO public.calificacion (id_alumno, id_materia, calificacion, periodo) VALUES
  ('a0000000-0000-0000-0000-000000000017', 1, 9.8, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000017', 2, 9.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000017', 3, 9.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000017', 4, 9.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000017', 5, 9.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000017', 6, 9.8, 'Bimestre 1');

-- Pedro Mendoza (id_alumno = ...018)
INSERT INTO public.calificacion (id_alumno, id_materia, calificacion, periodo) VALUES
  ('a0000000-0000-0000-0000-000000000018', 1, 8.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000018', 2, 7.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000018', 3, 8.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000018', 4, 8.0, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000018', 5, 8.5, 'Bimestre 1'),
  ('a0000000-0000-0000-0000-000000000018', 6, 7.5, 'Bimestre 1');

-- ==========================================================
-- 15. DATOS INICIALES — CONFIGURACIÓN DEL ADMIN
-- ==========================================================

INSERT INTO public.configuracion (id_usuario, tema, sidebar_colapsada, idioma, notificaciones_email, notificaciones_push, registros_por_pagina, formato_fecha, zona_horaria)
VALUES (
  'a0000000-0000-0000-0000-000000000001',
  'light', false, 'Español', true, false, 25, 'DD/MM/AAAA', 'America/Mexico_City'
);

-- ==========================================================
-- 16. ACTUALIZAR PROMEDIOS (cálculo desde calificaciones)
-- ==========================================================

UPDATE public.alumno a
SET promedio = (
  SELECT ROUND(AVG(calificacion), 2)
  FROM public.calificacion c
  WHERE c.id_alumno = a.id_alumno
);

-- ==========================================================
-- 17. FUNCIONES RPC PARA CRUD DE USUARIOS (Frontend)
-- ==========================================================

CREATE OR REPLACE FUNCTION obtener_usuarios()
RETURNS JSON AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_agg(json_build_object(
    'id_usuario', u.id_usuario,
    'nombre', u.nombre,
    'apellido_paterno', u.apellido_paterno,
    'apellido_materno', u.apellido_materno,
    'correo', u.correo,
    'telefono', u.telefono,
    'rol', u.rol,
    'ultimo_acceso', u.ultimo_acceso,
    'fecha_registro', u.fecha_registro
  ) ORDER BY u.fecha_registro DESC)
  INTO v_result
  FROM public.usuario u
  WHERE u.activo = true;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION actualizar_usuario(
  p_id_usuario UUID,
  p_nombre VARCHAR,
  p_apellido_paterno VARCHAR,
  p_apellido_materno VARCHAR,
  p_correo VARCHAR,
  p_telefono VARCHAR,
  p_rol VARCHAR
) RETURNS JSON AS $$
DECLARE
  v_existe BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM public.usuario WHERE correo = p_correo AND id_usuario != p_id_usuario) INTO v_existe;
  IF v_existe THEN
    RETURN json_build_object('success', false, 'error', 'El correo ya está en uso por otro usuario');
  END IF;

  UPDATE public.usuario
  SET nombre = p_nombre,
      apellido_paterno = p_apellido_paterno,
      apellido_materno = p_apellido_materno,
      correo = p_correo,
      telefono = p_telefono,
      rol = p_rol
  WHERE id_usuario = p_id_usuario;

  RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION eliminar_usuario(p_id_usuario UUID)
RETURNS JSON AS $$
BEGIN
  UPDATE public.usuario SET activo = false WHERE id_usuario = p_id_usuario;
  RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION obtener_usuarios TO anon;
GRANT EXECUTE ON FUNCTION actualizar_usuario TO anon;
GRANT EXECUTE ON FUNCTION eliminar_usuario TO anon;

-- ==========================================================
-- 18. FUNCIONES RPC PARA REGISTRO DE PADRE CON HIJOS
-- ==========================================================

CREATE OR REPLACE FUNCTION registrar_padre_con_hijos(
  p_nombre VARCHAR,
  p_apellido_paterno VARCHAR,
  p_apellido_materno VARCHAR,
  p_correo VARCHAR,
  p_telefono VARCHAR,
  p_contrasena VARCHAR,
  p_hijos JSON
) RETURNS JSON AS $$
DECLARE
  v_id_padre UUID;
  v_hijo JSON;
  v_nombre_hijo VARCHAR;
  v_ap_pat_hijo VARCHAR;
  v_ap_mat_hijo VARCHAR;
  v_grado_hijo VARCHAR;
  v_grupo_hijo VARCHAR;
  v_parentesco VARCHAR;
  v_id_grado INTEGER;
  v_id_grupo INTEGER;
  v_id_alumno UUID;
  v_correo_alumno VARCHAR;
  v_existe_correo BOOLEAN;
  v_counter INTEGER := 0;
BEGIN
  -- Verificar si el correo del padre ya existe
  SELECT EXISTS(SELECT 1 FROM public.usuario WHERE correo = p_correo) INTO v_existe_correo;
  IF v_existe_correo THEN
    RETURN json_build_object('success', false, 'error', 'El correo ya está registrado');
  END IF;

  -- 1. Crear usuario padre
  INSERT INTO public.usuario (nombre, apellido_paterno, apellido_materno, correo, telefono, rol, contrasena)
  VALUES (p_nombre, p_apellido_paterno, p_apellido_materno, p_correo, p_telefono, 'PADRE', crypt(p_contrasena, gen_salt('bf')))
  RETURNING id_usuario INTO v_id_padre;

  -- 2. Crear registro en tabla padre
  INSERT INTO public.padre (id_padre) VALUES (v_id_padre);

  -- 3. Procesar cada hijo
  FOR v_hijo IN SELECT * FROM json_array_elements(p_hijos)
  LOOP
    v_nombre_hijo := v_hijo->>'nombre';
    v_ap_pat_hijo := v_hijo->>'apellidoPaterno';
    v_ap_mat_hijo := v_hijo->>'apellidoMaterno';
    v_grado_hijo := v_hijo->>'grado';
    v_grupo_hijo := v_hijo->>'grupo';
    v_parentesco := v_hijo->>'parentesco';

    -- Validar parentesco
    IF v_parentesco NOT IN ('MADRE', 'PADRE', 'TUTOR') THEN
      v_parentesco := 'TUTOR';
    END IF;

    -- Buscar id_grado por nombre
    SELECT id_grado INTO v_id_grado FROM public.grado WHERE nombre = v_grado_hijo;
    IF v_id_grado IS NULL THEN
      SELECT id_grado INTO v_id_grado FROM public.grado ORDER BY nivel LIMIT 1;
    END IF;

    -- Buscar id_grupo por nombre
    SELECT id_grupo INTO v_id_grupo FROM public.grupo WHERE nombre = v_grupo_hijo;
    IF v_id_grupo IS NULL THEN
      SELECT id_grupo INTO v_id_grupo FROM public.grupo LIMIT 1;
    END IF;

    -- Generar correo único para el alumno
    v_counter := v_counter + 1;
    v_correo_alumno := LOWER(REGEXP_REPLACE(v_nombre_hijo || '.' || COALESCE(v_ap_pat_hijo, 'alumno') || v_counter || '@alumno.temp', '[^a-z0-9@.]', '', 'g'));

    -- Crear usuario alumno
    INSERT INTO public.usuario (nombre, apellido_paterno, apellido_materno, correo, rol, activo, contrasena)
    VALUES (v_nombre_hijo, v_ap_pat_hijo, v_ap_mat_hijo, v_correo_alumno, 'ALUMNO', true, NULL)
    RETURNING id_usuario INTO v_id_alumno;

    -- Crear registro en tabla alumno
    INSERT INTO public.alumno (id_alumno, id_grupo)
    VALUES (v_id_alumno, v_id_grupo);

    -- Crear relación alumno-padre
    INSERT INTO public.alumno_padre (id_alumno, id_padre, parentesco)
    VALUES (v_id_alumno, v_id_padre, v_parentesco);

  END LOOP;

  RETURN json_build_object('success', true, 'id_usuario', v_id_padre);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================================
-- 19. FUNCIONES RPC PARA CRUD DE EVENTOS (Calendario)
-- ==========================================================

CREATE OR REPLACE FUNCTION obtener_eventos(p_mes INTEGER, p_anio INTEGER)
RETURNS JSON AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_agg(json_build_object(
    'id_evento', e.id_evento,
    'titulo', e.titulo,
    'descripcion', e.descripcion,
    'tipo', e.tipo,
    'fecha', e.fecha,
    'hora', e.hora,
    'color', e.color,
    'id_creador', e.id_creador
  ) ORDER BY e.fecha, e.hora)
  INTO v_result
  FROM public.evento e
  WHERE EXTRACT(MONTH FROM e.fecha) = p_mes
    AND EXTRACT(YEAR FROM e.fecha) = p_anio;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION crear_evento(
  p_titulo VARCHAR,
  p_descripcion TEXT,
  p_tipo VARCHAR,
  p_fecha DATE,
  p_hora TIME,
  p_color VARCHAR,
  p_id_creador UUID
) RETURNS JSON AS $$
DECLARE
  v_id_evento INTEGER;
BEGIN
  IF p_tipo NOT IN ('EVENTO_ESCOLAR', 'EXAMEN', 'PROYECTO', 'FECHA_IMPORTANTE') THEN
    RETURN json_build_object('success', false, 'error', 'Tipo de evento inválido');
  END IF;

  INSERT INTO public.evento (titulo, descripcion, tipo, fecha, hora, color, id_creador)
  VALUES (p_titulo, p_descripcion, p_tipo, p_fecha, p_hora, p_color, p_id_creador)
  RETURNING id_evento INTO v_id_evento;

  RETURN json_build_object('success', true, 'id_evento', v_id_evento);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION eliminar_evento(p_id_evento INTEGER)
RETURNS JSON AS $$
BEGIN
  DELETE FROM public.evento WHERE id_evento = p_id_evento;
  RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION registrar_padre_con_hijos TO anon;
GRANT EXECUTE ON FUNCTION obtener_eventos TO anon;
GRANT EXECUTE ON FUNCTION crear_evento TO anon;
GRANT EXECUTE ON FUNCTION eliminar_evento TO anon;

-- ==========================================================
-- FIN DEL SCRIPT
-- ==========================================================
-- CREDENCIALES DE PRUEBA:
--   Admin:   admin@institucion.edu / admin123
--   Docente: maria.garcia@institucion.edu / docente123
--   Padre:   ana.martinez@email.com / padre123
-- ==========================================================
