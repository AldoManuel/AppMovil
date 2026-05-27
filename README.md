# TaskTracker — Sistema de Gestión Educativa

Panel administrativo educativo para la gestión de docentes, alumnos, padres de familia, calendario y reportes.

## Tecnologías

- **HTML5** — 10 páginas estructuradas
- **CSS3** — Diseño responsive, tema claro/oscuro, animaciones
- **JavaScript Vanilla** — Sidebar, modales, tabs, búsqueda, toasts, tema oscuro

## Pantallas

| Ruta | Descripción |
|---|---|
| `index.html` | Inicio de sesión |
| `dashboard.html` | Panel principal con estadísticas |
| `usuarios.html` | Gestión de usuarios |
| `docentes.html` | Perfiles de docentes |
| `padres.html` | Registro de padres |
| `alumnos.html` | Perfiles de alumnos |
| `calendario.html` | Calendario escolar (solo vista) |
| `notificaciones.html` | Centro de notificaciones |
| `reportes.html` | Estadísticas y reportes |
| `configuracion.html` | Ajustes del sistema |

## Estructura

```
AppMovil/
├── index.html
├── dashboard.html
├── *.html              (páginas del sistema)
├── assets/
│   ├── css/style.css
│   ├── js/main.js
│   ├── img/
│   └── icons/
├── controllers/        (preparado para MVC)
├── models/             (preparado para MVC)
└── views/              (preparado para MVC)
```

## Uso

Abrir cualquier archivo `.html` en un navegador. El login (`index.html`) redirige a `dashboard.html`.

> Proyecto frontend estático — sin backend, sin base de datos, sin dependencias externas.
