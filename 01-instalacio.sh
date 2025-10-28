#!/usr/bin/env bash
set -euo pipefail

echo "== Instalación Wayland + NVIDIA + Hyprland en Arch Linux =="

# Verifica que lo estás ejecutando como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o con sudo."
  exit 1
fi

### Paso 0: Detección automática del kernel y headers
echo "== Detectando kernel actual =="

# Ejemplo de uname -r: 6.11.4-arch1-1 → base = "linux"
KERNEL_VERSION=$(uname -r)
KERNEL_BASE="linux"

if echo "$KERNEL_VERSION" | grep -q "lts"; then
  KERNEL_BASE="linux-lts"
elif echo "$KERNEL_VERSION" | grep -q "zen"; then
  KERNEL_BASE="linux-zen"
elif echo "$KERNEL_VERSION" | grep -q "hardened"; then
  KERNEL_BASE="linux-hardened"
fi

KERNEL_HEADERS_PKG="${KERNEL_BASE}-headers"

echo "Kernel detectado: $KERNEL_VERSION"
echo "Paquete de headers correspondiente: $KERNEL_HEADERS_PKG"

### Paso 1: Actualizar sistema base
echo "== Paso 1: Actualizando sistema =="
pacman -Syu --noconfirm

### Paso 2: Instalar headers del kernel
echo "== Paso 2: Instalando headers del kernel ($KERNEL_HEADERS_PKG) =="
pacman -S --noconfirm ${KERNEL_HEADERS_PKG}

### Paso 3: Instalar Wayland y componentes básicos
echo "== Paso 3: Instalando Wayland y componentes =="
pacman -S --noconfirm \
    wayland \
    xorg-xwayland \
    wlroots \
    polkit \
    seatd

### Paso 4: Instalar drivers propietarios NVIDIA
echo "== Paso 4: Instalando controladores NVIDIA =="
pacman -S --noconfirm \
    nvidia \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings

### Paso 5: Configurar KMS (Kernel Mode Setting) para NVIDIA
echo "== Paso 5: Configurando NVIDIA KMS =="
cat <<EOF > /etc/modprobe.d/nvidia-kms.conf
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF

### Paso 6: Añadir módulos NVIDIA al initramfs
echo "== Paso 6: Añadiendo módulos NVIDIA al initramfs =="
sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm
nvidia_drm)/' /etc/mkinitcpio.conf

### Paso 7: Regenerar initramfs
echo "== Paso 7: Regenerando initramfs =="
mkinitcpio -P

### Paso 8: Instalar PipeWire (reemplazo moderno de PulseAudio)
echo "== Paso 8: Instalando PipeWire (audio moderno) =="
pacman -S --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber

### Paso 9: Instalar Hyprland
echo "== Paso 9: Instalando Hyprland =="
pacman -S --noconfirm hyprland

### Paso 10: Crear configuración Hyprland optimizada para NVIDIA
echo "== Paso 10: Configurando Hyprland (optimización NVIDIA) =="
CONFIG_DIR="$HOME/.config/hypr"
mkdir -p "${CONFIG_DIR}"

cat <<'EOF' > "${CONFIG_DIR}/hyprland.conf"
### Hyprland configuración optimizada para NVIDIA ###

# Variables de entorno para NVIDIA
env = WLR_NO_HARDWARE_CURSORS,1
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia

# Monitor (modo automático)
monitor=,preferred,auto,1

# Modificador principal
$mod = SUPER

# Aplicaciones
bind = $mod, RETURN, exec, kitty
bind = $mod SHIFT, Q, killactive
bind = $mod SHIFT, R, reload
bind = $mod, D, exec, fuzzel
exec-once = waybar & hyprpaper & dunst

# Decoración
general {
    gaps_in = 5
    gaps_out = 15
    border_size = 2
    col.active_border = rgba(89b4faee)
    col.inactive_border = rgba(585b70aa)
}

decoration {
    blur = true
    blur_size = 8
    blur_passes = 3
    blur_new_optimizations = true
}

animations {
    enabled = true
    bezier = easeOutQuint, 0.23, 1, 0.32, 1
    animation = windows, 1, 6, easeOutQuint
    animation = fade, 1, 4, easeOutQuint
}

input {
    kb_layout = es
    follow_mouse = 1
    sensitivity = 0
}
EOF

chown -R "$(id -u)":"$(id -g)" "${CONFIG_DIR}"

### Paso 11: Habilitar servicios
echo "== Paso 11: Habilitando servicios necesarios =="
systemctl enable --now seatd.service

# Activar audio (para el usuario actual)
systemctl --user enable --now pipewire pipewire-pulse wireplumber ||
true

### Paso 12: Final
echo "== Instalación completada =="
echo "➡️  Revisa que tu bootloader no use 'nomodeset' o 'video='."
echo "➡️  Añade 'nvidia-drm.modeset=1' a la línea de arranque si no lo
has hecho."
echo "➡️  Reinicia para aplicar cambios."
