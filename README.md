# 🖌️  Módulo: Aplicación Automática de Tema e Iconos GTK

![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-white?logo=debian) ![Hyprland version](https://img.shields.io/badge/Hyprland-0.41.2-white?logo=hyprland)



A partir de la instalación de **Debian GNU/Linux testing** se ejecutan una serie de scripts para dejar el sistema configurado de la siguiente manera:
- `00-preparacio.sh` realiza la actualización de **Debian GNU/Linux testing** a **unstable**
  - Elimina paquetes no necesarios.
- `01-install-hyprland.sh` realiza la instalación, configuración de **Wayland** y **Hyprland**.
  - A la hora de realizar la configuración se usan los siguientes temas:
    - **TEMA:** *Nordic-Dark*
    - **ICONOS:** *Colloid-Nord-Dark*
- `02-post-install.sh` realiza la instalación y configuración de las aplicaciones que nos pueden servir.
  - En este caso, instala y configura el gestor de sesiones **greetd** y el cliente **gtkgreet** configurado para que se asemeje lo maximo posible al tema Nord.
Este módulo script realiza la instalación y configuración, minima, para el correcto funcionamiento de **Wayland** y **hyprland** en una instalación limpia de Debian Unstable.aplica automáticamente el tema GTK, los iconos, la fuente y el cu
rsor definidos en tu archivo `modules.conf`, evitando modificar el script cada vez que cambias de estilo. Es compatible con **GTK2** y **GTK3**.

---

## 📖 Explicación del script

- **Propósito:** Centralizar la instalación y configuración visual del sistema.
- **Qué aplica:** Tema GTK, paquete de iconos, fuente, tema de cursor y tamaño de cursor.

---

## ⚙️ Funcionamiento

1. Descarga de esta (https://raw.githubusercontent.com/Vctrsnts/debian-hyprland-install/refs/heads/master/00-preparacio.sh) el script de preparación de la instalación:
    - El sistema, actualmente se realiza desde una instalación de **Debian GNU/Linux testing** (forky)
    - Durante la preparación, pregunta el nombre de la versión, para substituir por **testing**.
    - Posteriormente cambia a **unstable**.
    - Para finalizar, elimina aplicaciones no necesarias.
    - Descarga el resto de script para su posterior uso `debian-hyprland-install.zip`.
2. Mediante el script `01-install-hyprland.sh` se realiza la instalación y configuración del sistema.
    - Dentro del directorio `custom-configs` puedes encontrar los ficheros de configuración para dejar el sistema con el tema **Nordic-Dark**.
3. Mediante el script `02-post-install.sh` finaliza la instalación, instalando aplicaciones que se han creido necesarias y sus configuraciones.

---
**Valores por defecto:**

| Variable            | Defecto             |
|---------------------|---------------------|
| THEME_DARK_NAME     | `Nordic-Dark`       |
| ICON_DARK_NAME      | `Colloid-Nord-Dark` |
| GTK_FONT_NAME       | `Sans 10`           |
| GTK_CURSOR_THEME    | `Breeze`            |
| GTK_CURSOR_SIZE     | `24`                |

> 💡 Los nombres deben coincidir con los instalados en el sistema:
> - Temas GTK: `/usr/share/themes` o `~/.themes`
> - Iconos: `/usr/share/icons` o `~/.icons`

---

## 🚀 Instalación y uso

Estructura sugerida:


Pasos:


---

## 🧩 Ejemplo de cambio rápido de estilo

---

## 🛟 Solución de problemas
