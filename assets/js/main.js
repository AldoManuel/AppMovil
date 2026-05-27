/* ==========================================================
   Sistema de Gestión Educativa
   JavaScript Global Compartido
   Funcionalidades: Sidebar, Modales, Tema, Navegación
   ========================================================== */

document.addEventListener('DOMContentLoaded', function () {

  /* ==========================================================
     SIDEBAR TOGGLE
     ========================================================== */
  const sidebar = document.getElementById('sidebar');
  const sidebarToggle = document.getElementById('sidebarToggle');

  if (sidebarToggle && sidebar) {
    sidebarToggle.addEventListener('click', function () {
      sidebar.classList.toggle('collapsed');

      // Actualizar atributo aria-expanded para accesibilidad
      const isCollapsed = sidebar.classList.contains('collapsed');
      sidebarToggle.setAttribute('aria-expanded', !isCollapsed);
    });
  }

  /* ==========================================================
     TEMA CLARO / OSCURO
     ========================================================== */
  const themeToggle = document.getElementById('themeToggle');

  if (themeToggle) {
    // Cargar preferencia guardada
    const savedTheme = localStorage.getItem('app-theme');
    if (savedTheme) {
      document.documentElement.setAttribute('data-theme', savedTheme);
      themeToggle.checked = savedTheme === 'dark';
    }

    themeToggle.addEventListener('change', function () {
      const theme = this.checked ? 'dark' : 'light';
      document.documentElement.setAttribute('data-theme', theme);
      localStorage.setItem('app-theme', theme);
    });
  }

  /* ==========================================================
     NAVEGACIÓN ACTIVA
     ========================================================== */
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  const navItems = document.querySelectorAll('.nav-item');

  navItems.forEach(function (item) {
    const page = item.getAttribute('data-page');
    if (page === currentPage) {
      item.classList.add('active');
    } else {
      item.classList.remove('active');
    }
  });

  /* ==========================================================
     MODALES
     ========================================================== */
  const modalTriggers = document.querySelectorAll('[data-modal]');
  const modalCloses = document.querySelectorAll('.modal-close, .modal-overlay');

  // Abrir modal
  modalTriggers.forEach(function (trigger) {
    trigger.addEventListener('click', function (e) {
      e.preventDefault();
      const modalId = this.getAttribute('data-modal');
      const modal = document.getElementById(modalId);
      if (modal) {
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
      }
    });
  });

  // Cerrar modal
  modalCloses.forEach(function (closeEl) {
    closeEl.addEventListener('click', function () {
      const modal = this.closest('.modal-overlay');
      if (modal) {
        modal.classList.remove('show');
        document.body.style.overflow = '';
      }
    });
  });

  // Cerrar modal con tecla Escape
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      const openModal = document.querySelector('.modal-overlay.show');
      if (openModal) {
        openModal.classList.remove('show');
        document.body.style.overflow = '';
      }
    }
  });

  /* ==========================================================
     DROPDOWNS
     ========================================================== */
  const dropdownToggles = document.querySelectorAll('.dropdown-toggle');

  dropdownToggles.forEach(function (toggle) {
    toggle.addEventListener('click', function (e) {
      e.stopPropagation();
      const dropdown = this.closest('.dropdown');
      const menu = dropdown.querySelector('.dropdown-menu');

      // Cerrar otros dropdowns
      document.querySelectorAll('.dropdown-menu.show').forEach(function (m) {
        if (m !== menu) m.classList.remove('show');
      });

      menu.classList.toggle('show');
    });
  });

  // Cerrar dropdown al hacer clic fuera
  document.addEventListener('click', function () {
    document.querySelectorAll('.dropdown-menu.show').forEach(function (menu) {
      menu.classList.remove('show');
    });
  });

  /* ==========================================================
     TABS
     ========================================================== */
  const tabGroups = document.querySelectorAll('.tabs');

  tabGroups.forEach(function (tabGroup) {
    const tabs = tabGroup.querySelectorAll('.tab-item');

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        const target = this.getAttribute('data-tab');
        const parent = this.closest('[data-tab-container]') || this.parentElement.parentElement;

        // Desactivar todos los tabs del grupo
        tabGroup.querySelectorAll('.tab-item').forEach(function (t) {
          t.classList.remove('active');
        });

        // Desactivar todos los contenidos
        parent.querySelectorAll('.tab-content').forEach(function (c) {
          c.classList.remove('active');
        });

        // Activar tab y contenido
        this.classList.add('active');
        const content = document.getElementById(target);
        if (content) {
          content.classList.add('active');
        }
      });
    });
  });

  /* ==========================================================
     ALERTAS SIMULADAS
     ========================================================== */
  const alertCloses = document.querySelectorAll('.alert-close');

  alertCloses.forEach(function (closeBtn) {
    closeBtn.addEventListener('click', function () {
      const alert = this.closest('.alert');
      if (alert) {
        alert.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        alert.style.opacity = '0';
        alert.style.transform = 'translateX(20px)';
        setTimeout(function () {
          alert.remove();
        }, 300);
      }
    });
  });

  /* ==========================================================
     BÚSQUEDA EN TABLAS (Visual)
     ========================================================== */
  const searchInputs = document.querySelectorAll('.table-search');

  searchInputs.forEach(function (input) {
    input.addEventListener('input', function () {
      const query = this.value.toLowerCase();
      const table = this.closest('.table-container') || this.closest('.card') || document;
      const rows = table.querySelectorAll('table tbody tr');

      rows.forEach(function (row) {
        const text = row.textContent.toLowerCase();
        if (text.includes(query)) {
          row.style.display = '';
        } else {
          row.style.display = 'none';
        }
      });
    });
  });

  /* ==========================================================
     SIMULAR CARGA DE GRÁFICAS CON ANIMACIÓN
     ========================================================== */
  const chartBars = document.querySelectorAll('.chart-bar');

  chartBars.forEach(function (bar) {
    const targetHeight = bar.getAttribute('data-height') || '0';
    // Retraso escalonado para animación
    const delay = parseInt(bar.getAttribute('data-delay')) || 0;
    setTimeout(function () {
      bar.style.height = targetHeight + '%';
    }, delay);
  });

  /* ==========================================================
     NOTIFICACIÓN TOAST SIMULADA
     ========================================================== */
  const toastTriggers = document.querySelectorAll('[data-toast]');

  toastTriggers.forEach(function (trigger) {
    trigger.addEventListener('click', function () {
      const message = this.getAttribute('data-toast') || 'Acción simulada completada';
      showToast(message);
    });
  });

  function showToast(message) {
    // Eliminar toast previo si existe
    const prevToast = document.querySelector('.toast-notification');
    if (prevToast) prevToast.remove();

    const toast = document.createElement('div');
    toast.className = 'toast-notification';
    toast.textContent = message;

    // Estilos inline para el toast
    Object.assign(toast.style, {
      position: 'fixed',
      bottom: '24px',
      right: '24px',
      background: 'var(--bg-card, #ffffff)',
      color: 'var(--text-primary, #1f2937)',
      padding: '14px 20px',
      borderRadius: '10px',
      boxShadow: '0 8px 30px rgba(0,0,0,0.15)',
      border: '1px solid var(--border-color, #e5e7eb)',
      fontSize: '14px',
      fontWeight: '500',
      zIndex: '5000',
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      animation: 'slideUp 0.3s ease',
      borderLeft: '4px solid var(--primary, #1a73e8)'
    });

    // Icono de check
    const icon = document.createElement('span');
    icon.textContent = '✓';
    icon.style.cssText = 'color: var(--primary, #1a73e8); font-weight: 700; font-size: 16px;';
    toast.prepend(icon);

    document.body.appendChild(toast);

    // Auto cerrar después de 3 segundos
    setTimeout(function () {
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(40px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(function () {
        toast.remove();
      }, 300);
    }, 3000);
  }

  /* ==========================================================
     TOOLBAR DE ACCIONES (Editar, Eliminar, Ver)
     ========================================================== */
  document.querySelectorAll('[data-action="edit"], [data-action="delete"], [data-action="view"]').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      e.preventDefault();
      const action = this.getAttribute('data-action');
      const actionLabels = {
        edit: 'Editar',
        delete: 'Eliminar',
        view: 'Ver'
      };
      showToast(`Acción "${actionLabels[action] || action}" simulada correctamente`);
    });
  });

  /* ==========================================================
     BOTÓN AGREGAR (Simulado)
     ========================================================== */
  document.querySelectorAll('[data-action="add"]').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      e.preventDefault();
      showToast('Formulario de registro abierto (simulado)');
      // Buscar y abrir modal de agregar si existe
      const modalId = this.getAttribute('data-modal');
      if (modalId) {
        const modal = document.getElementById(modalId);
        if (modal) modal.classList.add('show');
      }
    });
  });

});
