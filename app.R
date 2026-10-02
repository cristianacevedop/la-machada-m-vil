# Entrada para publicar en Posit Connect Cloud.
# Las credenciales deben configurarse como variables secretas en el servicio;
# nunca se escriben en este archivo ni se incluyen en el repositorio.
Sys.setenv(FINCA_DB_BACKEND = "postgres")

variables_requeridas <- c(
  "FINCA_DB_HOST", "FINCA_DB_NAME", "FINCA_DB_USER",
  "FINCA_DB_PASSWORD", "FINCA_DB_SCHEMA", "FINCA_APP_PASSWORD"
)
variables_vacias <- variables_requeridas[
  !nzchar(Sys.getenv(variables_requeridas, unset = ""))
]
if (length(variables_vacias)) {
  stop(
    "Faltan variables secretas de conexión: ",
    paste(variables_vacias, collapse = ", "),
    call. = FALSE
  )
}

source("celular.R", local = TRUE)$value
