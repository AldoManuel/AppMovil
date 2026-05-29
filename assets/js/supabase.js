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
