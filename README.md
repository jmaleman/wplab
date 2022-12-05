# WPLAB
Laboratorio WordPress.

## Contenido

### wpcli
Automatización de tareas con WP-CLI (Interfaz de línea de comandos para WordPress).

#### wpcli_new_install
- Versión: 0.1
- Objetivo: Realiza una instalación nueva automatizada en entorno DDEV y WP-CLI.
- Requisitos:
  - BASH terminal.
  - DDEV.

- Funcionalidades:
  - Descarga la última versión de WordPress (locale ES_es por defecto).
  - Elimina ciertos ficheros innecesarios como "wp-config-smaple.php".
  - ~~Añade entrada NFS para el proyecto.~~ (Mutagen)
  - Instalación automática de WordPress.
  - Añade algunos parámetros como WP_DEBUG(true), WP_MEMORY_LIMIT(256M), WP_POST_REVISIONS(10)
  - Elimina Themes, Posts, Pages o comentarios que vienen por defecto.
  - Ajuste de permalinks "/%postname%/".
## Enlaces interesantes

### WP-CLI

- [WP-CLI](https://wp-cli.org/es/)


###
 - [DDEV](https://ddev.com/)

### BASH
 - [tput](https://linuxcommand.org/lc3_adv_tput.php)