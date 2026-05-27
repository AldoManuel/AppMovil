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
