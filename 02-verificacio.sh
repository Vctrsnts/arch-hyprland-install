#!/usr/bin/env bash
set -euo pipefail

echo "== Validación de instalación NVIDIA + Wayland + Hyprland =="

# Comprobar módulo nvidia_drm con modeset
if [ -e /sys/module/nvidia_drm/parameters/modeset ]; then
  val=$(cat /sys/module/nvidia_drm/parameters/modeset)
  echo "nvidia_drm modeset = $val"
  [ "$val" = "Y" ] || [ "$val" = "1" ] || echo "❌ Modeset deshabilitado,
revisa modprobe.d"
else
  echo "❌ Módulo nvidia_drm no cargado"
fi

# Verificar servicios PipeWire
echo "== Comprobando servicios PipeWire =="
for srv in pipewire pipewire-pulse wireplumber; do
  if systemctl --user is-active "$srv" &>/dev/null; then
    echo "✔️  $srv activo"
  else
    echo "❌  $srv no está activo"
  fi
done

# Comprobar Hyprland instalado
command -v hyprland >/dev/null && echo "✔️  Hyprland instalado" || echo
"❌ Hyprland no encontrado"

# Comprobar configuración NVIDIA en Hyprland
if grep -q "GBM_BACKEND,nvidia-drm" "$HOME/.config/hypr/hyprland.conf";
then
  echo "✔️  Configuración NVIDIA detectada en Hyprland"
else
  echo "❌  No se encontró configuración NVIDIA en Hyprland"
fi

# Comprobar módulos cargados
for mod in nvidia nvidia_modeset nvidia_uvm nvidia_drm; do
  lsmod | grep -q "$mod" && echo "✔️  Módulo $mod cargado" || echo "❌ 
$mod no cargado"
done

# Comprobar initramfs configuración
grep -E 'nvidia(_| )' /etc/mkinitcpio.conf && echo "✔️  NVIDIA presente
en mkinitcpio.conf" || echo "❌  No se añadió a mkinitcpio.conf"

echo "== Validación completada ✅ =="
