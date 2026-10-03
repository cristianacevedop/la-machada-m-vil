-- Ejecutar una sola vez en Supabase SQL Editor, conectado como postgres.
-- Guarda IDs/estados para prevenir reenvíos duplicados; no almacena datos de formularios.
CREATE TABLE IF NOT EXISTS finca_migracion.cola_sincronizacion_app (
  operacion_id uuid PRIMARY KEY,
  accion text NOT NULL,
  estado text NOT NULL CHECK (estado IN ('EN_PROCESO', 'ENVIADO', 'ERROR')),
  mensaje text,
  creado_en timestamptz NOT NULL DEFAULT now(),
  actualizado_en timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE
  ON TABLE finca_migracion.cola_sincronizacion_app
  TO finca_app;
