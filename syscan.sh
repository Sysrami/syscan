#!/bin/bash

# Colores
RED='\033[1;31m'
BLUE='\033[1;34m'
ITALIC='\033[3m'
NC='\033[0m' # Sin color

# Mostrar banner
clear
echo -e "${RED}"
echo "███████╗██╗   ██╗███████╗ ██████╗ █████╗ ███╗   ██╗"
echo "██╔════╝╚██╗ ██╔╝██╔════╝██╔════╝██╔══██╗████╗  ██║"
echo "███████╗ ╚████╔╝ ███████╗██║     ███████║██╔██╗ ██║"
echo "╚════██║  ╚██╔╝  ╚════██║██║     ██╔══██║██║╚██╗██║"
echo "███████║   ██║   ███████║╚██████╗██║  ██║██║ ╚████║"
echo "╚══════╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝"
echo -e "${BLUE}${ITALIC}               Autor: Facundo Ramirez${NC}"
echo ""

# Pedir IP o dominio
read -p "Ingrese la dirección IP o dominio que desea escanear: " TARGET

if [ -z "$TARGET" ]; then
    echo "[!] No se ingresó ninguna dirección. Abortando."
    exit 1
fi

echo "[*] Realizando escaneo inicial..."
nmap -p- --open -sS -Pn -n --min-rate=5000 --max-retries=1 --scan-delay 500ms "$TARGET" -oN scan1

# Extraer puertos abiertos
PORTS=$(grep -oP '^\d+/tcp\s+open' scan1 | cut -d '/' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$PORTS" ]; then
    echo "[!] No hay puertos abiertos encontrados."
    exit 0
fi

echo "[*] Puertos abiertos encontrados: $PORTS"

echo "[*] Realizando escaneo con -sCV a puertos abiertos..."
nmap -sCV -Pn  -p "$PORTS" "$TARGET" -oN scan2

echo "[*] Buscando vulnerabilidades con searchsploit..."
# Extraer posibles servicios/versiones para buscar en searchsploit
grep -Eo '[a-zA-Z0-9._/-]+ [0-9.]+\b' scan2 | while read line; do
    echo "[>] Buscando: $line"
    searchsploit "$line" >> vuln
done

echo "[✓] Escaneos completados. Resultados guardados en:"
echo "  - scan1"
echo "  - scan2"
echo "  - vuln"
