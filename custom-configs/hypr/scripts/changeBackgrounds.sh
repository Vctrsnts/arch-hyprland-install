#!/usr/bin/env bash

# Carpeta donde guardas tus fondos
WALLPAPER_DIR="$HOME/.config/backgrounds/"

# Intervalo en segundos (ej: 300 = 5 minutos)
INTERVAL=60

while true; do
  # Seleccionar un fondo aleatorio
  WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

  # Aplicar el fondo a todos los monitores
  hyprctl hyprpaper reload ,"$WALLPAPER"

  # Esperar el intervalo antes de cambiar de nuevo
  sleep $INTERVAL
done

