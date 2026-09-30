ruta_base <- normalizePath(file.path("database", "finca.sqlite"), mustWork = FALSE)

backend_base <- function() {
  # La copia móvil trabaja con la base compartida de Supabase por defecto.
  # SQLite sigue disponible solo cuando se selecciona explícitamente para
  # tareas locales o recuperación, evitando escribir sin querer en otra base.
  backend <- tolower(trimws(Sys.getenv("FINCA_DB_BACKEND", "postgres")))
  if (!backend %in% c("sqlite", "postgres")) {
    stop("FINCA_DB_BACKEND debe ser 'sqlite' o 'postgres'.")
  }
  backend
}

es_conexion_postgres <- function(conexion) inherits(conexion, "PqConnection")

# DBI/RPostgres usan parámetros $1, $2... mientras el código histórico de la
# app utiliza ?. La conversión solo se aplica en modo PostgreSQL; SQLite queda
# intacta. En las consultas actuales, ? se reserva exclusivamente a parámetros.
preparar_sql_postgres <- function(sql, params = NULL) {
  sql <- gsub("date[[:space:]]*\\([[:space:]]*'now'[[:space:]]*,[[:space:]]*'localtime'[[:space:]]*\\)",
              "CURRENT_DATE::text", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("date[[:space:]]*\\([[:space:]]*'now'[[:space:]]*,[[:space:]]*'\\+90 days'[[:space:]]*\\)",
              "(CURRENT_DATE + 90)::text", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("datetime[[:space:]]*\\([[:space:]]*'now'[[:space:]]*\\)",
              "CURRENT_TIMESTAMP::text", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("date[[:space:]]*\\([[:space:]]*'now'[[:space:]]*\\)",
              "CURRENT_DATE::text", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("strftime[[:space:]]*\\([[:space:]]*'%Y-%m'[[:space:]]*,[[:space:]]*'now'[[:space:]]*\\)",
              "to_char(CURRENT_DATE, 'YYYY-MM')", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("strftime[[:space:]]*\\([[:space:]]*'%Y-%m'[[:space:]]*,[[:space:]]*([^()]*)\\)",
              "to_char(CAST(\\1 AS date), 'YYYY-MM')", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("date[[:space:]]*\\(([^()]*)\\)", "CAST(\\1 AS date)", sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("HAVING[[:space:]]+Cantidad[[:space:]]*>[[:space:]]*0",
              "HAVING COALESCE(SUM(CASE m.tipo_codigo WHEN 'ENTRADA' THEN m.cantidad WHEN 'DEVOLUCION' THEN m.cantidad WHEN 'AJUSTE_POSITIVO' THEN m.cantidad ELSE -m.cantidad END),0) > 0",
              sql, ignore.case = TRUE, perl = TRUE)
  sql <- gsub("`([^`]+)`", "\"\\1\"", sql, perl = TRUE)

  n_parametros <- if (is.null(params)) 0L else length(params)
  encontrados <- lengths(regmatches(sql, gregexpr("\\?", sql, perl = TRUE)))
  if (encontrados != n_parametros) {
    stop("La consulta PostgreSQL tiene ", encontrados, " marcadores '?' y ",
         n_parametros, " parámetros.", call. = FALSE)
  }
  if (n_parametros) {
    posiciones <- gregexpr("?", sql, fixed = TRUE)[[1]]
    sql_preparado <- character(0)
    inicio <- 1L
    for (i in seq_len(n_parametros)) {
      posicion <- posiciones[[i]]
      sql_preparado <- c(sql_preparado,
        if (posicion > inicio) substr(sql, inicio, posicion - 1L) else "",
        paste0("$", i))
      inicio <- posicion + 1L
    }
    sufijo <- if (inicio <= nchar(sql)) substr(sql, inicio, nchar(sql)) else ""
    sql <- paste0(paste0(sql_preparado, collapse = ""), sufijo)
  }
  sql
}

# Compatibilidad centralizada: no obliga a reescribir todas las consultas ni
# altera el comportamiento SQLite. Los parámetros siguen siendo enlazados.
dbGetQuery <- function(conn, statement, params = NULL, ...) {
  postgres <- es_conexion_postgres(conn)
  sql_original <- statement
  if (postgres) statement <- preparar_sql_postgres(statement, params)
  resultado <- if (is.null(params)) {
    DBI::dbGetQuery(conn, statement, ...)
  } else {
    DBI::dbGetQuery(conn, statement, params = params, ...)
  }

  # PostgreSQL lowercases unquoted aliases, mientras SQLite conserva su
  # capitalización. Restáurala para que las tablas y los accesos datos$Total,
  # datos$Fecha, etc. sigan comportándose igual en ambos backends.
  if (postgres && ncol(resultado)) {
    coincidencias <- gregexpr(
      "\\bAS[[:space:]]+[A-Z][A-Za-z0-9_]*\\b", sql_original, perl = TRUE
    )
    aliases <- if (length(coincidencias[[1]]) && coincidencias[[1]][[1]] > 0L) {
      regmatches(sql_original, coincidencias)[[1]]
    } else {
      character(0)
    }
    aliases <- sub("^\\bAS[[:space:]]+", "", aliases, perl = TRUE)
    tipos_sql <- c("INTEGER", "BIGINT", "SMALLINT", "TEXT", "NUMERIC", "REAL",
                   "DATE", "TIMESTAMP", "BOOLEAN", "DOUBLE", "VARCHAR", "CHAR")
    aliases <- aliases[!toupper(aliases) %in% tipos_sql]
    for (alias in aliases) {
      indice <- which(names(resultado) == tolower(alias))
      if (length(indice) == 1L) names(resultado)[indice] <- alias
    }
  }
  resultado
}

dbExecute <- function(conn, statement, params = NULL, ...) {
  if (es_conexion_postgres(conn)) statement <- preparar_sql_postgres(statement, params)
  if (is.null(params)) DBI::dbExecute(conn, statement, ...) else DBI::dbExecute(conn, statement, params = params, ...)
}

insertar_con_id <- function(conexion, sql, params, columna_id) {
  if (es_conexion_postgres(conexion)) {
    consulta <- paste0(sub(";[[:space:]]*$", "", sql), " RETURNING ",
                       as.character(DBI::dbQuoteIdentifier(conexion, columna_id)), " AS id")
    return(dbGetQuery(conexion, consulta, params = params)$id[[1]])
  }
  dbExecute(conexion, sql, params = params)
  dbGetQuery(conexion, "SELECT last_insert_rowid() AS id")$id[[1]]
}

abrir_base <- function(ruta) {
  if (identical(backend_base(), "postgres")) {
    if (!requireNamespace("RPostgres", quietly = TRUE)) stop("Instala RPostgres antes de usar PostgreSQL.")
    requeridas <- c("FINCA_DB_HOST", "FINCA_DB_NAME", "FINCA_DB_USER", "FINCA_DB_PASSWORD", "FINCA_DB_SCHEMA")
    valores <- Sys.getenv(requeridas, unset = "")
    names(valores) <- requeridas
    vacias <- names(valores)[!nzchar(valores)]
    if (length(vacias)) stop(
      "Falta la configuración segura de Supabase: ", paste(vacias, collapse = ", "),
      ". Para iniciar la copia móvil, ejecuta con Source iniciar_celular_supabase.R; no pegues la contraseña en el código."
    )
    puerto <- suppressWarnings(as.integer(Sys.getenv("FINCA_DB_PORT", "5432")))
    if (is.na(puerto) || puerto < 1L || puerto > 65535L) stop("FINCA_DB_PORT no es válido.")
    conexion <- DBI::dbConnect(
      RPostgres::Postgres(), host = valores[["FINCA_DB_HOST"]], port = puerto,
      dbname = valores[["FINCA_DB_NAME"]], user = valores[["FINCA_DB_USER"]],
      password = valores[["FINCA_DB_PASSWORD"]], sslmode = "require"
    )
    esquema_sql <- as.character(DBI::dbQuoteIdentifier(conexion, valores[["FINCA_DB_SCHEMA"]]))
    DBI::dbExecute(conexion, paste0("SET search_path TO ", esquema_sql, ", public"))
    return(conexion)
  }

  conexion <- dbConnect(SQLite(), ruta)
  dbExecute(conexion, "PRAGMA foreign_keys = ON")
  # Ajustes seguros para una app local de un solo usuario: menos esperas y menos
  # escrituras innecesarias, manteniendo la durabilidad de la base SQLite.
  dbExecute(conexion, "PRAGMA busy_timeout = 5000")
  dbExecute(conexion, "PRAGMA synchronous = NORMAL")
  dbExecute(conexion, "PRAGMA temp_store = MEMORY")
  dbExecute(conexion, "PRAGMA cache_size = -16000")
  dbExecute(conexion, "CREATE TABLE IF NOT EXISTS eventos_destete (destete_id INTEGER PRIMARY KEY, animal_id TEXT NOT NULL REFERENCES animales(animal_id), fecha TEXT NOT NULL, observaciones TEXT, anulado_en TEXT, motivo_anulacion TEXT)")
  # Permitir reutilizar un arete cuando el animal anterior fue borrado lógicamente.
  dbExecute(conexion, "DROP INDEX IF EXISTS uq_animales_arete_hierro")
  dbExecute(conexion, "CREATE UNIQUE INDEX IF NOT EXISTS uq_animales_arete_hierro ON animales(arete_hierro) WHERE arete_hierro IS NOT NULL AND anulado_en IS NULL")
  dbExecute(conexion, "CREATE TABLE IF NOT EXISTS ajustes_sistema (clave TEXT PRIMARY KEY, aplicado_en TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)")
  ajuste_fecha <- dbGetQuery(conexion, "SELECT 1 FROM ajustes_sistema WHERE clave='correccion_fecha_registro_local' LIMIT 1")
  if (nrow(ajuste_fecha) == 0L) {
    dbExecute(conexion, "UPDATE animales SET fecha_registro=date(fecha_registro,'-1 day') WHERE fecha_registro IS NOT NULL")
    dbExecute(conexion, "INSERT INTO ajustes_sistema(clave) VALUES ('correccion_fecha_registro_local')")
  }
  # Limpieza conservadora de fechas asignadas por defecto: solo las que coinciden
  # exactamente con el día de registro del animal.
  dbExecute(conexion, "UPDATE animales SET fecha_nacimiento=NULL WHERE anulado_en IS NULL AND fecha_nacimiento IS NOT NULL AND (date(fecha_nacimiento)=date(fecha_registro) OR date(fecha_nacimiento)=date(fecha_registro,'+1 day') OR date(fecha_nacimiento)=date(fecha_registro,'-1 day'))")
  aplicar_actualizacion_historial(conexion)
  conexion
}

# Una fecha de salida igual a la entrada siguiente representa un traslado el mismo día.
aplicar_actualizacion_historial <- function(conexion) {
  dbExecute(conexion, "DROP TRIGGER IF EXISTS tr_grupo_sin_solape")
  dbExecute(conexion, "
    CREATE TRIGGER tr_grupo_sin_solape BEFORE INSERT ON animal_grupo_historial
    WHEN EXISTS (SELECT 1 FROM animal_grupo_historial h WHERE h.animal_id=NEW.animal_id AND h.anulado_en IS NULL
      AND COALESCE(h.fecha_fin,'9999-12-31') > NEW.fecha_inicio AND COALESCE(NEW.fecha_fin,'9999-12-31') > h.fecha_inicio)
    BEGIN SELECT RAISE(ABORT,'Un animal no puede pertenecer a dos grupos al mismo tiempo'); END")
  dbExecute(conexion, "DROP TRIGGER IF EXISTS tr_ubicacion_sin_solape")
  dbExecute(conexion, "
    CREATE TRIGGER tr_ubicacion_sin_solape BEFORE INSERT ON animal_ubicacion_historial
    WHEN EXISTS (SELECT 1 FROM animal_ubicacion_historial h WHERE h.animal_id=NEW.animal_id AND h.anulado_en IS NULL
      AND COALESCE(h.fecha_fin,'9999-12-31') > NEW.fecha_inicio AND COALESCE(NEW.fecha_fin,'9999-12-31') > h.fecha_inicio)
    BEGIN SELECT RAISE(ABORT,'Un animal no puede tener dos ubicaciones individuales simultáneas'); END")
  dbExecute(conexion, "DROP TRIGGER IF EXISTS tr_ocupacion_grupo_sin_solape")
  dbExecute(conexion, "
    CREATE TRIGGER tr_ocupacion_grupo_sin_solape BEFORE INSERT ON ocupacion_potrero
    WHEN EXISTS (SELECT 1 FROM ocupacion_potrero o WHERE o.grupo_id=NEW.grupo_id AND o.anulado_en IS NULL
      AND COALESCE(o.fecha_fin,'9999-12-31') > NEW.fecha_inicio AND COALESCE(NEW.fecha_fin,'9999-12-31') > o.fecha_inicio)
    BEGIN SELECT RAISE(ABORT,'Un grupo no puede ocupar dos potreros al mismo tiempo'); END")
}

siguiente_animal_id <- function(conexion, sexo) {
  prefijo <- if (identical(sexo, "HEMBRA")) "HEM" else "MAC"
  resultado <- dbGetQuery(conexion, "
    SELECT CAST(MAX(CAST(SUBSTR(animal_id, 5) AS INTEGER)) AS INTEGER) AS consecutivo
    FROM animales WHERE animal_id LIKE ?", params = list(paste0(prefijo, "-%")))
  ultimo <- if (nrow(resultado) && ncol(resultado)) {
    suppressWarnings(as.integer(as.character(resultado[[1]][[1]])))
  } else {
    NA_integer_
  }
  consecutivo <- if (!length(ultimo) || is.na(ultimo)) 1L else ultimo + 1L
  if (is.na(consecutivo) || consecutivo < 1L) {
    stop("No se pudo calcular un consecutivo válido para el ID del animal.", call. = FALSE)
  }
  sprintf("%s-%06d", prefijo, consecutivo)
}
