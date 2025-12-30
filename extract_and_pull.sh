#!/bin/bash

REGISTRY_URL="artifactory.net.nokia.com"
OUTPUT_FILE="imagenes_final.txt"
TEMP_RAW="raw_combined.tmp"

echo "Escaneando y reconstruyendo imágenes (Repository + Tag)..."

# Limpiar salida
> "$TEMP_RAW"

# 1. Extraer bloques manteniendo el contexto por archivo
find . -type f \( -name "*.yaml" -o -name "*.txt" \) | while read -r file; do
    last_repo=""
    
    # Leer línea por línea del archivo original
    while read -r line; do
        # Limpiar la línea de comillas, espacios y comentarios
        clean_line=$(echo "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/["'\'']//g; s/#.*//')
        
        # Ignorar variables de Helm o líneas vacías
        [[ "$clean_line" == *"{{"* ]] && continue
        [[ -z "$clean_line" ]] && continue

        # Caso A: Es un repositorio
        if [[ "$clean_line" =~ ^repository:[[:space:]]*(.*) ]]; then
            last_repo="${BASH_REMATCH[1]}"
            # Si el repo ya tiene el tag incluido (formato repo:tag)
            if [[ "$last_repo" == *":"* ]]; then
                echo "$last_repo" >> "$TEMP_RAW"
                last_repo=""
            fi
        
        # Caso B: Es un tag (y tenemos un repo guardado)
        elif [[ "$clean_line" =~ ^tag:[[:space:]]*(.*) ]]; then
            current_tag="${BASH_REMATCH[1]}"
            if [[ -n "$last_repo" && "$current_tag" != "null" ]]; then
                echo "${last_repo}:${current_tag}" >> "$TEMP_RAW"
                last_repo="" # Reset tras unir
            fi

        # Caso C: Es una imagen completa (image: repo:tag)
        elif [[ "$clean_line" =~ ^image:[[:space:]]*(.*) ]]; then
            echo "${BASH_REMATCH[1]}" >> "$TEMP_RAW"
        fi
        
    done < "$file"
done

# 2. Formatear y añadir el registro si falta
echo "Finalizando formato de comandos..."
sort -u "$TEMP_RAW" | while read -r img; do
    # Eliminar el registro si ya viene duplicado en el string
    clean_img=$(echo "$img" | sed "s|$REGISTRY_URL/||g")
    
    # Solo procesar si tiene un tag (contiene :)
    if [[ "$clean_img" == *":"* ]]; then
        echo "docker pull ${REGISTRY_URL}/${clean_img}"
    fi
done > "$OUTPUT_FILE"

# 3. Limpieza de seguridad para caracteres extraños
sed -i 's|//|/|g' "$OUTPUT_FILE"

echo "----------------------------------------------------------"
echo "PROCESO COMPLETADO"
echo "Archivo generado: $OUTPUT_FILE"
echo "Total de imágenes encontradas: $(wc -l < "$OUTPUT_FILE")"
echo "----------------------------------------------------------"
head -n 10 "$OUTPUT_FILE"