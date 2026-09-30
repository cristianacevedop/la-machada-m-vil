# Paquete de publicación móvil

Esta carpeta contiene una copia depurada de la aplicación Shiny móvil. No incluye
la base SQLite, archivos de respaldo, scripts de migración ni credenciales. La
app se conecta únicamente a PostgreSQL mediante variables de entorno.

## Antes de publicar

1. No subas la carpeta completa del proyecto de finca: publica únicamente el
   contenido de esta carpeta en un repositorio nuevo de GitHub.
2. No añadas `.Renviron`, archivos `.sqlite`/`.db`, respaldos ni tokens.
3. Desde RStudio, establece esta carpeta como directorio de trabajo y genera el
   manifiesto con `rsconnect::writeManifest()`. El archivo `manifest.json` debe
   quedar aquí, junto a `app.R`.
4. En Posit Connect Cloud, configura como variables secretas:
   `FINCA_DB_BACKEND=postgres`, `FINCA_DB_HOST`, `FINCA_DB_PORT`,
   `FINCA_DB_NAME`, `FINCA_DB_USER`, `FINCA_DB_PASSWORD` y
   `FINCA_DB_SCHEMA`. No pegues la contraseña en archivos del proyecto, GitHub,
   capturas ni mensajes.
   Para `FINCA_DB_USER`, crea y usa una cuenta PostgreSQL exclusiva para la app
   con permisos mínimos; no uses la cuenta administrativa `postgres`.
5. Configura el acceso de la app para que solo entren las personas autorizadas
   antes de compartir su enlace.

La carpeta está preparada, pero no se ha publicado ni se ha conectado aún al
repositorio de GitHub o a Posit Connect Cloud.
