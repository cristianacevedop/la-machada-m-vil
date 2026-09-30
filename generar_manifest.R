# Ejecutar con Source en RStudio para crear manifest.json en esta carpeta.
ruta_script <- normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE)
ruta_publicacion <- dirname(ruta_script)
(function() {
  if (!requireNamespace("rsconnect", quietly = TRUE)) {
    stop("Falta rsconnect. Instálalo en RStudio con install.packages('rsconnect') y vuelve a ejecutar este archivo.", call. = FALSE)
  }
  directorio_anterior <- getwd()
  on.exit(setwd(directorio_anterior), add = TRUE)
  setwd(ruta_publicacion)
  rsconnect::writeManifest()
  message("manifest.json creado en: ", ruta_publicacion)
})()
