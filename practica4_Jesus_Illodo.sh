#!/bin/bash

sudo apt update -y

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root. Finalizando."
  exit 1
fi

archivoEntrada="paquetes.txt"

if [ ! -f "$archivoEntrada" ]; then
  echo "El archivo de entrada \"$archivoEntrada\" no existe. Finalizando."
  exit 1
fi

declare -A paquetes

while IFS=: read -r paquete accion; do
  paquetes["$paquete"]="$accion"
done < "$archivoEntrada"

for paquete in "${!paquetes[@]}"; do
  accion="${paquetes["$paquete"]}"

  case "$accion" in
    "add")
      resultado=$(whereis "$paquete" | grep bin | wc -l)

      if [ "$resultado" -eq 0 ]; then
        echo "Instalando $paquete..."
        sudo apt install -y "$paquete"
      else
        echo "$paquete ya está instalado. No se realizará ninguna acción."
      fi
      ;;

    "remove")
      resultado=$(whereis "$paquete" | grep bin | wc -l)

      if [ "$resultado" -gt 0 ]; then
        echo "Desinstalando $paquete..."
        sudo apt remove -y "$paquete"
        sudo apt purge -y "$paquete"
      else
        echo "$paquete no está instalado. No se realizará ninguna acción."
      fi
      ;;

    "status")
      resultado=$(whereis "$paquete" | grep bin | wc -l)

      if [ "$resultado" -gt 0 ]; then
        echo "$paquete está instalado."
      else
        echo "$paquete no está instalado."
      fi
      ;;
  esac
done
