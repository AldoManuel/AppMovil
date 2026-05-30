console.log('[Supabase] Inicializando cliente...')

const SUPABASE_URL = 'https://felrasjmigeewkxadjow.supabase.co'
const SUPABASE_ANON_KEY = 'sb_publishable_tVNs_JESXmIUOPtg_jNahQ_2kA9zy6S'

if (!window.__sbClient) {
  console.log('[Supabase] Creando nuevo cliente...')
  window.__sbClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  console.log('[Supabase] Cliente inicializado exitosamente')
} else {
  console.log('[Supabase] Cliente ya existente, reutilizando...')
}

async function iniciarSesion(correo, contrasena) {
  console.log('[Auth] Intentando login con:', correo)
  const { data, error } = await window.__sbClient.rpc('iniciar_sesion', {
    p_correo: correo,
    p_contrasena: contrasena
  })
  if (error) throw error
  console.log('[Auth] Respuesta de login:', data)
  return data
}

async function registrarUsuario(datos) {
  console.log('[Auth] Registrando usuario:', datos.correo, '- Rol:', datos.rol)
  const { data, error } = await window.__sbClient.rpc('registrar_usuario', {
    p_nombre: datos.nombre,
    p_apellido_paterno: datos.apellidoPaterno || null,
    p_apellido_materno: datos.apellidoMaterno || null,
    p_correo: datos.correo,
    p_telefono: datos.telefono || null,
    p_rol: datos.rol,
    p_contrasena: datos.contrasena
  })
  if (error) throw error
  console.log('[Auth] Respuesta de registro:', data)
  return data
}

async function obtenerUsuarios() {
  console.log('[Supabase] Obteniendo usuarios...')
  const { data, error } = await window.__sbClient.rpc('obtener_usuarios')
  if (error) throw error
  console.log('[Supabase] Usuarios obtenidos:', data?.length || 0)
  return data || []
}

async function actualizarUsuario(id, datos) {
  console.log('[Supabase] Actualizando usuario:', id)
  const { data, error } = await window.__sbClient.rpc('actualizar_usuario', {
    p_id_usuario: id,
    p_nombre: datos.nombre,
    p_apellido_paterno: datos.apellidoPaterno || null,
    p_apellido_materno: datos.apellidoMaterno || null,
    p_correo: datos.correo,
    p_telefono: datos.telefono || null,
    p_rol: datos.rol
  })
  if (error) throw error
  console.log('[Supabase] Respuesta actualización:', data)
  return data
}

async function eliminarUsuario(id) {
  console.log('[Supabase] Eliminando usuario:', id)
  const { data, error } = await window.__sbClient.rpc('eliminar_usuario', {
    p_id_usuario: id
  })
  if (error) throw error
  console.log('[Supabase] Respuesta eliminación:', data)
  return data
}

async function registrarPadreConHijos(datosPadre, hijos) {
  console.log('[Supabase] Registrando padre con', hijos.length, 'hijos')
  const { data, error } = await window.__sbClient.rpc('registrar_padre_con_hijos', {
    p_nombre: datosPadre.nombre,
    p_apellido_paterno: datosPadre.apellidoPaterno || null,
    p_apellido_materno: datosPadre.apellidoMaterno || null,
    p_correo: datosPadre.correo,
    p_telefono: datosPadre.telefono || null,
    p_contrasena: datosPadre.contrasena,
    p_hijos: hijos
  })
  if (error) throw error
  console.log('[Supabase] Respuesta registro padre:', data)
  return data
}

async function obtenerPadresConHijos() {
  console.log('[Supabase] Obteniendo padres con hijos...')
  const { data, error } = await window.__sbClient.rpc('obtener_padres_con_hijos')
  if (error) throw error
  console.log('[Supabase] Padres obtenidos:', data?.length || 0)
  return data || []
}

async function actualizarPadreConHijos(idPadre, datosPadre, hijos) {
  console.log('[Supabase] Actualizando padre:', idPadre)
  const { data, error } = await window.__sbClient.rpc('actualizar_padre_con_hijos', {
    p_id_padre: idPadre,
    p_nombre: datosPadre.nombre,
    p_apellido_paterno: datosPadre.apellidoPaterno || null,
    p_apellido_materno: datosPadre.apellidoMaterno || null,
    p_correo: datosPadre.correo,
    p_telefono: datosPadre.telefono || null,
    p_direccion: datosPadre.direccion || null,
    p_hijos: hijos
  })
  if (error) throw error
  console.log('[Supabase] Respuesta actualización padre:', data)
  return data
}

async function obtenerEventos(mes, anio) {
  console.log('[Supabase] Obteniendo eventos para:', mes, anio)
  const { data, error } = await window.__sbClient.rpc('obtener_eventos', {
    p_mes: mes,
    p_anio: anio
  })
  if (error) throw error
  return data || []
}

async function crearEvento(datos) {
  console.log('[Supabase] Creando evento:', datos.titulo)
  const { data, error } = await window.__sbClient.rpc('crear_evento', {
    p_titulo: datos.titulo,
    p_descripcion: datos.descripcion || null,
    p_tipo: datos.tipo,
    p_fecha: datos.fecha,
    p_hora: datos.hora || null,
    p_color: datos.color,
    p_id_creador: datos.idCreador
  })
  if (error) throw error
  console.log('[Supabase] Respuesta crear evento:', data)
  return data
}

async function eliminarEvento(id) {
  console.log('[Supabase] Eliminando evento:', id)
  const { data, error } = await window.__sbClient.rpc('eliminar_evento', {
    p_id_evento: id
  })
  if (error) throw error
  console.log('[Supabase] Respuesta eliminar evento:', data)
  return data
}

async function obtenerDocentes() {
  console.log('[Supabase] Obteniendo docentes...')
  const { data, error } = await window.__sbClient.rpc('obtener_docentes')
  if (error) throw error
  console.log('[Supabase] Docentes obtenidos:', data?.length || 0)
  return data || []
}

/* ==========================================================
   FUNCIONES DE ASIGNACIÓN (Docente - Grupo - Materia)
   ========================================================== */

async function obtenerMaterias() {
  const { data, error } = await window.__sbClient.rpc('obtener_materias')
  if (error) throw error
  return data || []
}

async function crearMateria(nombre) {
  const { data, error } = await window.__sbClient.rpc('crear_materia', { p_nombre: nombre })
  if (error) throw error
  return data
}

async function eliminarMateria(id) {
  const { data, error } = await window.__sbClient.rpc('eliminar_materia', { p_id_materia: id })
  if (error) throw error
  return data
}

async function asignarMateriasDocente(idDocente, materias) {
  const { data, error } = await window.__sbClient.rpc('asignar_materias_docente', {
    p_id_docente: idDocente,
    p_materias: materias
  })
  if (error) throw error
  return data
}

async function asignarDocenteGrupo(idDocente, idGrado, idGrupo, idMateria) {
  const { data, error } = await window.__sbClient.rpc('asignar_docente_grupo', {
    p_id_docente: idDocente,
    p_id_grado: idGrado,
    p_id_grupo: idGrupo,
    p_id_materia: idMateria
  })
  if (error) throw error
  return data
}

async function obtenerAsignacionesGrupoPorDocente(idDocente) {
  const { data, error } = await window.__sbClient.rpc('obtener_asignaciones_grupo_por_docente', {
    p_id_docente: idDocente
  })
  if (error) throw error
  return data || []
}

async function asignarDocenteAlumno(idDocente, idAlumno, idMateria) {
  const { data, error } = await window.__sbClient.rpc('asignar_docente_alumno', {
    p_id_docente: idDocente,
    p_id_alumno: idAlumno,
    p_id_materia: idMateria
  })
  if (error) throw error
  return data
}

async function obtenerAsignacionesAlumnoPorDocente(idDocente) {
  const { data, error } = await window.__sbClient.rpc('obtener_asignaciones_alumno_por_docente', {
    p_id_docente: idDocente
  })
  if (error) throw error
  return data || []
}

async function eliminarAsignacionDocente(idAsignacion, tipo) {
  const { data, error } = await window.__sbClient.rpc('eliminar_asignacion_docente', {
    p_id_asignacion: idAsignacion,
    p_tipo: tipo
  })
  if (error) throw error
  return data
}

async function obtenerGrados() {
  const { data, error } = await window.__sbClient.rpc('obtener_grados')
  if (error) throw error
  return data || []
}

async function obtenerGrupos() {
  const { data, error } = await window.__sbClient.rpc('obtener_grupos')
  if (error) throw error
  return data || []
}

async function obtenerAlumnos() {
  const { data, error } = await window.__sbClient.rpc('obtener_alumnos')
  if (error) throw error
  return data || []
}

async function actualizarModoAsignacion(modo) {
  const { data, error } = await window.__sbClient.rpc('actualizar_modo_asignacion', { p_modo: modo })
  if (error) throw error
  return data
}

async function obtenerConfiguracionAdmin() {
  const { data, error } = await window.__sbClient.rpc('obtener_configuracion_admin')
  if (error) throw error
  return data
}

async function obtenerConteoAlumnosPorDocente() {
  const { data, error } = await window.__sbClient.rpc('obtener_conteo_alumnos_por_docente')
  if (error) throw error
  return data || []
}

async function obtenerNotificaciones() {
  console.log('[Supabase] Obteniendo notificaciones...')
  try {
    const [eventos, usuarios] = await Promise.all([
      window.__sbClient.rpc('obtener_eventos', { p_mes: new Date().getMonth() + 1, p_anio: new Date().getFullYear() }),
      window.__sbClient.rpc('obtener_usuarios')
    ])
    if (eventos.error) throw eventos.error
    if (usuarios.error) throw usuarios.error

    const hoy = new Date()
    const notificaciones = []

    const eventosData = eventos.data || []
    eventosData.forEach(function (ev) {
      const fechaEv = new Date(ev.fecha + 'T00:00:00')
      notificaciones.push({
        id: 'ev_' + ev.id_evento,
        titulo: ev.titulo,
        descripcion: ev.descripcion || '',
        tipo: 'evento',
        subtipo: ev.tipo || 'EVENTO_ESCOLAR',
        fecha: ev.fecha,
        hora: ev.hora || null,
        leida: false,
        color: ev.color || 'event-blue',
        timestamp: fechaEv
      })
    })

    const usuariosData = usuarios.data || []
    usuariosData.forEach(function (u) {
      notificaciones.push({
        id: 'usr_' + u.id_usuario,
        titulo: (u.nombre || '') + (u.apellido_paterno ? ' ' + u.apellido_paterno : ''),
        descripcion: u.rol === 'DOCENTE' ? 'Nuevo docente registrado' : u.rol === 'PADRE' ? 'Nuevo padre registrado' : 'Nuevo usuario registrado',
        tipo: 'usuario',
        subtipo: u.rol,
        fecha: u.fecha_creacion ? u.fecha_creacion.split('T')[0] : '',
        hora: null,
        leida: false,
        color: u.rol === 'DOCENTE' ? 'event-blue' : u.rol === 'PADRE' ? 'event-yellow' : 'event-green',
        timestamp: u.fecha_creacion ? new Date(u.fecha_creacion) : hoy
      })
    })

    notificaciones.sort(function (a, b) { return b.timestamp - a.timestamp })

    console.log('[Supabase] Notificaciones obtenidas:', notificaciones.length)
    return notificaciones
  } catch (err) {
    console.error('[Supabase] Error obteniendo notificaciones:', err)
    return []
  }
}
