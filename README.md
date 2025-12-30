# Nokia Altiplano Image Extractor 🚀

Este script de Bash está diseñado para automatizar la extracción de nombres de imágenes de contenedores desde manifiestos de Kubernetes, archivos values.yaml de Helm y archivos de texto. 

Está optimizado para la estructura de Nokia Altiplano, donde los registros, repositorios y etiquetas suelen estar fragmentados o apuntar a registros privados de JFrog Artifactory.

## 📋 Características

* Reconstrucción Inteligente: Une pares de 'repository:' y 'tag:' que se encuentran en líneas separadas.
* Limpieza de Helm: Ignora automáticamente variables de plantilla como {{ .Values... }} que no pueden descargarse directamente.
* Normalización de Registros: Asegura que todas las imágenes lleven el prefijo del registro correcto (artifactory.net.nokia.com) sin duplicarlo.
* Filtro de Basura: Elimina rutas de archivos, comentarios, valores nulos y líneas mal formadas.
* Salida Lista para Usar: Genera un archivo 'imagenes_final.txt' con comandos 'docker pull' ejecutables.

## 🚀 Uso rápido

1. Copiar el script (generate_all_pulls.sh) en la carpeta raíz donde están tus archivos .yaml o .txt.
2. Dar permisos de ejecución:
   chmod +x generate_all_pulls.sh

3. Ejecutar el script:
   ./generate_all_pulls.sh

4. Iniciar sesión en el registro de Nokia:
   docker login artifactory.net.nokia.com

5. Ejecutar las descargas masivas:
   bash imagenes_final.txt

## 🛠️ Cómo funciona

El script realiza un escaneo recursivo buscando tres patrones clave:
1. Líneas con 'image:' (formato estándar).
2. Pares de 'repository:' seguidos de un 'tag:' (formato común en Helm).
3. Referencias directas a registros de Nokia.

El proceso elimina duplicados y descarta cualquier línea que contenga llaves de variables {{ }} o que sea una ruta de sistema de archivos.

## 📂 Archivos generados

* imagenes_final.txt: Lista depurada de comandos docker pull listos para correr.
* raw_combined.tmp: Archivo temporal de depuración (se borra automáticamente).

## ⚠️ Requisitos

* Bash (Linux, macOS o WSL).
* Utilidades estándar: grep, sed, awk.
* Acceso a la VPN/Red de Nokia para el pull de imágenes.
