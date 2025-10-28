#!/usr/bin/env bash
set -euo pipefail

# ===== Colores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ===== Variables =====
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$TARGET_USER")

# ===== Funciones =====
log_error() {
  echo -e "${RED}"
  echo "=========================================="
  echo -e "!!! Ha ocurrido un fallo en el script. Saliendo... !!!"
  echo "=========================================="
  echo -e "${NC}"
  exit 1
}
log_success() {
  echo -e "${GREEN}"
  echo "=========================================="
  echo -e "=== $1 ==="
  echo "=========================================="
  echo -e "${NC}"
}
log_info() {
  echo -e "${YELLOW}"
  echo "=========================================="
  echo -e "--- $1 ---"
  echo "=========================================="
  echo -e "${NC}"
}
pac_install(){
  pacman -S --noconfirm "$@"
}
pac_upgrade(){
  pacman -Syu --noconfirm
}

log_info "== Instalación Wayland + NVIDIA + Hyprland en Arch Linux =="

# Verifica que lo estás ejecutando como root
if [ "$(id -u)" -ne 0 ]; then
  log_success "Por favor, ejecuta este script como root o con sudo."
  exit 1
fi

### Paso 0: Detección automática del kernel y headers
log_info "== Detectando kernel actual =="

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

log_success "Kernel detectado: $KERNEL_VERSION"
log_success "Paquete de headers correspondiente: $KERNEL_HEADERS_PKG"

### Paso 1: Actualizar sistema base
log_success "== Paso 1: Actualizando sistema =="
pac_upgrade

### Paso 2: Instalar headers del kernel
log_success "== Paso 2: Instalando headers del kernel ($KERNEL_HEADERS_PKG) =="
pac_install ${KERNEL_HEADERS_PKG}

### Paso 3: Instalar Wayland y componentes básicos
echo "== Paso 3: Instalando Wayland y componentes =="
pkgs=(
  wayland
  xorg-xwayland
  wlroots
  polkit
  seatd
)
pac_install "${pkgs[@]}"

### Paso 4: Instalar drivers propietarios NVIDIA
log_success "== Paso 4: Instalando controladores NVIDIA =="
pkgs=(
  nvidia
  nvidia-utils
  lib32-nvidia-utils
  nvidia-settings
  nvidia-smi
)
pac_install "${pkgs[@]}"

### Paso 5: Configurar KMS (Kernel Mode Setting) para NVIDIA
log_success "== Paso 5: Configurando NVIDIA KMS =="
cat <<EOF > /etc/modprobe.d/nvidia-kms.conf
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF

### Paso 6: Añadir módulos NVIDIA al initramfs
log_success "== Paso 6: Añadiendo módulos NVIDIA al initramfs =="
sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm
nvidia_drm)/' /etc/mkinitcpio.conf

### Paso 7: Regenerar initramfs
echo "== Paso 7: Regenerando initramfs =="
mkinitcpio -P

### Paso 8: Instalar PipeWire (reemplazo moderno de PulseAudio)
log_success "== Paso 8: Instalando PipeWire (audio moderno) =="
pkgs=(
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
)
pac_install "${pkgs[@]}"

### Paso 9: Instalar Hyprland
log_success "== Paso 9: Instalando Hyprland =="
pkgs=(
  hyprland
  hyprpaper
  waybar
  wezterm
)
pac_install "${pkgs[@]}"

### Paso 10: Crear configuración Hyprland optimizada para NVIDIA
log_success "== Paso 10: Configurando Hyprland (optimización NVIDIA) =="
CONFIG_DIR="$HOME/.config/hypr"
mkdir -p "${CONFIG_DIR}"

chown -R "$(id -u)":"$(id -g)" "${CONFIG_DIR}"

### Paso 11: Habilitar servicios
log_success "== Paso 11: Habilitando servicios necesarios =="
systemctl enable --now seatd.service

# Activar audio (para el usuario actual)
systemctl --user enable --now pipewire pipewire-pulse wireplumber ||
true

### Paso 12: Final
log_success "== Instalación completada =="
log_success "➡️  Revisa que tu bootloader no use 'nomodeset' o 'video='."
log_success "➡️  Añade 'nvidia-drm.modeset=1' a la línea de arranque si no lo has hecho."
log_success "➡️  Reinicia para aplicar cambios."
