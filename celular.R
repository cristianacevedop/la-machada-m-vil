library(shiny)
library(DBI)
library(plotly)

source("R/db.R")

ui_aplicacion <- tagList(
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1, viewport-fit=cover"),
    tags$style(HTML("\
    body { background: #f7f3ea; color: #29352d; font-family: 'Segoe UI', Arial, sans-serif; }
    .navbar-default { background: #1f4d3a; border: 0; border-radius: 0; min-height: 126px; box-shadow: 0 2px 7px rgba(32, 55, 40, .16); }
    .navbar-default .navbar-brand { height: 126px; padding: 5px 18px; }
    .navbar-default .navbar-brand .brand-logo { height: 116px; width: auto; }
    .navbar-default .navbar-nav > li > a { color: #e7efe4; font-weight: 600; padding-top: 53px; padding-bottom: 53px; }
    .navbar-default .navbar-nav > li > a:hover, .navbar-default .navbar-nav > .active > a,
    .navbar-default .navbar-nav > .active > a:hover { color: #4c1820; background: #d8a85b; }
    .navbar-default .navbar-nav .dropdown-menu { background: #fffdf8; border: 1px solid #e4dac5; border-radius: 0 0 8px 8px; }
    .navbar-default .navbar-nav .dropdown-menu > li > a { color: #355440; font-weight: 600; padding: 9px 16px; }
    .navbar-default .navbar-nav .dropdown-menu > li > a:hover { background: #dcebd5; color: #1f4d3a; }
    .datepicker, .datepicker-dropdown, .bootstrap-datetimepicker-widget { z-index: 6000 !important; }
    .form-group .shiny-date-input { position: relative; z-index: 6001; }
    @media (min-width: 768px) {
      .navbar-default .navbar-nav > li.dropdown:hover > .dropdown-menu { display: block; }
      .navbar-default .navbar-nav > li.dropdown:hover > a.dropdown-toggle { color: #4c1820; background: #d8a85b; }
    }
    .tab-content { max-width: 1440px; margin: 22px auto 36px; padding: 0 12px; }
    .tab-pane > .row > [class*='col-'] { background: #fffdf8; border: 1px solid #e4dac5; border-radius: 13px; padding: 18px 22px; box-shadow: 0 2px 10px rgba(63, 72, 53, .07); min-width: 0; overflow: hidden; }
    .tab-pane > .row > [class*='col-'] + [class*='col-'] { border-left-color: #e4dac5; }
    .tab-pane > .row { display: flex; flex-wrap: wrap; gap: 14px 0; }
    .tab-pane > .row > [class*='col-'] h3:first-child { border-bottom: 2px solid #d8a85b; padding-bottom: 9px; margin-bottom: 16px; }
    .module-layout { display: flex; gap: 22px; align-items: flex-start; }
    .module-sidebar { flex: 0 0 235px; background: #fffdf8; border: 1px solid #e4dac5; border-radius: 12px; padding: 10px; box-shadow: 0 2px 10px rgba(63, 72, 53, .07); }
    .module-sidebar button { display: block; width: 100%; margin: 0 0 5px; padding: 11px 13px; border: 0; border-radius: 7px; background: transparent; color: #355440; text-align: left; font-weight: 650; }
    .module-sidebar button:hover, .module-sidebar button.active { background: #dcebd5; color: #1f4d3a; }
    .module-content { flex: 1 1 auto; min-width: 0; background: #fffdf8; border: 1px solid #e4dac5; border-radius: 13px; padding: 22px; box-shadow: 0 2px 10px rgba(63, 72, 53, .07); }
    .module-back { display: none; width: 100%; margin-bottom: 12px; text-align: left; }
    .dashboard-filtros { width: 100%; margin: 0 0 12px; }
    .dashboard-content > [data-dashboard-bloque] { float: none; width: 100%; }
    .dashboard-layout .dashboard-back { display: none; width: 100%; margin-bottom: 12px; text-align: left; }
    .module-block { display: none; }
    .module-block.active { display: block; }
    .zoom-control { position: fixed; right: 18px; bottom: 18px; z-index: 2000; display: flex; align-items: center; gap: 5px; padding: 6px; background: #fffdf8; border: 1px solid #d8c9ad; border-radius: 10px; box-shadow: 0 3px 13px rgba(45, 57, 42, .2); }
    .zoom-control button { width: 32px; height: 30px; padding: 0; border: 0; border-radius: 6px; background: #2f6b50; color: white; font-size: 19px; line-height: 28px; font-weight: 700; }
    .zoom-control button:hover { background: #23533e; }
    .zoom-control .zoom-level { min-width: 48px; text-align: center; color: #355440; font-size: 12px; font-weight: 700; }
    .cola-offline-boton { position: relative; min-width: 38px; min-height: 38px; padding: 4px 9px; border: 0; border-radius: 7px; background: #2f6b50; color: #fff; font-size: 18px; }
    .cola-offline-contador { position: absolute; top: -7px; right: -7px; min-width: 18px; padding: 1px 5px; border-radius: 10px; background: #b3261e; color: white; font-size: 11px; line-height: 16px; }
    .cola-offline-modal { position: fixed; inset: 0; z-index: 6000; display: flex; align-items: center; justify-content: center; padding: 16px; background: rgba(12, 28, 43, .58); }
    .cola-offline-panel { width: min(980px, 100%); max-height: min(82vh, 760px); overflow: auto; padding: 20px; border-radius: 14px; background: #fffdf8; box-shadow: 0 12px 40px rgba(0,0,0,.28); }
    .cola-offline-cabecera { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 14px; }
    .cola-offline-cabecera h3 { margin: 0; }
    .cola-offline-tabla-wrap { width: 100%; overflow-x: auto; }
    .cola-offline-tabla { min-width: 680px; }
    .cola-offline-detalle { display: block; margin-top: 4px; color: #5b6670; white-space: normal; }
    .cola-offline-limpiar { margin-left: 6px; padding: 3px 7px; border: 1px solid #b8c8d6; border-radius: 6px; background: #fff; color: #173a63; }
    .cola-offline-nota { margin: 12px 0 0; color: #5b6670; font-size: 13px; }
    .genealogia-arbol { margin: 12px 0 18px; text-align: center; }
    .genealogia-fila { display: flex; justify-content: center; gap: 12px; flex-wrap: wrap; margin: 8px 0; }
    .genealogia-nodo { min-width: 150px; max-width: 220px; padding: 10px 12px; background: #eef5e9; border: 1px solid #b9d0ac; border-radius: 9px; color: #244b35; box-shadow: 0 2px 6px rgba(40,70,45,.08); }
    .genealogia-nodo.principal { background: #dcebd5; border-color: #8eb47e; font-weight: 700; }
    .genealogia-relacion { color: #8a6c2f; font-size: 12px; font-weight: 700; margin-bottom: 3px; }
    .genealogia-flecha { color: #8a6c2f; font-size: 18px; line-height: 20px; }
    .intro-splash { position: fixed; inset: 0; z-index: 5000; display: flex; align-items: center; justify-content: center; background: #1f4d3a; animation: splash-fondo 2.15s ease-in-out forwards; pointer-events: none; }
    .intro-splash img { width: min(72vw, 760px); height: auto; background: #fffdf8; padding: 16px; border-radius: 8px; animation: splash-logo 2.15s cubic-bezier(.45,0,.2,1) forwards; }
    .intro-splash .splash-bienvenida { position: absolute; top: calc(50% + min(25vw, 265px)); color: #fff8e8; font-size: clamp(20px, 3vw, 38px); font-weight: 700; letter-spacing: .72em; text-indent: .72em; opacity: 0; animation: splash-texto 2.15s ease-out forwards; }
    @keyframes splash-logo { 0% { transform: scale(1); opacity: 1; } 65% { transform: scale(.72); opacity: 1; } 100% { transform: translate(calc(-50vw + 130px), calc(-50vh + 63px)) scale(.16); opacity: 0; } }
    @keyframes splash-texto { 0%, 18% { transform: translateY(-28px); opacity: 0; } 38% { transform: translateY(0); opacity: 1; } 72% { transform: translateY(0); opacity: 1; } 100% { transform: translateY(-20px); opacity: 0; } }
    @keyframes splash-fondo { 0%, 72% { opacity: 1; } 100% { opacity: 0; visibility: hidden; } }
    .well { background: #fffdf8; border: 1px solid #e4dac5; border-radius: 12px; box-shadow: 0 2px 10px rgba(63, 72, 53, .07); }
    h3 { color: #1f4d3a; font-weight: 700; margin-top: 8px; }
    h4 { color: #98612d; font-weight: 700; }
    hr { border-top-color: #e5dbc8; }
    .form-control, .selectize-input { border: 1px solid #cabfa9; border-radius: 7px; box-shadow: none; }
    .form-control:focus, .selectize-input.focus { border-color: #b86f3f; box-shadow: 0 0 0 3px rgba(184, 111, 63, .16); }
    .control-label { color: #3c503f; font-weight: 650; }
    .btn { border-radius: 7px; font-weight: 650; border: 0; padding: 7px 13px; }
    .btn-default { background: #e8dfca; color: #304638; }
    .btn-default:hover { background: #d9cba9; color: #263b2e; }
    .btn-primary { background: #2f6b50; }
    .btn-primary:hover, .btn-primary:focus { background: #23533e; }
    .btn-success { background: #b86f3f; }
    .btn-success:hover, .btn-success:focus { background: #99572e; }
    .table { display: block; width: 100%; max-width: 100%; background: #fffdf8; border: 1px solid #e4dac5; border-radius: 8px; overflow-x: auto; overflow-y: hidden; }
    .table > thead > tr > th { background: #e6efdf; color: #244934; border-bottom: 2px solid #aac49b; }
    .table > tbody > tr:nth-of-type(odd) { background: #fbf8f0; }
    .table > tbody > tr:hover { background: #f2ead9; }
    .help-block, .helpText { color: #6e705e; font-size: 12px; }
    .shiny-notification { border-radius: 9px; box-shadow: 0 5px 18px rgba(0, 0, 0, .16); }
    @media (min-width: 768px) and (max-width: 991px) {
      .navbar-default { min-height: 86px; }
      .navbar-default .navbar-brand { height: 86px; padding: 5px 12px; }
      .navbar-default .navbar-brand .brand-logo { height: 76px; max-width: 190px; object-fit: contain; }
      .navbar-default .navbar-nav > li > a { padding: 33px 12px; }
      .module-layout { gap: 14px; }
      .module-sidebar { flex-basis: 205px; }
      .module-content { padding: 18px; }
    }
    @media (max-width: 767px) {
      html, body { width: 100%; min-width: 0; overflow-x: hidden; }
      body { font-size: 15px; -webkit-text-size-adjust: 100%; }
      .navbar-default { min-height: 60px; margin-bottom: 0; position: relative; z-index: 3000; }
      .navbar-default .navbar-header { min-height: 60px; }
      .navbar-default .navbar-brand { height: 60px; max-width: calc(100% - 62px); padding: 4px 10px; }
      .navbar-default .navbar-brand .brand-logo { height: 52px; width: auto; max-width: 100%; object-fit: contain; }
      .navbar-default .navbar-toggle { margin: 12px 12px 10px 0; border-color: #d8a85b; }
      .navbar-default .navbar-toggle:hover, .navbar-default .navbar-toggle:focus { background: #2f6b50; }
      .navbar-default .navbar-toggle .icon-bar { background: #fffdf8; }
      .navbar-default .navbar-collapse { max-height: calc(100vh - 60px) !important; overflow-y: auto !important; border-color: rgba(255,255,255,.16); background: #1f4d3a; }
      .navbar-default .navbar-nav { margin: 0 -15px; }
      .navbar-default .navbar-nav > li > a { min-height: 46px; padding: 13px 18px; }
      .navbar-default .navbar-nav .dropdown-menu { max-height: 48vh; overflow-y: auto; border-radius: 0; }
      .navbar-default .navbar-nav .dropdown-menu > li > a { min-height: 44px; padding: 12px 24px; white-space: normal; }
      .tab-content { width: 100%; max-width: 100%; margin: 12px auto 28px; padding: 0 9px; }
      .tab-pane > .row { display: flex; flex-direction: column; gap: 10px; margin: 0; }
      .tab-pane > .row > [class*='col-'], .tab-pane > .row > [class*='col-'] + [class*='col-'] {
        float: none; flex: 0 0 100%; width: 100%; max-width: 100%; margin: 0; padding: 15px 14px;
        border: 1px solid #e4dac5; border-radius: 12px; overflow: visible;
      }
      .tab-pane > .row > [class*='col-'] h3:first-child { font-size: 20px; line-height: 1.25; }
      .module-layout { display: flex; flex-direction: column; width: 100%; gap: 10px; }
      .module-sidebar {
        position: static; z-index: 100; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr));
        flex: 0 0 auto; width: 100%; gap: 10px; overflow: visible; padding: 0; white-space: normal;
        background: transparent; border: 0; box-shadow: none;
      }
      .module-sidebar button {
        display: flex; align-items: center; justify-content: center; width: 100%; min-height: 82px; margin: 0;
        padding: 12px; border: 1px solid #d8c9ad; border-radius: 12px; background: #fffdf8; color: #173a63;
        box-shadow: 0 2px 8px rgba(45, 57, 42, .09); text-align: center; white-space: normal; line-height: 1.3;
      }
      .dashboard-layout .dashboard-selector {
        position: static; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;
        width: 100%; overflow: visible; padding: 0; white-space: normal; background: transparent; border: 0; box-shadow: none;
      }
      .module-sidebar button.active, .module-sidebar button:hover { background: #e5eff8; border-color: #78a5ca; }
      .module-back { display: block; }
      .module-layout.mobile-blocks .module-content { display: none; }
      .module-layout.mobile-blocks .module-sidebar { display: grid; }
      .dashboard-content > [data-dashboard-bloque] { width: 100%; margin: 0 0 10px; padding: 14px 12px; }
      .module-content, .dashboard-content { width: 100%; min-width: 0; padding: 15px 12px; overflow: visible; }
      .module-block, [data-dashboard-bloque] { min-width: 0; max-width: 100%; }
      .shiny-input-container { max-width: 100%; }
      .form-control, .selectize-input { min-height: 44px; font-size: 16px; }
      .selectize-input { display: flex !important; align-items: center; }
      .btn, .btn-group > .btn { min-height: 44px; padding: 10px 14px; white-space: normal; touch-action: manipulation; }
      .radio, .checkbox, .radio-inline, .checkbox-inline { min-height: 36px; padding-top: 7px; }
      .table { display: block; width: 100%; max-width: 100%; overflow-x: auto; overflow-y: hidden; -webkit-overflow-scrolling: touch; touch-action: pan-x pan-y; }
      .table > thead, .table > tbody, .table > tfoot { white-space: nowrap; }
      .shiny-plot-output, .plotly, .plot-container, .js-plotly-plot { width: 100% !important; max-width: 100% !important; }
      .zoom-control { right: 10px; bottom: max(10px, env(safe-area-inset-bottom)); z-index: 2500; gap: 4px; padding: 5px; }
      .zoom-control button { width: 38px; height: 38px; }
      .cola-offline-panel { max-height: calc(100dvh - 24px); padding: 15px 12px; }
      .modal-dialog { width: auto; max-width: none; margin: 8px; }
      .modal-content { max-height: calc(100dvh - 16px); overflow-y: auto; }
      .modal-body { max-height: calc(100dvh - 150px); overflow-y: auto; }
      .datepicker, .datepicker-dropdown, .bootstrap-datetimepicker-widget { max-width: calc(100vw - 16px); }
      .genealogia-nodo { width: min(100%, 280px); max-width: 100%; }
      .intro-splash img { width: min(88vw, 560px); padding: 10px; }
      .intro-splash .splash-bienvenida { top: calc(50% + 31vw); font-size: clamp(16px, 5vw, 25px); letter-spacing: .42em; text-indent: .42em; }
      .navbar-default, .navbar-default .navbar-collapse, .intro-splash { background-color: #173a63; }
      .navbar-default { border-color: #173a63; }
      .navbar-default .navbar-nav > li > a:hover, .navbar-default .navbar-nav > .active > a,
      .navbar-default .navbar-nav > .active > a:hover, .navbar-default .navbar-nav > li.dropdown > a.dropdown-toggle:focus {
        color: #fffdf8; background: #2f6b9a;
      }
      .navbar-default .navbar-nav .dropdown-menu > li > a:hover { color: #173a63; background: #e5eff8; }
      .navbar-default .navbar-toggle { border-color: #b5cde2; }
      .navbar-default .navbar-toggle:hover, .navbar-default .navbar-toggle:focus { background: #2f6b9a; }
      .module-sidebar button { color: #173a63; }
      .module-sidebar button:hover, .module-sidebar button.active { color: #173a63; background: #e5eff8; }
      h3 { color: #173a63; }
      h4 { color: #2f6b9a; }
      .tab-pane > .row > [class*='col-'] h3:first-child { border-bottom-color: #6c9bc2; }
      .form-control:focus, .selectize-input.focus { border-color: #397bad; box-shadow: 0 0 0 3px rgba(57, 123, 173, .18); }
      .btn-primary, .zoom-control button { background: #2f6b9a; }
      .btn-primary:hover, .btn-primary:focus, .zoom-control button:hover { background: #173a63; }
      .btn-success { background: #397bad; }
      .btn-success:hover, .btn-success:focus { background: #285c85; }
      .table > thead > tr > th { color: #173a63; background: #e5eff8; border-bottom-color: #a8c5dc; }
      .table > tbody > tr:hover { background: #f1f6fb; }
      .tab-pane > .row > [class*='col-'], .module-sidebar, .module-content { border-color: #ead0d3; }
      .genealogia-nodo { color: #173a63; background: #f1f6fb; border-color: #a8c5dc; }
      .genealogia-nodo.principal { background: #e5eff8; border-color: #6c9bc2; }
      .genealogia-relacion, .genealogia-flecha { color: #2f6b9a; }
      .datepicker table tr td.active, .datepicker table tr td.active:hover,
      .datepicker table tr td span.active, .datepicker table tr td span.active:hover { background: #2f6b9a !important; }
      .zoom-control .zoom-level { color: #173a63; }
      @keyframes splash-logo { 0% { transform: scale(1); opacity: 1; } 65% { transform: scale(.72); opacity: 1; } 100% { transform: translate(calc(-50vw + 48px), calc(-50vh + 31px)) scale(.16); opacity: 0; } }
    }
    /* Tema propio de la copia móvil: azul en cualquier tamaño de ventana. */
    .navbar-default, .navbar-default .navbar-collapse, .intro-splash { background-color: #173a63; }
    .navbar-default { border-color: #173a63; }
    .navbar-default .navbar-nav > li > a:hover, .navbar-default .navbar-nav > .active > a,
    .navbar-default .navbar-nav > .active > a:hover, .navbar-default .navbar-nav > li.dropdown:hover > a.dropdown-toggle,
    .navbar-default .navbar-nav > li.dropdown > a.dropdown-toggle:focus { color: #fffdf8; background: #2f6b9a; }
    .navbar-default .navbar-nav .dropdown-menu > li > a:hover { color: #173a63; background: #e5eff8; }
    .navbar-default .navbar-toggle { border-color: #b5cde2; }
    .navbar-default .navbar-toggle:hover, .navbar-default .navbar-toggle:focus { background: #2f6b9a; }
    .module-sidebar button { color: #173a63; }
    .module-sidebar button:hover, .module-sidebar button.active { color: #173a63; background: #e5eff8; }
    h3 { color: #173a63; }
    h4 { color: #2f6b9a; }
    .tab-pane > .row > [class*='col-'] h3:first-child { border-bottom-color: #6c9bc2; }
    .form-control:focus, .selectize-input.focus { border-color: #397bad; box-shadow: 0 0 0 3px rgba(57, 123, 173, .18); }
    .btn-primary, .zoom-control button { background: #2f6b9a; }
    .btn-primary:hover, .btn-primary:focus, .zoom-control button:hover { background: #173a63; }
    .btn-success { background: #397bad; }
    .btn-success:hover, .btn-success:focus { background: #285c85; }
    .table > thead > tr > th { color: #173a63; background: #e5eff8; border-bottom-color: #a8c5dc; }
    .table > tbody > tr:hover { background: #f1f6fb; }
    .genealogia-nodo { color: #173a63; background: #f1f6fb; border-color: #a8c5dc; }
    .genealogia-nodo.principal { background: #e5eff8; border-color: #6c9bc2; }
    .genealogia-relacion, .genealogia-flecha { color: #2f6b9a; }
    .datepicker table tr td.active, .datepicker table tr td.active:hover,
    .datepicker table tr td span.active, .datepicker table tr td span.active:hover { background: #2f6b9a !important; }
    .zoom-control .zoom-level { color: #173a63; }
  ")), 
    tags$script(HTML("\
      $(function() {
        setTimeout(function() { $('#intro-splash').remove(); }, 2400);
        var colaDB = null, colaSincronizando = false, colaOperacionActiva = null;
        var colaAbierta = new Promise(function(resolve, reject) {
          if (!window.indexedDB) { reject(new Error('Este navegador no permite guardar registros locales.')); return; }
          var solicitud = indexedDB.open('la-machada-cola-offline', 1);
          solicitud.onupgradeneeded = function() {
            var db = solicitud.result;
            if (!db.objectStoreNames.contains('registros')) db.createObjectStore('registros', {keyPath: 'id'});
          };
          solicitud.onsuccess = function() { colaDB = solicitud.result; resolve(colaDB); };
          solicitud.onerror = function() { reject(solicitud.error || new Error('No se pudo abrir el almacenamiento local.')); };
        });
        function colaLeerTodos() {
          return colaAbierta.then(function(db) { return new Promise(function(resolve, reject) {
            var tx = db.transaction('registros', 'readonly'), req = tx.objectStore('registros').getAll();
            req.onsuccess = function() { resolve(req.result || []); }; req.onerror = function() { reject(req.error); };
          }); });
        }
        function colaGuardar(registro) {
          return colaAbierta.then(function(db) { return new Promise(function(resolve, reject) {
            var tx = db.transaction('registros', 'readwrite'); tx.objectStore('registros').put(registro);
            tx.oncomplete = function() { resolve(); }; tx.onerror = function() { reject(tx.error); };
          }); });
        }
        function colaActualizar(id, cambios) {
          return colaAbierta.then(function(db) { return new Promise(function(resolve, reject) {
            var tx = db.transaction('registros', 'readwrite'), store = tx.objectStore('registros'), req = store.get(id);
            req.onsuccess = function() { if (req.result) store.put(Object.assign(req.result, cambios)); };
            tx.oncomplete = function() { resolve(); }; tx.onerror = function() { reject(tx.error); };
          }); });
        }
        function colaNuevoId() {
          if (window.crypto && crypto.randomUUID) return crypto.randomUUID();
          return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0; return (c === 'x' ? r : (r & 3 | 8)).toString(16);
          });
        }
        function colaEscribirTabla() {
          return colaLeerTodos().then(function(registros) {
            registros.sort(function(a, b) { return b.creado - a.creado; });
            var html = `<div class='cola-offline-tabla-wrap'><table class='table cola-offline-tabla'><thead><tr><th>Registro</th><th>Fecha</th><th>Pendientes</th><th>Enviándose</th><th>Enviados <button id='cola-offline-limpiar' class='cola-offline-limpiar' type='button' title='Limpiar enviados' aria-label='Limpiar enviados'>🖌️</button></th></tr></thead><tbody>`;
            if (!registros.length) html += `<tr><td colspan='5'>No hay registros en la cola.</td></tr>`;
            registros.forEach(function(r) {
              var celda = function(estado) {
                if (r.estado !== estado) return '<td></td>';
                var texto = estado === 'enviado' ? '✓ Enviado' : estado === 'enviando' ? '⟳ Enviándose' : '• Pendiente';
                if (r.error) texto += '<br><small>' + $('<div>').text(r.error).html() + '</small>';
                return '<td>' + texto + '</td>';
              };
              var resumen = r.resumen ? '<small class=\"cola-offline-detalle\">' + $('<div>').text(r.resumen).html() + '</small>' : '';
              html += '<tr><td><strong>' + $('<div>').text(r.titulo).html() + '</strong>' + resumen + '</td><td>' + new Date(r.creado).toLocaleString() + '</td>' + celda('pendiente') + celda('enviando') + celda('enviado') + '</tr>';
            });
            html += '</tbody></table></div>';
            $('#cola-offline-contenido').html(html);
            var pendientes = registros.filter(function(r) { return r.estado !== 'enviado'; }).length;
            $('#cola-offline-contador').text(pendientes).toggle(pendientes > 0);
            $('#cola-offline-conexion').text(navigator.onLine ? 'Conexión a internet disponible. La app sincroniza al recuperar también la conexión con el servidor.' : 'Sin conexión: los nuevos registros se conservan pendientes en este dispositivo.');
          }).catch(function(e) { $('#cola-offline-contenido').text(e.message || 'No se pudo leer la cola local.'); });
        }
        function colaConectada() {
          var ws = window.Shiny && Shiny.shinyapp && Shiny.shinyapp.$socket;
          return navigator.onLine && ws && ws.readyState === WebSocket.OPEN;
        }
        function colaProcesarSiguiente() {
          if (colaSincronizando || !colaConectada()) return;
          colaLeerTodos().then(function(registros) {
            var siguiente = registros.find(function(r) { return r.estado === 'pendiente' && !r.error; });
            if (!siguiente) return;
            colaSincronizando = true; colaOperacionActiva = siguiente.id;
            colaActualizar(siguiente.id, {estado: 'enviando', error: null}).then(function() {
              colaEscribirTabla();
              Shiny.setInputValue('offline_sync_request', {id: siguiente.id, accion: siguiente.accion, titulo: siguiente.titulo, campos: siguiente.campos}, {priority: 'event'});
            }).catch(function() { colaSincronizando = false; colaOperacionActiva = null; });
          }).catch(function() {});
        }
        Shiny.addCustomMessageHandler('offline_sync_replay', function(m) {
          if (!m || m.id !== colaOperacionActiva) return;
          if (m.estado === 'enviado') {
            colaActualizar(m.id, {estado: 'enviado', error: null}).then(function() { colaSincronizando = false; colaOperacionActiva = null; colaEscribirTabla(); colaProcesarSiguiente(); });
            return;
          }
          if (m.estado === 'revisar' || m.estado === 'error') {
            colaActualizar(m.id, {estado: 'pendiente', error: m.mensaje || 'No se pudo confirmar el guardado; revisa antes de volver a enviarlo.'}).then(function() { colaSincronizando = false; colaOperacionActiva = null; colaEscribirTabla(); });
            return;
          }
          Object.keys(m.campos || {}).forEach(function(id) { Shiny.setInputValue(id, m.campos[id], {priority: 'event'}); });
          setTimeout(function() {
            if (!colaConectada()) { colaActualizar(m.id, {estado: 'pendiente'}).then(function() { colaSincronizando = false; colaOperacionActiva = null; colaEscribirTabla(); }); return; }
            var actual = Number(Shiny.shinyapp.$inputValues[m.accion] || 0);
            Shiny.setInputValue(m.accion, actual + 1, {priority: 'event'});
          }, 80);
        });
        Shiny.addCustomMessageHandler('offline_sync_resultado', function(m) {
          if (!m || m.id !== colaOperacionActiva) return;
          var cambios = m.estado === 'enviado' ? {estado: 'enviado', error: null} : {estado: 'pendiente', error: m.mensaje || 'No se confirmó el guardado. Revisa el registro antes de reintentar.'};
          colaActualizar(m.id, cambios).then(function() { colaSincronizando = false; colaOperacionActiva = null; colaEscribirTabla(); if (m.estado === 'enviado') colaProcesarSiguiente(); });
        });
        $('#cola-offline-abrir').on('click', function() { $('#cola-offline-modal').css('display', 'flex'); colaEscribirTabla(); });
        $('#cola-offline-cerrar').on('click', function() { $('#cola-offline-modal').hide(); });
        $('#cola-offline-modal').on('click', function(e) { if (e.target === this) $(this).hide(); });
        $(document).on('click', '#cola-offline-limpiar', function() {
          colaAbierta.then(function(db) { return new Promise(function(resolve, reject) {
            var tx = db.transaction('registros', 'readwrite'), store = tx.objectStore('registros'), req = store.openCursor();
            req.onsuccess = function() { var cursor = req.result; if (!cursor) return; if (cursor.value.estado === 'enviado') cursor.delete(); cursor.continue(); };
            tx.oncomplete = resolve; tx.onerror = function() { reject(tx.error); };
          }); }).then(colaEscribirTabla);
        });
        document.addEventListener('click', function(e) {
          var boton = e.target.closest && e.target.closest('button[id^=guardar_]');
          if (!boton || colaConectada()) return;
          if (boton.id.indexOf('guardar_edicion_') === 0 || boton.id === 'guardar_estado') {
            e.preventDefault(); e.stopPropagation(); if (e.stopImmediatePropagation) e.stopImmediatePropagation();
            alert('Esta acción requiere conexión. Solo se guardan sin conexión los registros nuevos.'); return;
          }
          e.preventDefault(); e.stopPropagation(); if (e.stopImmediatePropagation) e.stopImmediatePropagation();
          var contenedor = boton.closest('.module-block') || boton.closest('[data-dashboard-bloque]') || boton.closest('.tab-pane') || document;
          var entrada = window.Shiny && Shiny.shinyapp && Shiny.shinyapp.$inputValues || {}, campos = {};
          Object.keys(entrada).forEach(function(id) {
            var el = document.getElementById(id);
            if (el && contenedor.contains(el) && !el.matches('button')) campos[id] = entrada[id];
          });
          var resumen = Object.keys(campos).map(function(id) {
            var valor = campos[id], elemento = document.getElementById(id);
            if (valor === null || typeof valor === 'undefined' || valor === '') return null;
            if (Array.isArray(valor)) valor = valor.join(', ');
            else if (typeof valor === 'object') valor = JSON.stringify(valor);
            var contenedorCampo = elemento && elemento.closest('.shiny-input-container');
            var etiqueta = contenedorCampo && contenedorCampo.querySelector('label.control-label');
            var nombre = etiqueta ? $.trim(etiqueta.textContent) : id.replace(/_/g, ' ');
            return nombre + ': ' + String(valor).replace(/\\s+/g, ' ').slice(0, 100);
          }).filter(Boolean).slice(0, 8).join(' · ').slice(0, 700);
          var registro = {id: colaNuevoId(), accion: boton.id, titulo: $.trim($(boton).text()) || boton.id, resumen: resumen, creado: Date.now(), estado: 'pendiente', campos: campos, error: null};
          colaGuardar(registro).then(colaEscribirTabla).then(function() { $('#cola-offline-modal').css('display', 'flex'); })
            .catch(function(err) { alert('No se pudo guardar el registro en esta app: ' + (err.message || err)); });
        }, true);
        window.addEventListener('online', function() { colaEscribirTabla(); colaProcesarSiguiente(); });
        window.addEventListener('focus', colaProcesarSiguiente);
        document.addEventListener('visibilitychange', function() { if (!document.hidden) colaProcesarSiguiente(); });
        $(document).on('shiny:connected', colaProcesarSiguiente);
        setInterval(colaProcesarSiguiente, 3000);
        colaAbierta.then(function(db) { return new Promise(function(resolve, reject) {
          var tx = db.transaction('registros', 'readwrite'), store = tx.objectStore('registros'), req = store.openCursor();
          req.onsuccess = function() { var cursor = req.result; if (!cursor) return; if (cursor.value.estado === 'enviando') { var r = cursor.value; r.estado = 'pendiente'; r.error = null; cursor.update(r); } cursor.continue(); };
          tx.oncomplete = resolve; tx.onerror = function() { reject(tx.error); };
        }); }).then(function() { colaEscribirTabla(); colaProcesarSiguiente(); });
        var sonidoInicioReproducido = false;
        function reproducirSonidoInicio() {
          if (sonidoInicioReproducido) return;
          sonidoInicioReproducido = true;
          try {
            var AudioContexto = window.AudioContext || window.webkitAudioContext;
            if (!AudioContexto) return;
            var audio = new AudioContexto();
            var ahora = audio.currentTime + 0.04;
            [[261.63, 0.00, 0.34], [329.63, 0.16, 0.30], [392.00, 0.31, 0.48]].forEach(function(nota) {
              var oscilador = audio.createOscillator();
              var ganancia = audio.createGain();
              oscilador.type = 'sine';
              oscilador.frequency.value = nota[0];
              ganancia.gain.setValueAtTime(0.0001, ahora + nota[1]);
              ganancia.gain.exponentialRampToValueAtTime(0.13, ahora + nota[1] + 0.035);
              ganancia.gain.exponentialRampToValueAtTime(0.0001, ahora + nota[1] + nota[2]);
              oscilador.connect(ganancia).connect(audio.destination);
              oscilador.start(ahora + nota[1]);
              oscilador.stop(ahora + nota[1] + nota[2] + 0.02);
            });
            setTimeout(function() { audio.close(); }, 1200);
          } catch (e) { /* Algunos navegadores bloquean audio automático. */ }
        }
        setTimeout(reproducirSonidoInicio, 180);
        $(document).one('pointerdown keydown', reproducirSonidoInicio);
        var sonidosModulos = {
          'Ganado': document.getElementById('audio-ganado'),
          'Comercial y finanzas': document.getElementById('audio-comercial-finanzas'),
          'Operación de finca': document.getElementById('audio-operacion-finca')
        };
        var sonidosModulosSilenciados = false;
        try { sonidosModulosSilenciados = localStorage.getItem('machada-sonidos-silenciados') === 'true'; } catch (e) {}
        function actualizarBotonSonido() {
          var boton = document.getElementById('sonido-toggle');
          if (!boton) return;
          boton.textContent = sonidosModulosSilenciados ? '🔇' : '🔊';
          boton.title = sonidosModulosSilenciados ? 'Activar efectos de sonido' : 'Silenciar efectos de sonido';
          boton.setAttribute('aria-label', boton.title);
          boton.setAttribute('aria-pressed', String(sonidosModulosSilenciados));
        }
        $(document).on('click', '#sonido-toggle', function() {
          sonidosModulosSilenciados = !sonidosModulosSilenciados;
          try { localStorage.setItem('machada-sonidos-silenciados', String(sonidosModulosSilenciados)); } catch (e) {}
          if (sonidosModulosSilenciados) Object.keys(sonidosModulos).forEach(function(nombre) {
            var audio = sonidosModulos[nombre];
            if (audio) { audio.pause(); audio.currentTime = 0; }
          });
          actualizarBotonSonido();
        });
        actualizarBotonSonido();
        $(document).on('click', '.navbar-nav > li.dropdown > a.dropdown-toggle', function() {
          var nombre = $.trim($(this).clone().children().remove().end().text());
          var audio = sonidosModulos[nombre];
          if (audio && !sonidosModulosSilenciados) { audio.currentTime = 0; audio.play().catch(function() {}); }
        });
        var zoomActual = 1;
        function actualizarZoom() {
          $('body').css('zoom', zoomActual);
          $('#zoom-nivel').text(Math.round(zoomActual * 100) + '%');
        }
        function cambiarZoom(delta) {
          zoomActual = Math.max(0.7, Math.min(1.5, Math.round((zoomActual + delta) * 10) / 10));
          actualizarZoom();
        }
        $('#zoom-mas').on('click', function() { cambiarZoom(0.1); });
        $('#zoom-menos').on('click', function() { cambiarZoom(-0.1); });
        $(document).on('keydown', function(evento) {
          var etiqueta = (evento.target.tagName || '').toLowerCase();
          if (etiqueta === 'input' || etiqueta === 'textarea' || etiqueta === 'select') return;
          if (evento.key === '+' || evento.key === '=') { evento.preventDefault(); cambiarZoom(0.1); }
          if (evento.key === '-' || evento.key === '_') { evento.preventDefault(); cambiarZoom(-0.1); }
        });
        $(document).on('dblclick', '#tabla_infraestructura table tbody tr td:first-child', function() {
          Shiny.setInputValue('editar_potrero_nombre', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_grupos table tbody tr td:first-child', function() {
          Shiny.setInputValue('editar_grupo_nombre', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_finanzas table tbody tr td:nth-child(5)', function() {
          Shiny.setInputValue('editar_movimiento_concepto', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_movimientos_historicos table tbody tr td', function() {
          Shiny.setInputValue('editar_movimiento_historico_fila', $(this).closest('tr').index() + 1, {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_ventas table tbody tr td:first-child', function() {
          Shiny.setInputValue('editar_venta_id', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_compras_ganado table tbody tr td:nth-child(3)', function() {
          Shiny.setInputValue('editar_compra_reciente', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_ventas_leche table tbody tr td:first-child', function() {
          Shiny.setInputValue('editar_venta_leche_id', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('dblclick', '#tabla_animales table tbody tr td:first-child', function() {
          Shiny.setInputValue('editar_animal_id', $(this).text().trim(), {priority: 'event'});
        });
        $(document).on('click', '#buscar_numero_registrado', function() {
          $('a').filter(function() { return $(this).attr('data-value') === 'Ficha del animal'; }).tab('show');
        });
        if (!$('.navbar-nav').data('grupos-creados')) {
          var grupos = {
            'Ganado': ['Animales', 'Manejo', 'Ficha del animal', 'Reproducción', 'Sanidad'],
            'Operación de finca': ['Potreros', 'Inventario', 'Activos'],
            'Comercial y finanzas': ['Finanzas', 'Comercialización']
          };
          var $nav = $('.navbar-nav').first();
          Object.keys(grupos).forEach(function(nombre) {
            var $menu = $('<li class=\"dropdown\"><a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\"></a><ul class=\"dropdown-menu\"></ul></li>');
            $menu.find('a.dropdown-toggle').prepend(nombre + ' ').append('<span class=\"caret\"></span>');
            grupos[nombre].forEach(function(etiqueta) {
              $nav.children('li').filter(function() { return $.trim($(this).find('> a').first().text()) === etiqueta; }).appendTo($menu.find('ul'));
            });
            if ($menu.find('ul').children().length) $nav.prepend($menu);
          });
          $('.navbar-nav').data('grupos-creados', true);
        }
        setTimeout(function() { $('.tab-content > .tab-pane').each(function() {
          var $pane = $(this);
          if ($pane.find('#grafica_natalidad, #grafica_inventario_grupo, #grafica_rentabilidad_actividad, #dash_vencimientos').length) {
            if ($pane.data('dashboard-organizado')) return;
            var $dashLayout = $('<div class=\"module-layout dashboard-layout\"></div>');
            var $dashSide = $('<div class=\"module-sidebar module-selector dashboard-selector\" aria-label=\"Bloques del dashboard\"></div>');
            var $dashContent = $('<div class=\"module-content dashboard-content\"></div>');
            var $dashFiltros = $('<div class=\"dashboard-filtros\"></div>');
            var $dashBack = $('<button type=\"button\" class=\"btn btn-default dashboard-back\">← Volver a los bloques</button>');
            var dashIndice = 0;
            $dashContent.append($dashBack);
            $pane.children('.row').each(function() {
              var $fila = $(this);
              $fila.children().each(function() {
                var $columna = $(this), $titulo = $columna.children('h3').first();
                if (!$titulo.length) {
                  $columna.appendTo($dashFiltros);
                  return;
                }
                var idDash = 'dashboard-bloque-' + dashIndice++;
                var textoDash = $.trim($titulo.text()) || 'Bloque';
                var $botonDash = $('<button type=\"button\"></button>').text(textoDash).attr('data-bloque', idDash);
                $columna.attr('data-dashboard-bloque', idDash).appendTo($dashContent);
                $dashSide.append($botonDash);
              });
            });
            $pane.children('.row').remove();
            $pane.append($dashFiltros);
            $dashLayout.append($dashSide).append($dashContent);
            $pane.append($dashLayout).data('dashboard-organizado', true);
            $dashContent.children('[data-dashboard-bloque]').hide();
            if (window.matchMedia('(max-width: 767px)').matches) {
              $dashContent.hide();
            } else {
              $dashContent.children('[data-dashboard-bloque]').first().show();
              $dashSide.children('button').first().addClass('active');
            }
            return;
          }
          if ($pane.data('bloques-convertidos')) return;
          if (window.Shiny && Shiny.unbindAll) Shiny.unbindAll($pane[0]);
          var bloques = [];
          $pane.children('.row').children().filter(function() { return ($(this).attr('class') || '').indexOf('col-') >= 0; }).each(function() {
            var $col = $(this);
            $col.find('h3').each(function() {
              var $h = $(this);
              var $contenido = $h.nextUntil('h3');
              var titulo = $.trim($h.text()) || 'Bloque';
              bloques.push({ titulo: titulo, nodos: $contenido });
              $h.remove();
            });
          });
          if (!bloques.length) return;
          var $layout = $('<div class=\"module-layout module-section-layout\"></div>');
          var $sidebar = $('<div class=\"module-sidebar module-selector\" aria-label=\"Apartados del módulo\"></div>');
          var $content = $('<div class=\"module-content\"></div>');
          var $back = $('<button type=\"button\" class=\"btn btn-default module-back\">← Volver a los apartados</button>');
          $content.append($back);
          bloques.forEach(function(bloque, indice) {
            var id = ($pane.attr('id') || 'modulo') + '-bloque-' + indice;
            var $boton = $('<button type=\"button\"></button>').text(bloque.titulo).attr('data-bloque', id);
            var $caja = $('<div class=\"module-block\"></div>').attr('id', id);
            bloque.nodos.appendTo($caja);
            $sidebar.append($boton);
            $content.append($caja);
            if (indice === 0) { $boton.addClass('active'); $caja.addClass('active'); }
          });
          $pane.children('.row').remove();
          $layout.append($sidebar).append($content);
          $pane.append($layout).data('bloques-convertidos', true);
          if (window.matchMedia('(max-width: 767px)').matches) {
            $layout.addClass('mobile-blocks');
            $content.hide();
          }
          if (window.Shiny && Shiny.bindAll) Shiny.bindAll($pane[0]);
        }); }, 900);
        $(document).on('click', '.module-sidebar button', function() {
          var $boton = $(this), id = $boton.attr('data-bloque'), $layout = $boton.closest('.module-layout');
          $layout.find('.module-sidebar button').removeClass('active');
          $boton.addClass('active');
          $layout.find('.module-block').removeClass('active');
          $layout.find('#' + id).addClass('active');
          $layout.find('[data-dashboard-bloque]').hide();
          $layout.find('[data-dashboard-bloque]').filter(function() { return $(this).attr('data-dashboard-bloque') === id; }).show();
          if (window.matchMedia('(max-width: 767px)').matches) {
            $layout.addClass('mobile-blocks');
            $layout.find('.module-selector').hide();
            $layout.find('.module-content').show();
            $layout.find('.module-back').show();
            setTimeout(function() {
              $(window).trigger('resize');
              if (window.Plotly) $layout.find('.js-plotly-plot').each(function() { Plotly.Plots.resize(this); });
            }, 50);
          }
        });
        $(document).on('click', '.module-back, .dashboard-back', function() {
          var $layout = $(this).closest('.module-layout');
          $layout.find('.module-content').hide();
          $layout.find('.module-selector').show();
          $layout.find('.module-back, .dashboard-back').hide();
        });
        $(window).on('resize.dashboard-layout', function() {
          if (window.matchMedia('(min-width: 768px)').matches) {
            $('.dashboard-layout .dashboard-selector, .dashboard-layout .dashboard-content').show();
            $('.dashboard-layout .dashboard-back').hide();
            $('.module-section-layout').removeClass('mobile-blocks');
            $('.module-section-layout .module-selector, .module-section-layout .module-content').show();
            $('.module-section-layout .module-back').hide();
          } else {
            $('.module-section-layout').each(function() {
              var $layout = $(this);
              if (!$layout.hasClass('mobile-blocks')) {
                $layout.addClass('mobile-blocks');
                $layout.find('.module-content').hide();
                $layout.find('.module-selector').show();
                $layout.find('.module-back').hide();
              }
            });
          }
        });
      });
    "))),
  tags$div(class = "zoom-control", role = "group", `aria-label` = "Zoom de la interfaz",
    tags$button(id = "cola-offline-abrir", class = "cola-offline-boton", type = "button", title = "Registros sin conexión", `aria-label` = "Ver registros sin conexión", "⟳", tags$span(id = "cola-offline-contador", class = "cola-offline-contador", "0")),
    tags$button(id = "zoom-menos", type = "button", title = "Reducir zoom", "−"),
    tags$span(id = "zoom-nivel", class = "zoom-level", "100%"),
    tags$button(id = "zoom-mas", type = "button", title = "Aumentar zoom", "+"),
    tags$button(id = "sonido-toggle", type = "button", class = "boton-sonido", title = "Silenciar efectos de sonido", `aria-label` = "Silenciar efectos de sonido", `aria-pressed` = "false", "🔊")
  ),
  tags$div(id = "cola-offline-modal", class = "cola-offline-modal", style = "display:none", role = "dialog", `aria-modal` = "true", `aria-labelledby` = "cola-offline-titulo",
    tags$div(class = "cola-offline-panel",
      tags$div(class = "cola-offline-cabecera", tags$h3(id = "cola-offline-titulo", "Estado de registros"), tags$button(id = "cola-offline-cerrar", type = "button", class = "btn btn-default", "Cerrar")),
      tags$div(id = "cola-offline-contenido"),
      tags$p(id = "cola-offline-conexion", class = "cola-offline-nota"),
      tags$p(class = "cola-offline-nota", "Los registros pendientes se guardan en el almacenamiento privado de esta app en este celular. Solo se consideran enviados cuando la nube confirma el guardado.")
    )
  ),
  tags$div(id = "intro-splash", class = "intro-splash", tags$img(src = "logo-la-machacada.png", alt = "La Machacada Ganadería"), tags$div(class = "splash-bienvenida", "B I E N V E N I D O")),
  tags$audio(id = "audio-ganado", src = "sonido-ganado.mp3", preload = "auto"),
  tags$audio(id = "audio-comercial-finanzas", src = "sonido-comercial-finanzas.mp3", preload = "auto"),
  tags$audio(id = "audio-operacion-finca", src = "sonido-operacion-finca.mp3", preload = "auto"),
  navbarPage(tags$img(src = "logo-la-machacada.png", class = "brand-logo", alt = "La Machacada Ganadería"),
  tabPanel("Dashboard", fluidRow(
    column(3, h3("Ganado"), strong(textOutput("dash_total_animales")), uiOutput("dash_animales_estado")),
    column(3, h3("Inventario"), strong(textOutput("dash_stock_bajo")), textOutput("dash_vencimientos_kpi")),
    column(3, h3("Finanzas"), strong(textOutput("dash_balance")), textOutput("dash_pendiente")),
    column(3, h3("Comercialización"), strong(textOutput("dash_ventas_mes")), textOutput("dash_ultima_venta"))
  ),
  fluidRow(
    column(6, h3("Animales por grupo"), tableOutput("dash_grupos")),
    column(6, h3("Mantenimientos recientes"), tableOutput("dash_mantenimientos"))
  ),
  fluidRow(
    column(6, h3("Tasa de natalidad"), selectInput("dash_natalidad_periodo", "Agrupar por", c("Mes" = "MES", "Trimestre" = "TRIMESTRE")), plotlyOutput("grafica_natalidad", height = "280px")),
    column(6, h3("Inventario por grupo"), plotOutput("grafica_inventario_grupo", height = "280px"))
  ),
  fluidRow(
    column(12, h3("Rentabilidad / utilidad por actividad"), plotOutput("grafica_rentabilidad_actividad", height = "320px"))
  ),
  fluidRow(
    column(6, h3("Rentabilidad general"), selectInput("dash_rentabilidad_periodo", "Agrupar por", c("Semana" = "SEMANA", "Mes" = "MES", "Año" = "ANO")), plotOutput("grafica_rentabilidad_general", height = "300px")),
    column(6, h3("Producción de leche"), selectInput("dash_leche_periodo", "Agrupar por", c("Día" = "DIA", "Quincena" = "QUINCENA", "Semana" = "SEMANA", "Mes" = "MES", "Año" = "ANO")), plotlyOutput("grafica_leche", height = "300px", width = "100%"))
  ),
  fluidRow(
    column(6, h3("Ingresos, egresos y utilidad trimestral"), plotOutput("grafica_finanzas_trimestral", height = "300px")),
    column(6, h3("Cabezas de ganado en el tiempo"), plotOutput("grafica_cabezas_tiempo", height = "300px"))
  ),
  fluidRow(
    column(6, h3("Próximos vencimientos de inventario"), tableOutput("dash_vencimientos")),
    column(6, h3("Últimos movimientos financieros"), tableOutput("dash_finanzas"))
  )),
  tabPanel("Animales", sidebarLayout(
    sidebarPanel(
      h3("Registrar animal"),
      helpText("Los campos vacíos significan: No registrado."),
      selectInput("sexo", "Sexo", c("Hembra" = "HEMBRA", "Macho" = "MACHO")),
      textOutput("proximo_id"),
      textInput("nombre", "Nombre (opcional)"),
      textInput("arete_hierro", "Arete o hierro (opcional)"),
      dateInput("fecha_nacimiento", "Fecha de nacimiento (opcional)", value = NA),
      selectInput("madre_id", "Madre conocida (opcional)", choices = character(0)),
      actionButton("limpiar_madre_animal", "Quitar madre", class = "btn-default"),
      textInput("animal_madre_arete", "Arete de la madre (si aún no está registrada)", placeholder = "Ej. 045"),
      selectInput("padre_id", "Padre conocido (opcional)", choices = character(0)),
      textInput("raza", "Raza o composición (opcional)"),
      selectInput("animal_grupo_inicial", "Grupo inicial (opcional)", choices = c("Sin grupo" = "")),
      textAreaInput("observaciones", "Observaciones", rows = 3),
      actionButton("guardar_animal", "Guardar animal", class = "btn-primary")
      ,hr(), h3("Registrar cría nacida"),
      selectizeInput("cria_madre", "Madre registrada (buscar por arete)", choices = character(0),
        options = list(placeholder = "Escribe el arete para buscar...", maxOptions = 500L,
          searchField = list("label", "value"))),
      textInput("cria_madre_arete", "Arete de la madre (si aún no está registrada)", placeholder = "Ej. 045"),
      selectInput("cria_sin_marcar", "Estado de marcado de la cría", choices = c("No" = "NO", "Sí, Sin marcar" = "SI"), selected = "NO"),
      selectInput("cria_grupo", "Grupo de la cría", choices = c("PEQUEÑOS" = ""), selected = ""),
      radioButtons("pasar_madre_pequenos", "Pasar madre a grupo PEQUEÑOS", choices = c("No" = "NO", "Sí" = "SI"), selected = "NO", inline = TRUE),
      selectInput("cria_sexo", "Sexo de la cría", c("Hembra" = "HEMBRA", "Macho" = "MACHO")),
      textInput("cria_nombre", "Nombre (opcional)"), textInput("cria_arete", "Arete o hierro (opcional)"),
      dateInput("cria_fecha", "Fecha de nacimiento", value = Sys.Date()),
      selectInput("cria_padre", "Padre registrado (opcional)", choices = character(0)),
      textInput("cria_origen_padre", "Toro o semen externo (opcional)"), textInput("cria_raza", "Raza o composición (opcional)"),
      textAreaInput("cria_observaciones", "Observaciones", rows = 2), actionButton("guardar_cria", "Registrar nacimiento", class = "btn-success"),
      hr(), h3("Registrar destete"), selectInput("destete_animal", "Animal", choices = character(0)),
      dateInput("destete_fecha", "Fecha de destete", value = Sys.Date()), textAreaInput("destete_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_destete", "Registrar destete", class = "btn-primary")
    ),
    mainPanel(
      h3("Animales registrados"),
      selectInput("filtro_grupo_animales", "Filtrar por grupo", choices = c("Todos los grupos" = "TODOS")),
      selectInput("filtro_potrero_animales", "Filtrar por potrero", choices = c("Todos los potreros" = "TODOS")),
      selectInput("filtro_sexo_animales", "Filtrar por sexo", choices = c("Todos" = "TODOS", "Hembra" = "HEMBRA", "Macho" = "MACHO")),
      selectInput("filtro_estado_animales", "Filtrar por estado", choices = c("Todos los estados" = "TODOS", "Sin marcar" = "SIN_MARCAR")),
      textInput("filtro_arete_animales", "Filtrar por número de arete o ID", placeholder = "Escribe el arete o ID..."),
      textInput("filtro_raza_animales", "Buscar por raza", placeholder = "Ej. Brahman"),
      actionButton("limpiar_filtros_animales", "Limpiar filtros", class = "btn-default"),
      textOutput("contador_animales_filtrados"),
      fluidRow(
        column(4, strong(textOutput("total_animales"))),
        column(4, strong(textOutput("total_hembras"))),
        column(4, strong(textOutput("total_machos")))
      ),
      br(),
      tableOutput("tabla_animales")
    )
  )),
  tabPanel("Manejo", fluidRow(
    column(4,
      h3("Crear grupo"),
      textInput("grupo_nombre", "Nombre del grupo"),
      textAreaInput("grupo_descripcion", "Descripción", rows = 2),
      actionButton("guardar_grupo", "Guardar grupo"),
      hr(),
      h3("Mover a un grupo"),
      selectInput("mov_animal", "Animal", choices = character(0)),
      selectInput("mov_grupo", "Grupo de destino", choices = character(0)),
      dateInput("mov_fecha", "Fecha de entrada", value = Sys.Date()),
      textInput("mov_motivo", "Motivo (opcional)"),
      actionButton("guardar_movimiento", "Registrar movimiento", class = "btn-primary")
    ),
    column(4,
      h3("Registrar pesaje"),
      selectInput("peso_animal", "Animal", choices = character(0)),
      dateInput("peso_fecha", "Fecha", value = Sys.Date()),
      numericInput("peso_kg", "Peso (kg)", value = NA, min = 0.1, step = 0.1),
      textAreaInput("peso_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_peso", "Guardar pesaje", class = "btn-primary")
    ),
    column(4,
      h3("Grupos actuales"),
      tableOutput("tabla_grupos"),
      hr(),
      h3("Últimos pesajes"),
      tableOutput("tabla_pesajes")
    )
  )),
  tabPanel("Ficha del animal", sidebarLayout(
    sidebarPanel(
      h3("Registrar cambio de estado"),
      selectizeInput("estado_animal", "Animal", choices = character(0),
        options = list(placeholder = "Busca por ID, arete o nombre...", maxOptions = 500L,
          searchField = list("label", "value"))),
      selectInput("estado_nuevo", "Nuevo estado", c(
        "Activo" = "ACTIVO", "Sin marcar" = "SIN_MARCAR", "En observación" = "OBSERVACION", "En tratamiento" = "TRATAMIENTO",
        "En recuperación" = "RECUPERACION", "En venta" = "VENTA", "Vendido" = "VENDIDO",
        "Muerto" = "MUERTO", "Descartado" = "DESCARTADO", "Trasladado" = "TRASLADADO"
      )),
      dateInput("estado_fecha", "Fecha de inicio", value = Sys.Date()),
      textInput("estado_motivo", "Motivo (opcional)"),
      textAreaInput("estado_observaciones", "Observaciones", rows = 3),
      actionButton("guardar_estado", "Registrar estado", class = "btn-primary")
    ),
    mainPanel(
      div(
        h3("Ficha técnica del animal"),
        selectizeInput("ficha_animal", "Buscar animal por ID, arete o nombre", choices = character(0),
          options = list(placeholder = "Escribe para buscar...", maxOptions = 500L,
            searchField = list("label", "value"))),
        conditionalPanel(
          condition = "input.ficha_animal != null && input.ficha_animal !== ''",
        h4(textOutput("ficha_titulo")),
        tableOutput("ficha_resumen"),
        fluidRow(
          column(6, h4("Historial de estados"), tableOutput("ficha_estados")),
          column(6, h4("Historial de grupos"), tableOutput("ficha_grupos"))
        ),
        h4("Historial de pesajes"),
        tableOutput("ficha_pesajes"),
        h4("Genealogía"),
        uiOutput("ficha_arbol_genealogico"),
        tableOutput("ficha_genealogia")
        )
      )
    )
  )),
  tabPanel("Potreros", fluidRow(
    column(4,
      h3("Crear potrero"),
      textInput("potrero_nombre", "Nombre"),
      numericInput("potrero_area", "Área (hectáreas, opcional)", value = NA, min = 0.01, step = 0.01),
      textInput("potrero_pastura", "Pastura predominante (opcional)"),
      textAreaInput("potrero_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_potrero", "Guardar potrero", class = "btn-primary"),
      hr(), h3("Potreros registrados"), tableOutput("tabla_potreros"),
      hr(),
      h3("Infraestructura"),
      selectInput("infra_potrero", "Potrero", choices = character(0)),
      selectInput("infra_tipo", "Tipo", c("Bebedero" = "BEBEDERO", "Cerca" = "CERCA", "Puerta" = "PUERTA", "Otro" = "OTRO")),
      textInput("infra_nombre", "Nombre o detalle (opcional)"),
      numericInput("infra_cantidad", "Cantidad", value = 1, min = 0.01, step = 1),
      actionButton("guardar_infra", "Registrar infraestructura")
    ),
    column(4,
      h3("Asignar grupo a potrero"),
      selectInput("ocup_grupo", "Grupo", choices = character(0)),
      selectInput("ocup_potrero", "Potrero", choices = character(0)),
      dateInput("ocup_fecha", "Fecha de entrada", value = Sys.Date()),
      textAreaInput("ocup_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_ocupacion", "Registrar ocupación", class = "btn-primary"),
      helpText("Registrar una nueva ocupación cierra la ocupación vigente de ese grupo el mismo día.")
    ),
    column(4,
      h3("Ocupación actual"),
      tableOutput("tabla_ocupacion_actual"),
      hr(),
      h3("Infraestructura registrada"),
      tableOutput("tabla_infraestructura")
    )
  )),
  tabPanel("Reproducción", sidebarLayout(
    sidebarPanel(
      h3("Registrar evento"),
      selectInput("repro_hembra", "Hembra", choices = character(0)),
      dateInput("repro_fecha", "Fecha", value = Sys.Date()),
      selectInput("repro_tipo", "Tipo de evento", c(
        "Celo" = "CELO", "Monta natural" = "MONTA", "Inseminación artificial" = "INSEMINACION",
        "Diagnóstico de gestación" = "DIAGNOSTICO_GESTACION", "Parto" = "PARTO", "Aborto o pérdida" = "ABORTO"
      )),
      selectInput("repro_resultado", "Resultado (opcional)", c("No registrado" = "", "Positivo" = "POSITIVO", "Negativo" = "NEGATIVO")),
      selectInput("repro_macho", "Macho reproductor registrado (opcional)", choices = character(0)),
      textInput("repro_origen_macho", "Toro, semen o proveedor externo (opcional)"),
      textAreaInput("repro_observaciones", "Observaciones", rows = 3),
      actionButton("guardar_reproduccion", "Guardar evento", class = "btn-primary"),
    ),
    mainPanel(
      h3("Historial reproductivo"),
      helpText("El padre biológico del animal y el macho usado en un evento reproductivo son conceptos distintos."),
      tableOutput("tabla_reproduccion")
    )
  )),
  tabPanel("Sanidad", sidebarLayout(
    sidebarPanel(
      h3("Registrar evento sanitario"),
      radioButtons("sanidad_alcance", "Aplicar a", c("Un animal" = "ANIMAL", "Un grupo" = "GRUPO"), inline = TRUE),
      conditionalPanel("input.sanidad_alcance == 'ANIMAL'", selectInput("sanidad_animal", "Animal", choices = character(0))),
      conditionalPanel("input.sanidad_alcance == 'GRUPO'", selectInput("sanidad_grupo", "Grupo", choices = character(0))),
      dateInput("sanidad_fecha", "Fecha", value = Sys.Date()),
      selectInput("sanidad_tipo", "Tipo", c("Vacunación" = "VACUNACION", "Desparasitación" = "DESPARASITACION", "Tratamiento" = "TRATAMIENTO")),
      radioButtons("sanidad_origen_producto", "Producto", c("De inventario" = "INVENTARIO", "Externo" = "EXTERNO", "No aplica" = "NINGUNO"), inline = TRUE),
      conditionalPanel("input.sanidad_origen_producto == 'INVENTARIO'", selectInput("sanidad_item", "Producto disponible", choices = character(0))),
      conditionalPanel("input.sanidad_origen_producto == 'EXTERNO'", textInput("sanidad_producto", "Producto externo")),
      numericInput("sanidad_dosis", "Dosis (opcional)", value = NA, min = 0.001, step = 0.1),
      textInput("sanidad_unidad", "Unidad de dosis (ml, dosis, etc.)"),
      textInput("sanidad_motivo", "Diagnóstico o motivo (opcional)"),
      textInput("sanidad_responsable", "Responsable (opcional)"),
      textAreaInput("sanidad_observaciones", "Observaciones", rows = 3),
      actionButton("guardar_sanidad", "Guardar evento", class = "btn-primary")
    ),
    mainPanel(
      h3("Historial sanitario reciente"),
      tableOutput("tabla_sanidad")
    )
  )),
  tabPanel("Inventario", fluidRow(
    column(4,
      h3("Crear producto o insumo"),
      textInput("inv_nombre", "Nombre"),
      selectInput("inv_categoria", "Categoría", c("Medicamento" = "MEDICAMENTO", "Alimento" = "ALIMENTO", "Insumo" = "INSUMO", "Otro" = "OTRO")),
      textInput("inv_unidad", "Unidad de medida (ml, kg, unidad, etc.)"),
      numericInput("inv_stock_minimo", "Stock mínimo", value = 0, min = 0, step = 0.1),
      textInput("inv_ubicacion", "Ubicación (opcional)"),
      actionButton("guardar_item", "Guardar producto", class = "btn-primary")
    ),
    column(4,
      h3("Registrar movimiento"),
      selectInput("mov_inv_item", "Producto", choices = character(0)),
      selectInput("mov_inv_tipo", "Movimiento", c("Entrada" = "ENTRADA", "Salida" = "SALIDA", "Ajuste positivo" = "AJUSTE_POSITIVO", "Ajuste negativo" = "AJUSTE_NEGATIVO", "Devolución" = "DEVOLUCION")),
      numericInput("mov_inv_cantidad", "Cantidad", value = NA, min = 0.001, step = 0.1),
      dateInput("mov_inv_fecha", "Fecha", value = Sys.Date()),
      textInput("mov_inv_lote_nuevo", "Código de lote para una entrada (opcional)"),
      dateInput("mov_inv_vencimiento", "Vencimiento para una entrada (opcional)", value = NULL),
      selectInput("mov_inv_lote_existente", "Lote existente para salida/devolución (opcional)", choices = character(0)),
      numericInput("mov_inv_costo", "Costo unitario (opcional)", value = NA, min = 0, step = 0.01),
      textAreaInput("mov_inv_observaciones", "Motivo u observaciones", rows = 2),
      actionButton("guardar_mov_inv", "Guardar movimiento", class = "btn-primary")
    ),
    column(4,
      h3("Existencias actuales"),
      tableOutput("tabla_existencias"),
      hr(),
      h3("Próximos vencimientos"),
      tableOutput("tabla_vencimientos")
    ),
    column(12,
      h3("Movimientos recientes"),
      tableOutput("tabla_movimientos_inventario")
    )
  )),
  tabPanel("Activos", fluidRow(
    column(4,
      h3("Registrar activo"),
      textInput("activo_nombre", "Nombre"),
      selectInput("activo_categoria", "Categoría", c(
        "Maquinaria" = "MAQUINARIA", "Vehículo" = "VEHICULO", "Herramienta" = "HERRAMIENTA", "Otro" = "OTRO"
      )),
      textInput("activo_marca", "Marca (opcional)"),
      textInput("activo_modelo", "Modelo (opcional)"),
      textInput("activo_placa", "Placa (opcional)"),
      textInput("activo_serial", "Serial (opcional)"),
      dateInput("activo_fecha_adquisicion", "Fecha de adquisición (opcional)", value = NULL),
      numericInput("activo_valor", "Valor de adquisición (opcional)", value = NA, min = 0, step = 1000),
      textInput("activo_ubicacion", "Ubicación (opcional)"),
      selectInput("activo_estado", "Estado", c("Operativo" = "OPERATIVO", "En mantenimiento" = "MANTENIMIENTO", "Averiado" = "AVERIADO", "Baja" = "BAJA")),
      textAreaInput("activo_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_activo", "Guardar activo", class = "btn-primary")
    ),
    column(4,
      h3("Registrar mantenimiento"),
      selectInput("mant_activo", "Activo", choices = character(0)),
      dateInput("mant_fecha", "Fecha", value = Sys.Date()),
      selectInput("mant_tipo", "Tipo", c("Preventivo" = "PREVENTIVO", "Correctivo" = "CORRECTIVO")),
      textAreaInput("mant_descripcion", "Trabajo realizado", rows = 3),
      numericInput("mant_costo", "Costo (opcional)", value = NA, min = 0, step = 1000),
      textAreaInput("mant_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_mantenimiento", "Guardar mantenimiento", class = "btn-primary")
    ),
    column(4,
      h3("Activos registrados"),
      tableOutput("tabla_activos"),
      hr(),
      h3("Mantenimientos recientes"),
      tableOutput("tabla_mantenimientos")
    )
  )),
  tabPanel("Finanzas", fluidRow(
    column(4,
      h3("Registrar movimiento manual"),
      helpText("Las ventas de ganado se registran automáticamente desde Comercialización y no deben volver a crearse aquí."),
      dateInput("fin_fecha", "Fecha", value = Sys.Date(), format = "yyyy-mm-dd", startview = "year", language = "es"),
      radioButtons("fin_tipo", "Tipo", c("Ingreso" = "INGRESO", "Egreso" = "EGRESO"), inline = TRUE),
      selectInput("fin_categoria", "Categoría", choices = character(0)),
      selectInput("fin_tercero", "Tercero relacionado (opcional)", choices = character(0)),
      textInput("fin_concepto", "Concepto"),
      numericInput("fin_valor_total", "Valor total", value = NA, min = 0.01, step = 1000),
      selectInput("fin_estado_pago", "Estado del pago", c("Pagado" = "PAGADO", "Pendiente" = "PENDIENTE", "Parcial" = "PARCIAL")),
      numericInput("fin_valor_pagado", "Valor pagado (solo pago parcial)", value = NA, min = 0, step = 1000),
      dateInput("fin_fecha_pago", "Fecha de pago", value = Sys.Date(), format = "yyyy-mm-dd", startview = "year", language = "es"),
      textAreaInput("fin_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_finanza", "Guardar movimiento", class = "btn-primary"),
      hr(),
      h3("Registrar personal"),
      textInput("personal_nombre", "Nombre"),
      textInput("personal_rol", "Rol"),
      actionButton("guardar_personal", "Guardar personal", class = "btn-primary")
    ),
    column(4,
      h3("Resumen acumulado"),
      fluidRow(
        column(12, strong(textOutput("fin_ingresos"))),
        column(12, strong(textOutput("fin_egresos"))),
        column(12, strong(textOutput("fin_balance"))),
        column(12, strong(textOutput("fin_pendiente")))
      ),
      hr(),
      helpText("El saldo pendiente suma lo que aún no se ha pagado o cobrado en movimientos vigentes.")
    ),
    column(4,
      h3("Movimientos recientes"),
      tableOutput("tabla_finanzas"),
      hr(),
      h3("Movimientos históricos"),
      selectInput("hist_tipo", "Filtrar por tipo", choices = c("Todos" = "TODOS", "Ingresos" = "INGRESO", "Egresos" = "EGRESO")),
      selectInput("hist_categoria", "Filtrar por categoría", choices = c("Todas" = "TODAS")),
      textInput("hist_concepto", "Buscar por concepto", placeholder = "Escribe parte del concepto..."),
      tableOutput("tabla_movimientos_historicos")
    )
  )),
  tabPanel("Comercialización", fluidRow(
    column(4,
      h3("Registrar comprador"),
      textInput("comprador_nombre", "Nombre o razón social"),
      textInput("comprador_documento", "Documento (opcional)"),
      textInput("comprador_telefono", "Teléfono (opcional)"),
      textInput("comprador_correo", "Correo (opcional)"),
      textAreaInput("comprador_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_comprador", "Guardar comprador", class = "btn-primary"),
      hr(),
      h3("Compradores registrados"),
      tableOutput("tabla_compradores"),
      hr(),
      h3("Registrar compra de ganado"),
      selectInput("compra_ganado_tercero", "Vendedor (opcional)", choices = character(0)),
      dateInput("compra_ganado_fecha", "Fecha de compra", value = Sys.Date(), format = "yyyy-mm-dd", startview = "year", language = "es"),
      numericInput("compra_ganado_valor", "Valor total", value = NA, min = 0.01, step = 1000),
      selectInput("compra_ganado_estado_pago", "Estado del pago", c("Pagado" = "PAGADO", "Pendiente" = "PENDIENTE", "Parcial" = "PARCIAL")),
      numericInput("compra_ganado_pagado", "Monto pagado (solo parcial)", value = NA, min = 0, step = 1000),
      textAreaInput("compra_ganado_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_compra_ganado", "Guardar compra de ganado", class = "btn-success")
    ),
    column(5,
      h3("Registrar venta de leche"),
      selectInput("leche_comprador", "Comprador (opcional)", choices = character(0)),
      dateInput("leche_fecha", "Fecha", value = Sys.Date(), format = "yyyy-mm-dd", startview = "year", language = "es"),
      numericInput("leche_litros", "Litros", value = NA, min = 0.01, step = 0.1),
      numericInput("leche_precio_litro", "Precio por litro", value = NA, min = 0, step = 10),
      textAreaInput("leche_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_venta_leche", "Guardar venta de leche", class = "btn-success"),
      hr(),
      h3("Ventas de leche recientes"),
      tableOutput("tabla_ventas_leche"),
      hr(),
      h3("Registrar venta de ganado"),
      helpText("Todos los animales de esta venta usarán el mismo precio por kg. El peso se congela desde su último pesaje."),
      selectInput("venta_comprador", "Comprador", choices = character(0)),
      dateInput("venta_fecha", "Fecha de venta", value = Sys.Date(), format = "yyyy-mm-dd", startview = "year", language = "es"),
      checkboxGroupInput("venta_animales", "Animales vendidos", choices = character(0)),
      numericInput("venta_precio_kg", "Precio por kg", value = NA, min = 0, step = 100),
      selectInput("venta_estado_pago", "Estado del pago", c("Pagado" = "PAGADO", "Pendiente" = "PENDIENTE", "Parcial" = "PARCIAL")),
      numericInput("venta_valor_pagado", "Monto pagado (solo pago parcial)", value = NA, min = 0, step = 1000),
      textAreaInput("venta_observaciones", "Observaciones", rows = 2),
      actionButton("guardar_venta", "Confirmar venta", class = "btn-success")
    ),
    column(3,
      h3("Resumen de la venta"),
      tableOutput("resumen_venta"),
      helpText("Los animales sin pesaje no aparecen como disponibles: primero registre su peso en Manejo.")
    ),
    column(12,
      h3("Ventas recientes"),
      tableOutput("tabla_ventas"),
      hr(),
      h3("Compras recientes"),
      tableOutput("tabla_compras_ganado")
    )
  ))
)
)

server_aplicacion <- function(input, output, session) {
  if (identical(backend_base(), "sqlite") && !file.exists(ruta_base)) {
    stop("No se encontró database/finca.sqlite. Ejecuta primero database/inicializar_base.R.")
  }

  conexion <- abrir_base(ruta_base)
  onSessionEnded(function() dbDisconnect(conexion))
  operacion_offline <- new.env(parent = emptyenv())
  operacion_offline$id <- NULL
  operacion_offline$accion <- NULL
  registrar_estado_offline <- function(id, estado, mensaje = NA_character_) {
    tryCatch(dbExecute(conexion,
      "UPDATE cola_sincronizacion_app SET estado=?, mensaje=?, actualizado_en=now() WHERE operacion_id=CAST(? AS uuid)",
      params = list(estado, mensaje, id)), error = function(e) NULL)
  }
  showNotification <- function(...) {
    argumentos <- list(...)
    tipo <- if (is.null(argumentos$type)) "default" else as.character(argumentos$type)[1]
    texto <- if (length(argumentos) && is.character(argumentos[[1]])) paste(argumentos[[1]], collapse = " ") else ""
    resultado <- do.call(shiny::showNotification, argumentos)
    id <- operacion_offline$id
    accion <- operacion_offline$accion
    if (!is.null(id) && identical(tipo, "message") && grepl(
      "guardado correctamente|Grupo creado|Movimiento de grupo registrado|Pesaje guardado|Estado actualizado|Potrero creado|Infraestructura registrada|Ocupación registrada|Evento reproductivo guardado|Nacimiento registrado|Animal existente vinculado al parto|Destete registrado|Evento sanitario guardado|Producto creado|Movimiento de inventario guardado|Activo guardado|Mantenimiento guardado|Movimiento financiero guardado|Personal registrado y disponible|Comprador guardado|Venta de leche registrada|Compra de ganado registrada|Venta registrada, ingreso financiero creado",
      texto, ignore.case = TRUE)) {
      registrar_estado_offline(id, "ENVIADO")
      session$sendCustomMessage("offline_sync_resultado", list(id = id, estado = "enviado"))
      operacion_offline$id <- NULL
      operacion_offline$accion <- NULL
    } else if (!is.null(id) && identical(tipo, "error")) {
      later::later(function() {
        if (!identical(operacion_offline$id, id)) return()
        mensaje <- if (nzchar(texto)) texto else paste("No se pudo completar", accion)
        registrar_estado_offline(id, "ERROR", mensaje)
        session$sendCustomMessage("offline_sync_resultado", list(id = id, estado = "error", mensaje = mensaje))
        operacion_offline$id <- NULL
        operacion_offline$accion <- NULL
      }, delay = 30)
    }
    resultado
  }
  observeEvent(input$offline_sync_request, {
    solicitud <- input$offline_sync_request
    if (is.null(solicitud$id) || is.null(solicitud$accion) ||
        !grepl("^guardar_[A-Za-z0-9_]+$", solicitud$accion) ||
        startsWith(solicitud$accion, "guardar_edicion_") || identical(solicitud$accion, "guardar_estado")) return()
    tryCatch({
      existente <- dbGetQuery(conexion,
        "SELECT estado FROM cola_sincronizacion_app WHERE operacion_id=CAST(? AS uuid)",
        params = list(as.character(solicitud$id)))
      if (nrow(existente)) {
        estado <- as.character(existente$estado[1])
        if (identical(estado, "ENVIADO")) {
          session$sendCustomMessage("offline_sync_replay", list(id = solicitud$id, estado = "enviado"))
        } else {
          session$sendCustomMessage("offline_sync_replay", list(id = solicitud$id, estado = "revisar",
            mensaje = "El servidor ya recibió este intento, pero no confirmó su resultado. Verifica el registro antes de repetirlo."))
        }
        return()
      }
      dbExecute(conexion,
        "INSERT INTO cola_sincronizacion_app(operacion_id, accion, estado) VALUES (CAST(? AS uuid), ?, 'EN_PROCESO')",
        params = list(as.character(solicitud$id), as.character(solicitud$accion)))
      operacion_offline$id <- as.character(solicitud$id)
      operacion_offline$accion <- as.character(solicitud$accion)
      session$sendCustomMessage("offline_sync_replay", list(id = solicitud$id, accion = solicitud$accion, campos = solicitud$campos))
    }, error = function(e) {
      session$sendCustomMessage("offline_sync_replay", list(id = solicitud$id, estado = "error",
        mensaje = paste("No se pudo preparar la sincronización:", conditionMessage(e))))
    })
  }, ignoreInit = TRUE)
  recargar <- reactiveVal(0L)
  formato_pesos <- function(x) {
    ifelse(is.na(x), "—", paste0("$ ", format(round(as.numeric(x), 2), big.mark = ".", decimal.mark = ",", nsmall = 2)))
  }

  animales <- reactive({
    recargar()
    filtro <- if (is.null(input$filtro_grupo_animales) || input$filtro_grupo_animales == "TODOS") NULL else as.integer(input$filtro_grupo_animales)
    potrero <- if (is.null(input$filtro_potrero_animales) || input$filtro_potrero_animales == "TODOS") NULL else as.integer(input$filtro_potrero_animales)
    sexo <- if (is.null(input$filtro_sexo_animales) || input$filtro_sexo_animales == "TODOS") NULL else input$filtro_sexo_animales
    estado_seleccionado <- input$filtro_estado_animales
    marcado <- identical(estado_seleccionado, "SIN_MARCAR")
    estado <- if (is.null(estado_seleccionado) || estado_seleccionado %in% c("TODOS", "SIN_MARCAR")) NULL else estado_seleccionado
    raza <- trimws(if (is.null(input$filtro_raza_animales)) "" else input$filtro_raza_animales)
    arete <- trimws(if (is.null(input$filtro_arete_animales)) "" else input$filtro_arete_animales)
    condiciones <- c(if (!is.null(filtro)) "AND gh.grupo_id = ?", if (!is.null(potrero)) "AND op.potrero_id = ?", if (!is.null(sexo)) "AND a.sexo = ?", if (!is.null(estado)) "AND eh.estado_codigo = ?", if (marcado) "AND EXISTS (SELECT 1 FROM animal_estado_historial sm WHERE sm.animal_id=a.animal_id AND sm.estado_codigo='SIN_MARCAR' AND sm.fecha_fin IS NULL AND sm.anulado_en IS NULL)", if (nzchar(arete)) "AND (LOWER(COALESCE(a.arete_hierro,'')) LIKE LOWER(?) OR LOWER(a.animal_id) LIKE LOWER(?))", if (nzchar(raza)) "AND LOWER(COALESCE(a.raza_composicion,'')) LIKE LOWER(?)")
    condicion_filtros <- if (length(condiciones)) paste(condiciones, collapse = ' ') else ''
    parametros <- c(if (!is.null(filtro)) list(filtro), if (!is.null(potrero)) list(potrero), if (!is.null(sexo)) list(sexo), if (!is.null(estado)) list(estado), if (nzchar(arete)) list(paste0('%', arete, '%'), paste0('%', arete, '%')), if (nzchar(raza)) list(paste0('%', raza, '%')))
    consulta_animales <- paste0("
      SELECT DISTINCT a.animal_id AS ID, a.sexo AS Sexo, a.nombre AS Nombre, a.arete_hierro AS `Arete / hierro`,
             a.fecha_nacimiento AS `Fecha nacimiento`, a.raza_composicion AS Raza,
             g.nombre AS Grupo, p.nombre AS Ubicación,
             a.fecha_registro AS `Registrado el`
      FROM animales a
      LEFT JOIN animal_grupo_historial gh ON gh.animal_id=a.animal_id AND gh.anulado_en IS NULL AND gh.fecha_fin IS NULL
      LEFT JOIN grupos g ON g.grupo_id=gh.grupo_id
      LEFT JOIN ocupacion_potrero op ON op.grupo_id=gh.grupo_id AND op.anulado_en IS NULL AND op.fecha_fin IS NULL
      LEFT JOIN potreros p ON p.potrero_id=op.potrero_id
      LEFT JOIN animal_estado_historial eh ON eh.animal_id=a.animal_id AND eh.anulado_en IS NULL AND eh.fecha_fin IS NULL
      WHERE a.anulado_en IS NULL ", condicion_filtros, " ORDER BY a.animal_id
    ")
    if (length(parametros) == 0L) {
      dbGetQuery(conexion, consulta_animales)
    } else {
      dbGetQuery(conexion, consulta_animales, params = parametros)
    }
  })

  actualizar_progenitores <- function() {
    datos <- dbGetQuery(conexion, "SELECT animal_id, nombre, arete_hierro, sexo FROM animales WHERE anulado_en IS NULL ORDER BY animal_id")
    etiqueta <- function(sexo) {
      filas <- datos[datos$sexo == sexo, , drop = FALSE]
      etiquetas <- paste0(ifelse(is.na(filas$arete_hierro) | filas$arete_hierro == "", "Sin arete", paste0("Arete: ", filas$arete_hierro)),
        " — ", filas$animal_id, ifelse(is.na(filas$nombre) | filas$nombre == "", "", paste0(" — ", filas$nombre)))
      c(setNames("", "Sin registrar"), setNames(filas$animal_id, etiquetas))
    }
    updateSelectInput(session, "madre_id", choices = etiqueta("HEMBRA"))
    updateSelectInput(session, "padre_id", choices = etiqueta("MACHO"))
    updateSelectizeInput(session, "cria_madre", choices = etiqueta("HEMBRA"), server = TRUE)
  }

  observe({ recargar(); actualizar_progenitores() })
  observeEvent(input$limpiar_madre_animal, {
    updateSelectInput(session, "madre_id", selected = "")
    updateTextInput(session, "animal_madre_arete", value = "")
  })

  etiqueta_animales <- function() {
    datos <- dbGetQuery(conexion, "SELECT animal_id, nombre, arete_hierro FROM animales WHERE anulado_en IS NULL ORDER BY animal_id")
    etiqueta <- paste0(datos$animal_id,
      ifelse(is.na(datos$arete_hierro) | datos$arete_hierro == "", "", paste0(" — Arete: ", datos$arete_hierro)),
      ifelse(is.na(datos$nombre) | datos$nombre == "", "", paste0(" — ", datos$nombre)))
    setNames(datos$animal_id, etiqueta)
  }
  actualizar_manejo <- function() {
    opciones_animales <- etiqueta_animales()
    updateSelectInput(session, "mov_animal", choices = opciones_animales)
    updateSelectInput(session, "peso_animal", choices = opciones_animales)
    estado_animal_seleccionado <- isolate(input$estado_animal)
    estado_animal_actual <- if (!is.null(estado_animal_seleccionado) && nzchar(estado_animal_seleccionado) && estado_animal_seleccionado %in% unname(opciones_animales)) estado_animal_seleccionado else character(0)
    updateSelectizeInput(session, "estado_animal", choices = opciones_animales, selected = estado_animal_actual, server = TRUE)
    ficha_seleccionada <- isolate(input$ficha_animal)
    ficha_actual <- if (!is.null(ficha_seleccionada) && nzchar(ficha_seleccionada) && ficha_seleccionada %in% unname(opciones_animales)) ficha_seleccionada else if (length(opciones_animales)) unname(opciones_animales)[1] else character(0)
    updateSelectizeInput(session, "ficha_animal", choices = opciones_animales, selected = ficha_actual, server = TRUE)
    updateSelectInput(session, "destete_animal", choices = opciones_animales)
    grupos <- dbGetQuery(conexion, "SELECT grupo_id, nombre FROM grupos WHERE activo = 1 ORDER BY nombre")
    updateSelectInput(session, "animal_grupo_inicial", choices = c("Sin grupo" = "", setNames(grupos$grupo_id, grupos$nombre)))
    grupo_cria_actual <- isolate(input$cria_grupo)
    grupo_cria_default <- if (!is.null(grupo_cria_actual) && nzchar(grupo_cria_actual) && grupo_cria_actual %in% as.character(grupos$grupo_id)) grupo_cria_actual else if (any(toupper(grupos$nombre) == "PEQUEÑOS")) as.character(grupos$grupo_id[which(toupper(grupos$nombre) == "PEQUEÑOS")[1]]) else ""
    updateSelectInput(session, "cria_grupo", choices = c("Sin grupo" = "", setNames(grupos$grupo_id, grupos$nombre)), selected = grupo_cria_default)
    updateSelectInput(session, "filtro_grupo_animales", choices = c("Todos los grupos" = "TODOS", setNames(grupos$grupo_id, grupos$nombre)))
    potreros_filtro <- dbGetQuery(conexion, "SELECT potrero_id, nombre FROM potreros WHERE activo=1 AND anulado_en IS NULL ORDER BY nombre")
    updateSelectInput(session, "filtro_potrero_animales", choices = c("Todos los potreros" = "TODOS", setNames(potreros_filtro$potrero_id, potreros_filtro$nombre)))
    estados_filtro <- dbGetQuery(conexion, "SELECT DISTINCT estado_codigo FROM animal_estado_historial WHERE anulado_en IS NULL ORDER BY estado_codigo")
    updateSelectInput(session, "filtro_estado_animales", choices = c("Todos los estados" = "TODOS", "Sin marcar" = "SIN_MARCAR", setNames(estados_filtro$estado_codigo, estados_filtro$estado_codigo)))
    updateSelectInput(session, "mov_grupo", choices = setNames(grupos$grupo_id, grupos$nombre))
    updateSelectInput(session, "ocup_grupo", choices = setNames(grupos$grupo_id, grupos$nombre))
    updateSelectInput(session, "sanidad_grupo", choices = setNames(grupos$grupo_id, grupos$nombre))
    updateSelectInput(session, "sanidad_animal", choices = opciones_animales)
    items <- dbGetQuery(conexion, "SELECT item_id, nombre, unidad_medida FROM items_inventario WHERE activo=1 ORDER BY nombre")
    opciones_items <- if (nrow(items) == 0L) character(0) else setNames(items$item_id, paste0(items$nombre, " (", items$unidad_medida, ")"))
    updateSelectInput(session, "mov_inv_item", choices = opciones_items)
    items_stock <- dbGetQuery(conexion, "SELECT item_id, nombre, unidad_medida, cantidad_actual FROM v_existencias_inventario WHERE cantidad_actual > 0 ORDER BY nombre")
    opciones_stock <- if (nrow(items_stock) == 0L) character(0) else setNames(items_stock$item_id,
      paste0(items_stock$nombre, " — disponible: ", round(items_stock$cantidad_actual, 2), " ", items_stock$unidad_medida))
    updateSelectInput(session, "sanidad_item", choices = opciones_stock)
    potreros <- dbGetQuery(conexion, "SELECT potrero_id, nombre FROM potreros WHERE activo = 1 AND anulado_en IS NULL ORDER BY nombre")
    opciones_potreros <- setNames(potreros$potrero_id, potreros$nombre)
    updateSelectInput(session, "infra_potrero", choices = opciones_potreros)
    updateSelectInput(session, "ocup_potrero", choices = opciones_potreros)
    reproductores <- dbGetQuery(conexion, "SELECT animal_id, nombre, arete_hierro, sexo FROM animales WHERE anulado_en IS NULL ORDER BY animal_id")
    etiquetas_repro <- function(sexo, incluir_vacio = FALSE) {
      filas <- reproductores[reproductores$sexo == sexo, , drop = FALSE]
      etiquetas <- paste0(ifelse(is.na(filas$arete_hierro) | filas$arete_hierro == "", "Sin arete", paste0("Arete: ", filas$arete_hierro)),
        " — ", filas$animal_id, ifelse(is.na(filas$nombre) | filas$nombre == "", "", paste0(" — ", filas$nombre)))
      opciones <- setNames(filas$animal_id, etiquetas)
      if (incluir_vacio) c(setNames("", ""), opciones) else opciones
    }
    updateSelectInput(session, "repro_hembra", choices = etiquetas_repro("HEMBRA"))
    updateSelectInput(session, "repro_macho", choices = etiquetas_repro("MACHO", TRUE))
    updateSelectizeInput(session, "cria_madre", choices = etiquetas_repro("HEMBRA"), server = TRUE)
    updateSelectInput(session, "cria_padre", choices = etiquetas_repro("MACHO", TRUE))
    activos <- dbGetQuery(conexion, "SELECT activo_id, nombre, categoria_codigo, estado_codigo FROM activos WHERE anulado_en IS NULL AND estado_codigo <> 'BAJA' ORDER BY nombre")
    opciones_activos <- if (nrow(activos) == 0L) character(0) else setNames(activos$activo_id,
      paste0(activos$nombre, " — ", activos$categoria_codigo, " (", activos$estado_codigo, ")"))
    updateSelectInput(session, "mant_activo", choices = opciones_activos)
    compradores <- dbGetQuery(conexion, "SELECT tercero_id, nombre FROM terceros WHERE activo=1 AND tipo_codigo='COMPRADOR' ORDER BY nombre")
    opciones_compradores <- if (nrow(compradores) == 0L) character(0) else setNames(compradores$tercero_id, compradores$nombre)
    updateSelectInput(session, "venta_comprador", choices = opciones_compradores)
    animales_venta <- dbGetQuery(conexion, "
      SELECT a.animal_id, a.nombre, p.peso_kg
      FROM animales a
      JOIN pesajes p ON p.pesaje_id=(SELECT p2.pesaje_id FROM pesajes p2
        WHERE p2.animal_id=a.animal_id AND p2.anulado_en IS NULL ORDER BY p2.fecha DESC, p2.pesaje_id DESC LIMIT 1)
      WHERE a.anulado_en IS NULL
        AND COALESCE((SELECT e.estado_codigo FROM animal_estado_historial e WHERE e.animal_id=a.animal_id
          AND e.anulado_en IS NULL AND e.fecha_fin IS NULL ORDER BY e.fecha_inicio DESC, e.estado_historial_id DESC LIMIT 1), 'ACTIVO')
          NOT IN ('VENDIDO','MUERTO','DESCARTADO','TRASLADADO')
        AND NOT EXISTS (SELECT 1 FROM venta_animales d JOIN ventas_ganado v ON v.venta_id=d.venta_id
          WHERE d.animal_id=a.animal_id AND v.anulado_en IS NULL)
      ORDER BY a.animal_id")
    opciones_animales_venta <- if (nrow(animales_venta) == 0L) character(0) else setNames(animales_venta$animal_id,
      paste0(animales_venta$animal_id, ifelse(is.na(animales_venta$nombre) | animales_venta$nombre == "", "", paste0(" — ", animales_venta$nombre)),
        " (", round(animales_venta$peso_kg, 1), " kg)"))
    updateCheckboxGroupInput(session, "venta_animales", choices = opciones_animales_venta)
  }
  observe({ recargar(); actualizar_manejo() })
  observeEvent(input$limpiar_filtros_animales, {
    updateSelectInput(session, "filtro_grupo_animales", selected = "TODOS")
    updateSelectInput(session, "filtro_potrero_animales", selected = "TODOS")
    updateSelectInput(session, "filtro_sexo_animales", selected = "TODOS")
    updateSelectInput(session, "filtro_estado_animales", selected = "TODOS")
    updateTextInput(session, "filtro_arete_animales", value = "")
    updateTextInput(session, "filtro_raza_animales", value = "")
  })
  observeEvent(input$buscar_numero_registrado, {
    removeModal()
    id <- session$userData$animal_duplicado_id
    if (!is.null(id)) updateSelectizeInput(session, "ficha_animal", selected = id, server = TRUE)
  })
  observeEvent(input$editar_potrero_nombre, {
    potrero <- dbGetQuery(conexion, "SELECT potrero_id, nombre, area_ha, pastura_predominante, observaciones FROM potreros WHERE nombre=? AND anulado_en IS NULL LIMIT 1", params = list(input$editar_potrero_nombre))
    if (!nrow(potrero)) return()
    showModal(modalDialog(title = paste("Editar potrero:", potrero$nombre[1]),
      textInput("editar_potrero_nombre_val", "Nombre", value = potrero$nombre[1]),
      numericInput("editar_potrero_area_val", "Área (hectáreas)", value = potrero$area_ha[1], min = 0.01),
      textInput("editar_potrero_pastura_val", "Pastura predominante", value = ifelse(is.na(potrero$pastura_predominante[1]), '', potrero$pastura_predominante[1])),
      textAreaInput("editar_potrero_observaciones_val", "Observaciones", value = ifelse(is.na(potrero$observaciones[1]), '', potrero$observaciones[1]), rows = 3),
      footer = tagList(modalButton("Cancelar"), actionButton("guardar_edicion_potrero", "Guardar cambios", class = "btn-primary")), easyClose = FALSE
    ))
    session$userData$potrero_edicion_id <- potrero$potrero_id[1]
  })
  observeEvent(input$editar_grupo_nombre, {
    grupo <- dbGetQuery(conexion, "SELECT grupo_id, nombre, descripcion FROM grupos WHERE nombre=? AND activo=1 LIMIT 1", params = list(input$editar_grupo_nombre))
    if (!nrow(grupo)) return()
    session$userData$grupo_edicion_id <- grupo$grupo_id[1]
    showModal(modalDialog(title = paste('Grupo:', grupo$nombre[1]),
      textInput('editar_grupo_nombre_val', 'Nombre', value = grupo$nombre[1]),
      textAreaInput('editar_grupo_descripcion_val', 'Descripción', value = ifelse(is.na(grupo$descripcion[1]), '', grupo$descripcion[1]), rows = 3),
      footer = tagList(modalButton('Cerrar'), actionButton('editar_grupo_guardar', 'EDITAR', class='btn-primary'), actionButton('editar_grupo_borrar', 'BORRAR', class='btn-danger')), easyClose = TRUE))
  })
  observeEvent(input$editar_movimiento_concepto, {
    concepto <- trimws(input$editar_movimiento_concepto)
    mov <- dbGetQuery(conexion, "SELECT movimiento_financiero_id, fecha, concepto, valor_total, valor_pagado, estado_pago, observaciones FROM movimientos_financieros WHERE concepto=? AND anulado_en IS NULL ORDER BY fecha DESC, movimiento_financiero_id DESC LIMIT 1", params = list(concepto))
    if (!nrow(mov)) return()
    session$userData$movimiento_edicion_id <- mov$movimiento_financiero_id[1]
    showModal(modalDialog(title = paste("Editar movimiento:", concepto),
      dateInput("editar_mov_fecha", "Fecha", value = as.Date(mov$fecha[1]), format = "yyyy-mm-dd", startview = "year", language = "es"),
      numericInput("editar_mov_total", "Valor total", value = mov$valor_total[1], min = 0.01, step = 1000),
      selectInput("editar_mov_pago", "Estado del pago", c("Pagado" = "PAGADO", "Pendiente" = "PENDIENTE", "Parcial" = "PARCIAL"), selected = mov$estado_pago[1]),
      numericInput("editar_mov_pagado", "Valor pagado", value = mov$valor_pagado[1], min = 0, step = 1000),
      textAreaInput("editar_mov_obs", "Observaciones", value = ifelse(is.na(mov$observaciones[1]), "", mov$observaciones[1]), rows = 3),
      footer = tagList(modalButton("Cancelar"), actionButton("guardar_edicion_movimiento", "Guardar cambios", class = "btn-primary")), easyClose = FALSE))
  })
  observeEvent(input$editar_movimiento_historico_fila, {
    fila <- suppressWarnings(as.integer(input$editar_movimiento_historico_fila))
    ids <- session$userData$historial_movimientos_ids
    if (is.na(fila) || fila < 1L || length(ids) < fila) return()
    id <- ids[fila]
    mov <- dbGetQuery(conexion, "SELECT movimiento_financiero_id, fecha, tipo, categoria_financiera_id, tercero_id, concepto, valor_total, valor_pagado, estado_pago, origen_tipo, observaciones FROM movimientos_financieros WHERE movimiento_financiero_id=? AND anulado_en IS NULL LIMIT 1", params = list(id))
    if (!nrow(mov)) return()
    session$userData$movimiento_edicion_id <- mov$movimiento_financiero_id[1]
    tipo <- as.character(mov$tipo[1])
    categorias <- dbGetQuery(conexion, "SELECT categoria_financiera_id, nombre FROM categorias_financieras WHERE tipo=? AND (activo=1 OR categoria_financiera_id=?) ORDER BY nombre", params = list(tipo, as.integer(mov$categoria_financiera_id[1])))
    terceros <- dbGetQuery(conexion, "SELECT tercero_id, nombre FROM terceros WHERE activo=1 OR tercero_id=? ORDER BY nombre", params = list(if (is.na(mov$tercero_id[1])) -1L else as.integer(mov$tercero_id[1])))
    categoria_choices <- setNames(as.character(categorias$categoria_financiera_id), categorias$nombre)
    tercero_choices <- c("Sin tercero" = "", setNames(as.character(terceros$tercero_id), terceros$nombre))
    tercero_seleccionado <- if (is.na(mov$tercero_id[1])) "" else as.character(mov$tercero_id[1])
    showModal(modalDialog(title = paste("Editar movimiento:", mov$concepto[1]),
      dateInput("editar_hist_fecha", "Fecha", value = as.Date(mov$fecha[1]), format = "yyyy-mm-dd", startview = "year", language = "es"),
      selectInput("editar_hist_tipo", "Tipo", c("Ingreso" = "INGRESO", "Egreso" = "EGRESO"), selected = tipo),
      selectInput("editar_hist_categoria", "Categoría", choices = categoria_choices, selected = as.character(mov$categoria_financiera_id[1])),
      selectInput("editar_hist_tercero", "Tercero", choices = tercero_choices, selected = tercero_seleccionado),
      textInput("editar_hist_concepto", "Concepto", value = mov$concepto[1]),
      numericInput("editar_hist_total", "Total", value = mov$valor_total[1], min = 0.01, step = 1000),
      numericInput("editar_hist_pagado", "Pagado", value = mov$valor_pagado[1], min = 0, step = 1000),
      selectInput("editar_hist_pago", "Estado de pago", c("Pagado" = "PAGADO", "Pendiente" = "PENDIENTE", "Parcial" = "PARCIAL"), selected = mov$estado_pago[1]),
      textInput("editar_hist_origen", "Origen", value = ifelse(is.na(mov$origen_tipo[1]), "", mov$origen_tipo[1])),
      textAreaInput("editar_hist_obs", "Observaciones", value = ifelse(is.na(mov$observaciones[1]), "", mov$observaciones[1]), rows = 3),
      helpText("Nota: cambiar el origen de un registro automático puede afectar su vínculo con la operación que lo creó."),
      footer = tagList(modalButton("Cancelar"), actionButton("guardar_edicion_movimiento_historico", "Guardar cambios", class = "btn-primary")), easyClose = FALSE))
  })
  observeEvent(input$editar_hist_tipo, {
    req(input$editar_hist_tipo)
    categorias <- dbGetQuery(conexion, "SELECT categoria_financiera_id, nombre FROM categorias_financieras WHERE tipo=? AND activo=1 ORDER BY nombre", params = list(input$editar_hist_tipo))
    updateSelectInput(session, "editar_hist_categoria", choices = setNames(as.character(categorias$categoria_financiera_id), categorias$nombre), selected = if (nrow(categorias)) as.character(categorias$categoria_financiera_id[1]) else character(0))
  }, ignoreInit = TRUE)
  observeEvent(input$guardar_edicion_movimiento_historico, {
    id <- session$userData$movimiento_edicion_id
    concepto <- trimws(input$editar_hist_concepto)
    total <- input$editar_hist_total
    estado <- input$editar_hist_pago
    pagado <- input$editar_hist_pagado
    if (is.null(id) || is.null(input$editar_hist_categoria) || !nzchar(input$editar_hist_categoria) || !nzchar(concepto) || is.na(total) || total <= 0) {
      showNotification("Completa fecha, tipo, categoría, concepto y total con valores válidos.", type = "error")
      return()
    }
    if (estado == "PAGADO") pagado <- total
    if (estado == "PENDIENTE") pagado <- 0
    if (is.na(pagado) || pagado < 0 || pagado > total || (estado == "PARCIAL" && (pagado <= 0 || pagado >= total))) {
      showNotification("Revisa los valores y el estado del pago.", type = "error")
      return()
    }
    tryCatch({
      categoria_valida <- dbGetQuery(conexion, "SELECT 1 AS valido FROM categorias_financieras WHERE categoria_financiera_id=? AND tipo=?", params = list(as.integer(input$editar_hist_categoria), input$editar_hist_tipo))
      if (!nrow(categoria_valida)) stop("La categoría seleccionada no corresponde al tipo de movimiento.")
      dbExecute(conexion, "UPDATE movimientos_financieros SET fecha=?, tipo=?, categoria_financiera_id=?, tercero_id=?, concepto=?, valor_total=?, valor_pagado=?, estado_pago=?, fecha_pago=?, origen_tipo=?, observaciones=? WHERE movimiento_financiero_id=? AND anulado_en IS NULL",
        params = list(as.character(input$editar_hist_fecha), input$editar_hist_tipo, as.integer(input$editar_hist_categoria),
          if (is.null(input$editar_hist_tercero) || !nzchar(input$editar_hist_tercero)) NA_integer_ else as.integer(input$editar_hist_tercero),
          concepto, total, pagado, estado, if (estado == "PENDIENTE") NA_character_ else as.character(input$editar_hist_fecha),
          if (nzchar(trimws(input$editar_hist_origen))) trimws(input$editar_hist_origen) else NA_character_,
          if (nzchar(trimws(input$editar_hist_obs))) trimws(input$editar_hist_obs) else NA_character_, id))
      removeModal()
      recargar(recargar() + 1L)
      showNotification("Se actualizaron los datos del movimiento.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo actualizar el movimiento:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$guardar_edicion_movimiento, {
    id <- session$userData$movimiento_edicion_id
    if (is.null(id)) return()
    total <- input$editar_mov_total; pagado <- input$editar_mov_pagado
    if (input$editar_mov_pago == "PAGADO") pagado <- total
    if (input$editar_mov_pago == "PENDIENTE") pagado <- 0
    if (is.na(total) || total <= 0 || is.na(pagado) || pagado < 0 || pagado > total || (input$editar_mov_pago == "PARCIAL" && (pagado <= 0 || pagado >= total))) {
      showNotification("Revisa el valor total y el pago.", type = "error"); return()
    }
    tryCatch({
      dbExecute(conexion, "UPDATE movimientos_financieros SET fecha=?, valor_total=?, estado_pago=?, valor_pagado=?, fecha_pago=?, observaciones=? WHERE movimiento_financiero_id=? AND anulado_en IS NULL", params = list(as.character(input$editar_mov_fecha), total, input$editar_mov_pago, pagado, if (input$editar_mov_pago == "PENDIENTE") NA_character_ else as.character(input$editar_mov_fecha), if (nzchar(trimws(input$editar_mov_obs))) trimws(input$editar_mov_obs) else NA_character_, id))
      removeModal(); recargar(recargar() + 1L); showNotification("Movimiento actualizado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo actualizar:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$editar_animal_id, {
    id <- trimws(input$editar_animal_id)
    animal <- dbGetQuery(conexion, "SELECT * FROM animales WHERE animal_id=? AND anulado_en IS NULL LIMIT 1", params = list(id))
    if (!nrow(animal)) return()
    otros <- dbGetQuery(conexion, "SELECT animal_id, sexo FROM animales WHERE anulado_en IS NULL AND animal_id<>? ORDER BY animal_id", params = list(id))
    madres <- otros[otros$sexo == "HEMBRA", , drop = FALSE]
    padres <- otros[otros$sexo == "MACHO", , drop = FALSE]
    opciones <- function(x) if (!nrow(x)) character(0) else setNames(x$animal_id, x$animal_id)
    fecha_edicion <- if (is.na(animal$fecha_nacimiento[1]) || !nzchar(animal$fecha_nacimiento[1])) NULL else as.Date(animal$fecha_nacimiento[1])
    madre_edicion <- if (is.na(animal$madre_id[1])) "" else as.character(animal$madre_id[1])
    padre_edicion <- if (is.na(animal$padre_id[1])) "" else as.character(animal$padre_id[1])
    grupo_actual <- dbGetQuery(conexion, "SELECT grupo_id FROM animal_grupo_historial WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL ORDER BY fecha_inicio DESC LIMIT 1", params = list(id))
    grupos_edicion <- dbGetQuery(conexion, "SELECT grupo_id, nombre FROM grupos WHERE activo=1 ORDER BY nombre")
    grupo_seleccionado <- if (nrow(grupo_actual)) as.character(grupo_actual$grupo_id[1]) else ""
    estado_actual <- dbGetQuery(conexion, "SELECT estado_historial_id, estado_codigo, fecha_inicio, motivo FROM animal_estado_historial WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL ORDER BY fecha_inicio DESC, estado_historial_id DESC LIMIT 1", params = list(id))
    estado_seleccionado <- if (nrow(estado_actual)) estado_actual$estado_codigo[1] else "ACTIVO"
    estado_fecha_inicio <- if (nrow(estado_actual) && !is.na(estado_actual$fecha_inicio[1])) as.Date(estado_actual$fecha_inicio[1]) else Sys.Date()
    estado_motivo <- if (nrow(estado_actual) && !is.na(estado_actual$motivo[1])) as.character(estado_actual$motivo[1]) else ""
    session$userData$animal_edicion_id <- id
    showModal(modalDialog(title = paste("Editar animal:", id),
      textInput("editar_animal_nombre", "Nombre", value = ifelse(is.na(animal$nombre[1]), "", animal$nombre[1])),
      textInput("editar_animal_arete", "Arete o hierro", value = ifelse(is.na(animal$arete_hierro[1]), "", animal$arete_hierro[1])),
      dateInput("editar_animal_fecha", "Fecha de nacimiento", value = if (is.null(fecha_edicion)) NA else fecha_edicion),
      actionButton("limpiar_fecha_editar_animal", "Limpiar fecha", class = "btn-default"),
      selectInput("editar_animal_madre", "Madre", choices = c("Sin registrar" = "", opciones(madres)), selected = madre_edicion),
      selectInput("editar_animal_padre", "Padre", choices = c("Sin registrar" = "", opciones(padres)), selected = padre_edicion),
      selectInput("editar_animal_grupo", "Grupo actual", choices = c("Sin grupo" = "", setNames(grupos_edicion$grupo_id, grupos_edicion$nombre)), selected = grupo_seleccionado),
      selectInput("editar_animal_estado", "Estado actual", choices = c("Activo" = "ACTIVO", "Sin marcar" = "SIN_MARCAR", "En observación" = "OBSERVACION", "En tratamiento" = "TRATAMIENTO", "En recuperación" = "RECUPERACION", "En venta" = "VENTA", "Vendido" = "VENDIDO", "Muerto" = "MUERTO", "Descartado" = "DESCARTADO", "Trasladado" = "TRASLADADO"), selected = estado_seleccionado),
      dateInput("editar_animal_estado_fecha_inicio", "Fecha de inicio del estado", value = estado_fecha_inicio, format = "yyyy-mm-dd", language = "es"),
      textInput("editar_animal_estado_motivo", "Motivo del estado", value = estado_motivo),
      textInput("editar_animal_raza", "Raza o composición", value = ifelse(is.na(animal$raza_composicion[1]), "", animal$raza_composicion[1])),
      textAreaInput("editar_animal_observaciones", "Observaciones", value = ifelse(is.na(animal$observaciones[1]), "", animal$observaciones[1]), rows = 3),
      footer = tagList(modalButton("Cancelar"), actionButton("guardar_edicion_animal", "Guardar cambios", class = "btn-primary"), actionButton("borrar_animal", "BORRAR ANIMAL", class = "btn-danger")), easyClose = FALSE
    ))
  })
  observeEvent(input$limpiar_fecha_editar_animal, {
    updateDateInput(session, "editar_animal_fecha", value = NA)
  })
  observeEvent(input$guardar_edicion_animal, {
    id <- session$userData$animal_edicion_id
    if (is.null(id)) return()
    vacio <- function(x) if (is.null(x) || !nzchar(trimws(x))) NA_character_ else trimws(x)
    fecha_entrada <- input$editar_animal_fecha
    fecha <- if (is.null(fecha_entrada) || length(fecha_entrada) == 0L || all(is.na(fecha_entrada)) || !nzchar(trimws(as.character(fecha_entrada[1])))) NA_character_ else as.character(fecha_entrada[1])
    fecha_estado_entrada <- input$editar_animal_estado_fecha_inicio
    if (is.null(fecha_estado_entrada) || !length(fecha_estado_entrada) || is.na(fecha_estado_entrada[1]) || !nzchar(trimws(as.character(fecha_estado_entrada[1])))) {
      showNotification("Indica la fecha de inicio del estado.", type = "error"); return()
    }
    fecha_estado <- as.character(fecha_estado_entrada[1])
    tryCatch({
      dbExecute(conexion, "UPDATE animales SET nombre=?, arete_hierro=?, fecha_nacimiento=?, madre_id=?, padre_id=?, raza_composicion=?, observaciones=? WHERE animal_id=?",
        params = list(vacio(input$editar_animal_nombre), vacio(input$editar_animal_arete), fecha, vacio(input$editar_animal_madre), vacio(input$editar_animal_padre), vacio(input$editar_animal_raza), vacio(input$editar_animal_observaciones), id))
      grupo_nuevo <- vacio(input$editar_animal_grupo)
      grupo_anterior <- dbGetQuery(conexion, "SELECT grupo_id FROM animal_grupo_historial WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL ORDER BY fecha_inicio DESC LIMIT 1", params = list(id))
      grupo_anterior_id <- if (nrow(grupo_anterior)) as.character(grupo_anterior$grupo_id[1]) else NA_character_
      if (!identical(grupo_nuevo, grupo_anterior_id)) {
        dbExecute(conexion, "UPDATE animal_grupo_historial SET fecha_fin=date('now','localtime') WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL", params = list(id))
        if (!is.na(grupo_nuevo)) dbExecute(conexion, "INSERT INTO animal_grupo_historial(animal_id, grupo_id, fecha_inicio, motivo) VALUES (?, ?, date('now','localtime'), 'Grupo actualizado desde edición del animal')", params = list(id, as.integer(grupo_nuevo)))
      }
      estado_nuevo <- vacio(input$editar_animal_estado)
      motivo_estado <- vacio(input$editar_animal_estado_motivo)
      estado_anterior <- dbGetQuery(conexion, "SELECT estado_historial_id, estado_codigo FROM animal_estado_historial WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL ORDER BY fecha_inicio DESC, estado_historial_id DESC LIMIT 1", params = list(id))
      estado_anterior_codigo <- if (nrow(estado_anterior)) estado_anterior$estado_codigo[1] else NA_character_
      if (!is.na(estado_nuevo)) {
        dbWithTransaction(conexion, {
          if (nrow(estado_anterior) && !identical(estado_nuevo, estado_anterior_codigo)) {
            if (estado_nuevo == "SIN_MARCAR") dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=? WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL AND estado_codigo='SIN_MARCAR'", params = list(fecha_estado, id))
            if (estado_nuevo != "SIN_MARCAR") dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=? WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL AND estado_codigo <> 'SIN_MARCAR'", params = list(fecha_estado, id))
            dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo) VALUES (?, ?, ?, ?)", params = list(id, estado_nuevo, fecha_estado, motivo_estado))
          } else if (nrow(estado_anterior)) {
            id_estado <- estado_anterior$estado_historial_id[1]
            dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_inicio=?, motivo=? WHERE estado_historial_id=? AND animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL", params = list(fecha_estado, motivo_estado, id_estado, id))
            if (identical(estado_anterior_codigo, "SIN_MARCAR")) {
              dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=? WHERE estado_historial_id=(SELECT estado_historial_id FROM animal_estado_historial WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NOT NULL AND estado_codigo='SIN_MARCAR' AND estado_historial_id<>? ORDER BY fecha_inicio DESC, estado_historial_id DESC LIMIT 1)", params = list(fecha_estado, id, id_estado))
            } else {
              dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=? WHERE estado_historial_id=(SELECT estado_historial_id FROM animal_estado_historial WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NOT NULL AND estado_codigo<>'SIN_MARCAR' AND estado_historial_id<>? ORDER BY fecha_inicio DESC, estado_historial_id DESC LIMIT 1)", params = list(fecha_estado, id, id_estado))
            }
          } else {
            dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo) VALUES (?, ?, ?, ?)", params = list(id, estado_nuevo, fecha_estado, motivo_estado))
          }
        })
      }
      removeModal(); recargar(recargar() + 1L); showNotification("Animal actualizado correctamente.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo actualizar el animal:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$borrar_animal, {
    id <- session$userData$animal_edicion_id
    if (is.null(id)) return()
    showModal(modalDialog(
      title = "¿SEGURO?",
      p(paste("¿Deseas borrar el animal", id, "? El historial se conservará, pero dejará de aparecer en los listados activos.")),
      footer = tagList(modalButton("Cancelar"), actionButton("confirmar_borrar_animal", "Sí, borrar animal", class = "btn-danger")),
      easyClose = FALSE
    ))
  })
  observeEvent(input$confirmar_borrar_animal, {
    id <- session$userData$animal_edicion_id
    if (is.null(id)) return()
    tryCatch({
      dbWithTransaction(conexion, {
        dbExecute(conexion, "UPDATE animales SET anulado_en=datetime('now'), motivo_anulacion='Borrado desde la ficha del animal' WHERE animal_id=? AND anulado_en IS NULL", params = list(id))
        dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=COALESCE(fecha_fin, date('now')) WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL", params = list(id))
        dbExecute(conexion, "UPDATE animal_grupo_historial SET fecha_fin=COALESCE(fecha_fin, date('now')) WHERE animal_id=? AND anulado_en IS NULL AND fecha_fin IS NULL", params = list(id))
      })
      removeModal(); recargar(recargar() + 1L); showNotification(paste("Animal", id, "borrado. Su historial se conserva."), type = "message")
    }, error = function(e) showNotification(paste("No se pudo borrar el animal:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$editar_grupo_guardar, {
    id <- session$userData$grupo_edicion_id
    if (is.null(id) || !nzchar(trimws(input$editar_grupo_nombre_val))) { showNotification('Escribe un nombre válido.', type='error'); return() }
    tryCatch({
      dbExecute(conexion, "UPDATE grupos SET nombre=?, descripcion=? WHERE grupo_id=?", params=list(trimws(input$editar_grupo_nombre_val), if(nzchar(trimws(input$editar_grupo_descripcion_val))) trimws(input$editar_grupo_descripcion_val) else NA_character_, id))
      removeModal(); recargar(recargar()+1L); showNotification('Grupo actualizado.', type='message')
    }, error=function(e) showNotification(paste('No se pudo editar:', conditionMessage(e)), type='error', duration=NULL))
  })
  observeEvent(input$editar_grupo_borrar, {
    id <- session$userData$grupo_edicion_id
    if (is.null(id)) return()
    tryCatch({
      dbExecute(conexion, "UPDATE grupos SET activo=0 WHERE grupo_id=?", params=list(id))
      removeModal(); recargar(recargar()+1L); showNotification('Grupo desactivado. Su historial se conserva.', type='message')
    }, error=function(e) showNotification(paste('No se pudo borrar:', conditionMessage(e)), type='error', duration=NULL))
  })
  observeEvent(input$guardar_edicion_potrero, {
    id <- session$userData$potrero_edicion_id
    if (is.null(id) || !nzchar(trimws(input$editar_potrero_nombre_val))) { showNotification('Escribe un nombre válido.', type='error'); return() }
    tryCatch({
      dbExecute(conexion, "UPDATE potreros SET nombre=?, area_ha=?, pastura_predominante=?, observaciones=? WHERE potrero_id=?",
        params = list(trimws(input$editar_potrero_nombre_val), if (is.na(input$editar_potrero_area_val)) NA_real_ else input$editar_potrero_area_val,
          if (nzchar(trimws(input$editar_potrero_pastura_val))) trimws(input$editar_potrero_pastura_val) else NA_character_,
          if (nzchar(trimws(input$editar_potrero_observaciones_val))) trimws(input$editar_potrero_observaciones_val) else NA_character_, id))
      removeModal(); recargar(recargar() + 1L); showNotification('Potrero actualizado.', type='message')
    }, error = function(e) showNotification(paste('No se pudo actualizar:', conditionMessage(e)), type='error', duration=NULL))
  })
  actualizar_finanzas <- function() {
    tipo <- if (is.null(input$fin_tipo) || !nzchar(input$fin_tipo)) "INGRESO" else input$fin_tipo
    categorias <- dbGetQuery(conexion, "SELECT categoria_financiera_id, nombre FROM categorias_financieras
      WHERE tipo=? AND activo=1 ORDER BY nombre", params = list(tipo))
    opciones_categorias <- if (nrow(categorias) == 0L) character(0) else setNames(categorias$categoria_financiera_id, categorias$nombre)
    updateSelectInput(session, "fin_categoria", choices = opciones_categorias)
    terceros <- dbGetQuery(conexion, "SELECT tercero_id, tipo_codigo, nombre FROM terceros WHERE activo=1 ORDER BY nombre")
    opciones_terceros <- if (nrow(terceros) == 0L) character(0) else setNames(terceros$tercero_id,
      paste0(terceros$nombre, " (", terceros$tipo_codigo, ")"))
    updateSelectInput(session, "fin_tercero", choices = c(setNames("", "Sin tercero"), opciones_terceros))
    comprador_leche_actual <- isolate(input$leche_comprador)
    comprador_leche_seleccionado <- if (!is.null(comprador_leche_actual) && comprador_leche_actual %in% c("", unname(opciones_terceros))) comprador_leche_actual else ""
    updateSelectInput(session, "leche_comprador", choices = c(setNames("", "Sin comprador"), opciones_terceros), selected = comprador_leche_seleccionado)
    updateSelectInput(session, "compra_ganado_tercero", choices = c(setNames("", "Sin vendedor"), opciones_terceros))
  }
  observe({ recargar(); input$fin_tipo; actualizar_finanzas() })
  observe({
    recargar()
    req(input$mov_inv_item)
    lotes <- dbGetQuery(conexion, "SELECT lote_id, codigo_lote, fecha_vencimiento FROM inventario_lotes WHERE item_id=? ORDER BY fecha_vencimiento, fecha_ingreso",
                         params = list(as.integer(input$mov_inv_item)))
    opciones_lotes <- character(0)
    if (nrow(lotes) > 0L) {
      etiqueta <- ifelse(is.na(lotes$codigo_lote) | lotes$codigo_lote == "", paste("Lote", lotes$lote_id), lotes$codigo_lote)
      etiqueta <- ifelse(is.na(lotes$fecha_vencimiento), etiqueta, paste0(etiqueta, " — vence ", lotes$fecha_vencimiento))
      opciones_lotes <- setNames(lotes$lote_id, etiqueta)
    }
    updateSelectInput(session, "mov_inv_lote_existente", choices = c(setNames("", ""), opciones_lotes))
  })

  output$proximo_id <- renderText({
    recargar()
    paste("ID que se asignará:", siguiente_animal_id(conexion, input$sexo))
  })
  output$tabla_animales <- renderTable(animales(), striped = TRUE, bordered = TRUE, spacing = "s")
  output$contador_animales_filtrados <- renderText({ paste("Resultados:", nrow(animales())) })
  output$dash_total_animales <- renderText({ paste("Total de animales:", nrow(animales())) })
  output$dash_animales_estado <- renderUI({
    recargar()
    x <- dbGetQuery(conexion, "SELECT estado_codigo, COUNT(DISTINCT animal_id) AS n FROM animal_estado_historial WHERE anulado_en IS NULL AND fecha_fin IS NULL GROUP BY estado_codigo ORDER BY estado_codigo")
    if (!nrow(x)) return(tags$span("Sin estados registrados"))
    nombres_estado <- tools::toTitleCase(tolower(gsub("_", " ", x$estado_codigo)))
    tags$div(lapply(seq_len(nrow(x)), function(i) tags$div(paste0(nombres_estado[i], ": ", x$n[i]))))
  })
  output$dash_stock_bajo <- renderText({
    recargar()
    n <- dbGetQuery(conexion, "SELECT COUNT(*) AS n FROM v_existencias_inventario WHERE cantidad_actual <= stock_minimo")$n[1]
    paste("Productos con stock bajo:", n)
  })
  output$dash_vencimientos_kpi <- renderText({
    recargar()
    n <- dbGetQuery(conexion, "SELECT COUNT(*) AS n FROM inventario_lotes WHERE fecha_vencimiento IS NOT NULL AND fecha_vencimiento <= date('now','+90 days')")$n[1]
    paste("Lotes que vencen en 90 días:", n)
  })
  output$dash_balance <- renderText({
    recargar(); x <- dbGetQuery(conexion, "SELECT COALESCE(SUM(CASE WHEN tipo='INGRESO' THEN valor_total ELSE -valor_total END),0) AS n FROM movimientos_financieros WHERE anulado_en IS NULL")$n[1]
    paste0("Balance: $ ", format(round(x, 2), big.mark = ".", decimal.mark = ",", nsmall = 2))
  })
  output$dash_pendiente <- renderText({
    recargar(); x <- dbGetQuery(conexion, "SELECT COALESCE(SUM(valor_total-valor_pagado),0) AS n FROM movimientos_financieros WHERE anulado_en IS NULL")$n[1]
    paste0("Pendiente: $ ", format(round(x, 2), big.mark = ".", decimal.mark = ",", nsmall = 2))
  })
  output$dash_ventas_mes <- renderText({
    recargar(); n <- dbGetQuery(conexion, "SELECT COUNT(*) AS n FROM ventas_ganado WHERE anulado_en IS NULL AND strftime('%Y-%m',fecha)=strftime('%Y-%m','now')")$n[1]
    paste("Ventas este mes:", n)
  })
  output$dash_ultima_venta <- renderText({
    recargar(); x <- dbGetQuery(conexion, "SELECT MAX(fecha) AS fecha FROM ventas_ganado WHERE anulado_en IS NULL")$fecha[1]
    paste("Última venta:", ifelse(is.na(x), "No registrada", x))
  })
  output$dash_grupos <- renderTable({
    recargar(); dbGetQuery(conexion, "SELECT g.nombre AS Grupo, CAST(COUNT(DISTINCT h.animal_id) AS INTEGER) AS Animales FROM grupos g LEFT JOIN animal_grupo_historial h ON h.grupo_id=g.grupo_id AND h.fecha_fin IS NULL AND h.anulado_en IS NULL WHERE g.activo=1 GROUP BY g.grupo_id, g.nombre ORDER BY g.nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s")
  output$grafica_natalidad <- renderPlotly({
    recargar()
    x <- dbGetQuery(conexion, "
      SELECT a.fecha_nacimiento AS fecha
      FROM animales a
      WHERE a.anulado_en IS NULL AND a.fecha_nacimiento IS NOT NULL AND TRIM(a.fecha_nacimiento) <> ''
      UNION ALL
      SELECT e.fecha
      FROM eventos_reproductivos e
      WHERE e.tipo_codigo='PARTO' AND e.anulado_en IS NULL AND e.fecha IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM animales a2
          WHERE a2.anulado_en IS NULL AND a2.fecha_nacimiento=e.fecha
            AND e.observaciones LIKE '%' || a2.animal_id || '%'
        )
      ORDER BY fecha")
    if (nrow(x)) {
      fechas_filtro <- rango_dashboard()
      x <- x[as.Date(x$fecha) >= fechas_filtro[1] & as.Date(x$fecha) <= fechas_filtro[2], , drop = FALSE]
    }
    if (!nrow(x)) return(plot_ly() %>% layout(title = "Sin partos registrados"))
    fechas <- as.Date(x$fecha)
    if (identical(input$dash_natalidad_periodo, "TRIMESTRE")) {
      etiquetas <- paste(format(fechas, '%Y'), paste0('T', ((as.integer(format(fechas, '%m')) - 1) %/% 3) + 1), sep = '-')
    } else etiquetas <- format(fechas, '%Y-%m')
    conteo <- as.data.frame(table(etiquetas), stringsAsFactors = FALSE)
    names(conteo) <- c("periodo", "nacimientos")
    plot_ly(conteo, x = ~periodo, y = ~nacimientos, type = "bar", marker = list(color = "#5d8b5c"),
      hovertemplate = "%{x}<br>Nacimientos: %{y}<extra></extra>") %>%
      layout(title = "Nacimientos registrados", xaxis = list(title = "Periodo", rangeslider = list(visible = TRUE)), yaxis = list(title = "Nacimientos"))
  })
  output$grafica_inventario_grupo <- renderPlot({
    recargar()
    x <- dbGetQuery(conexion, "SELECT g.nombre AS grupo, CAST(COUNT(DISTINCT h.animal_id) AS INTEGER) AS total FROM grupos g LEFT JOIN animal_grupo_historial h ON h.grupo_id=g.grupo_id AND h.fecha_fin IS NULL AND h.anulado_en IS NULL WHERE g.activo=1 GROUP BY g.grupo_id, g.nombre ORDER BY g.nombre")
    if (!nrow(x)) { plot.new(); text(.5, .5, 'Sin grupos registrados'); return() }
    totales <- as.integer(x$total)
    barplot(totales, names.arg = x$grupo, col = '#b86f3f', border = NA, las = 2, ylab = 'Cabezas de ganado', main = 'Ganado por grupo')
  })
  output$grafica_rentabilidad_actividad <- renderPlot({
    recargar()
    rango <- rango_dashboard()
    x <- dbGetQuery(conexion, "SELECT CASE WHEN m.origen_tipo='VENTA_GANADO' THEN 'Ganado' WHEN m.origen_tipo='PRODUCCION_LECHE' THEN 'Leche' WHEN m.tipo='INGRESO' THEN COALESCE(NULLIF(m.concepto,''),'Otros ingresos') ELSE COALESCE(c.nombre,'Otros egresos') END AS actividad, m.tipo AS tipo, SUM(m.valor_total) AS valor FROM movimientos_financieros m LEFT JOIN categorias_financieras c ON c.categoria_financiera_id=m.categoria_financiera_id WHERE m.anulado_en IS NULL AND date(m.fecha) BETWEEN date(?) AND date(?) GROUP BY actividad, m.tipo ORDER BY actividad", params = as.list(rango))
    if (!nrow(x)) { plot.new(); text(.5, .5, 'Sin movimientos financieros'); return() }
    actividades <- unique(x$actividad); ingresos <- sapply(actividades, function(a) sum(x$valor[x$actividad == a & x$tipo == 'INGRESO'])); egresos <- sapply(actividades, function(a) sum(x$valor[x$actividad == a & x$tipo == 'EGRESO'])); utilidad <- ingresos - egresos
    valores <- rbind(Ingresos = ingresos, Egresos = egresos, Utilidad = utilidad)
    barplot(valores, beside = TRUE, names.arg = actividades, col = c('#5d8b5c', '#b86f3f', '#d8a85b'), border = NA, las = 2, ylab = 'Pesos colombianos', main = 'Ingresos, egresos y utilidad por actividad', legend.text = TRUE, args.legend = list(x = 'topright', bty = 'n', cex = .8))
  })
  agrupar_fecha <- function(fecha, periodo) {
    if (periodo == 'DIA') return(format(fecha, '%Y-%m-%d'))
    if (periodo == 'QUINCENA') return(ifelse(as.integer(format(fecha, '%d')) <= 15, paste0(format(fecha, '%Y-%m'), '-01'), paste0(format(fecha, '%Y-%m'), '-16')))
    if (periodo == 'SEMANA') return(format(fecha - as.integer(format(fecha, '%u')) + 1, '%Y-%m-%d'))
    if (periodo == 'ANO') return(format(fecha, '%Y'))
    format(fecha, '%Y-%m')
  }
  rango_dashboard <- function() as.character(c(Sys.Date() - 365, Sys.Date()))
  filtrar_rango_dashboard <- function(x, columna = "fecha") {
    rango <- rango_dashboard()
    if (nrow(x)) {
      fechas <- as.Date(x[[columna]])
      x <- x[fechas >= as.Date(rango[1]) & fechas <= as.Date(rango[2]), , drop = FALSE]
    }
    x
  }
  output$grafica_rentabilidad_general <- renderPlot({
    recargar(); x <- dbGetQuery(conexion, "SELECT fecha, tipo, valor_total FROM movimientos_financieros WHERE anulado_en IS NULL ORDER BY fecha"); x <- filtrar_rango_dashboard(x)
    if (!nrow(x)) { plot.new(); text(.5,.5,'Sin movimientos financieros'); return() }
    x$fecha <- as.Date(x$fecha); x$periodo <- agrupar_fecha(x$fecha, input$dash_rentabilidad_periodo); ing <- tapply(ifelse(x$tipo=='INGRESO',x$valor_total,0), x$periodo, sum); egr <- tapply(ifelse(x$tipo=='EGRESO',x$valor_total,0), x$periodo, sum); per <- sort(unique(x$periodo)); utilidad <- as.numeric(ing[per]) - as.numeric(egr[per]); plot(seq_along(per), utilidad, type='o', pch=16, col='#2f6b50', xaxt='n', xlab='Tiempo', ylab='Pesos colombianos', main='Rentabilidad general'); axis(1, at=seq_along(per), labels=per, las=2, cex.axis=.75); abline(h=0, lty=2, col='grey')
  })
  output$grafica_leche <- renderPlotly({
    recargar(); x <- dbGetQuery(conexion, "SELECT fecha, litros FROM produccion_leche WHERE anulado_en IS NULL ORDER BY fecha"); x <- filtrar_rango_dashboard(x)
    if (!nrow(x)) return(plot_ly() %>% layout(title = 'Sin producción de leche registrada'))
    x$fecha <- as.Date(x$fecha); x$periodo <- agrupar_fecha(x$fecha, input$dash_leche_periodo)
    datos <- aggregate(litros ~ periodo, x, sum)
    datos$fecha <- as.Date(paste0(datos$periodo, ifelse(input$dash_leche_periodo == 'ANO', '-01-01', ifelse(input$dash_leche_periodo == 'MES', '-01', ''))))
    datos$etiqueta <- datos$periodo
    if (input$dash_leche_periodo == 'QUINCENA') datos$etiqueta <- paste0(format(datos$fecha, '%Y-%m'), ifelse(as.integer(format(datos$fecha, '%d')) == 1, ' Q1', ' Q2'))
    plot_ly(datos, x = ~fecha, y = ~litros, type = 'scatter', mode = 'lines+markers',
      text = ~paste0(etiqueta, '<br>Litros: ', format(round(litros, 2), big.mark = '.', decimal.mark = ',')), hoverinfo = 'text', line = list(color = '#5d8b5c'), marker = list(color = '#2f6b50')) %>%
      layout(title = 'Producción de leche', autosize = TRUE, width = NULL, xaxis = list(title = 'Tiempo', type = 'date', rangeslider = list(visible = TRUE)), yaxis = list(title = 'Litros'), hovermode = 'x unified') %>%
      config(responsive = TRUE, displaylogo = FALSE)
  })
  output$grafica_finanzas_trimestral <- renderPlot({
    recargar(); x <- dbGetQuery(conexion, "SELECT fecha, tipo, valor_total FROM movimientos_financieros WHERE anulado_en IS NULL ORDER BY fecha"); x <- filtrar_rango_dashboard(x)
    if (!nrow(x)) { plot.new(); text(.5,.5,'Sin movimientos financieros'); return() }
    x$fecha <- as.Date(x$fecha); x$periodo <- paste(format(x$fecha,'%Y'), paste0('T', ((as.integer(format(x$fecha,'%m'))-1)%/%3)+1), sep='-'); per <- sort(unique(x$periodo)); ing <- sapply(per, function(p) sum(x$valor_total[x$periodo==p & x$tipo=='INGRESO'])); egr <- sapply(per, function(p) sum(x$valor_total[x$periodo==p & x$tipo=='EGRESO'])); vals <- rbind(Ingresos=ing, Egresos=egr, Utilidad=ing-egr); barplot(vals, beside=TRUE, names.arg=per, col=c('#5d8b5c','#b86f3f','#d8a85b'), border=NA, las=2, ylab='Pesos colombianos', main='Resultado financiero trimestral', legend.text=TRUE, args.legend=list(x='topright',bty='n',cex=.75))
  })
  output$grafica_cabezas_tiempo <- renderPlot({
    recargar(); x <- dbGetQuery(conexion, "SELECT fecha_nacimiento AS fecha, 1 AS cambio FROM animales WHERE anulado_en IS NULL AND fecha_nacimiento IS NOT NULL AND TRIM(fecha_nacimiento) <> '' UNION ALL SELECT v.fecha, -1 AS cambio FROM ventas_ganado v JOIN venta_animales d ON d.venta_id=v.venta_id JOIN animales a ON a.animal_id=d.animal_id WHERE v.anulado_en IS NULL AND a.fecha_nacimiento IS NOT NULL AND TRIM(a.fecha_nacimiento) <> ''"); x <- filtrar_rango_dashboard(x)
    if (!nrow(x)) { plot.new(); text(.5,.5,'Sin animales con fecha de nacimiento'); return() }
    x$fecha <- as.Date(x$fecha); x <- aggregate(cambio ~ fecha, x, sum); x <- x[order(x$fecha),]; x$total <- cumsum(x$cambio); plot(x$fecha, x$total, type='o', pch=16, col='#2f6b50', xlab='Fecha', ylab='Cabezas de ganado', main='Cabezas de ganado en el tiempo'); grid()
  })
  output$dash_mantenimientos <- renderTable({
    recargar(); dbGetQuery(conexion, "SELECT m.fecha AS Fecha, a.nombre AS Activo, m.tipo_codigo AS Tipo, m.costo AS Costo FROM mantenimientos_activos m JOIN activos a ON a.activo_id=m.activo_id WHERE m.anulado_en IS NULL ORDER BY m.fecha DESC LIMIT 8")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$dash_vencimientos <- renderTable({
    recargar(); dbGetQuery(conexion, "SELECT i.nombre AS Producto, l.fecha_vencimiento AS Vence, ROUND(SUM(CASE m.tipo_codigo WHEN 'ENTRADA' THEN m.cantidad WHEN 'DEVOLUCION' THEN m.cantidad WHEN 'AJUSTE_POSITIVO' THEN m.cantidad ELSE -m.cantidad END),2) AS Cantidad FROM inventario_lotes l JOIN items_inventario i ON i.item_id=l.item_id LEFT JOIN movimientos_inventario m ON m.lote_id=l.lote_id AND m.anulado_en IS NULL WHERE l.fecha_vencimiento IS NOT NULL AND l.fecha_vencimiento <= date('now','+90 days') GROUP BY l.lote_id, i.item_id, i.nombre, l.fecha_vencimiento HAVING Cantidad > 0 ORDER BY l.fecha_vencimiento LIMIT 10")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$dash_finanzas <- renderTable({
    recargar(); dbGetQuery(conexion, "SELECT fecha AS Fecha, tipo AS Tipo, concepto AS Concepto, valor_total AS Total, estado_pago AS Pago FROM movimientos_financieros WHERE anulado_en IS NULL ORDER BY fecha DESC, movimiento_financiero_id DESC LIMIT 8")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$total_animales <- renderText(paste("Total:", nrow(animales())))
  output$total_hembras <- renderText(paste("Hembras:", sum(animales()$Sexo == "HEMBRA")))
  output$total_machos <- renderText(paste("Machos:", sum(animales()$Sexo == "MACHO")))
  output$tabla_grupos <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT nombre AS Grupo, descripcion AS Descripción FROM grupos WHERE activo = 1 ORDER BY nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s")
  output$tabla_pesajes <- renderTable({
    recargar()
    dbGetQuery(conexion, "
      SELECT p.fecha AS Fecha, p.animal_id AS Animal, p.peso_kg AS `Peso (kg)`
      FROM pesajes p WHERE p.anulado_en IS NULL ORDER BY p.fecha DESC, p.pesaje_id DESC LIMIT 10")
  }, striped = TRUE, bordered = TRUE, spacing = "s")
  animal_ficha <- reactive({
    req(!is.null(input$ficha_animal), nzchar(input$ficha_animal))
    input$ficha_animal
  })
  output$ficha_titulo <- renderText({ paste("Ficha de", animal_ficha()) })
  output$ficha_resumen <- renderTable({
    id <- animal_ficha()
    dbGetQuery(conexion, "
      SELECT a.animal_id AS ID, a.sexo AS Sexo, a.nombre AS Nombre, a.arete_hierro AS `Arete / hierro`,
        a.fecha_nacimiento AS `Fecha nacimiento`, a.raza_composicion AS Raza,
        madre.animal_id AS Madre, padre.animal_id AS Padre,
        (SELECT estado_codigo FROM animal_estado_historial e WHERE e.animal_id=a.animal_id AND e.anulado_en IS NULL
          AND e.fecha_fin IS NULL AND e.estado_codigo <> 'SIN_MARCAR' ORDER BY e.fecha_inicio DESC, e.estado_historial_id DESC LIMIT 1) AS `Estado actual`,
        (SELECT g.nombre FROM animal_grupo_historial h JOIN grupos g ON g.grupo_id=h.grupo_id WHERE h.animal_id=a.animal_id
          AND h.anulado_en IS NULL AND h.fecha_fin IS NULL ORDER BY h.fecha_inicio DESC, h.movimiento_id DESC LIMIT 1) AS `Grupo actual`,
        (SELECT peso_kg FROM pesajes p WHERE p.animal_id=a.animal_id AND p.anulado_en IS NULL ORDER BY p.fecha DESC, p.pesaje_id DESC LIMIT 1) AS `Último peso (kg)`
      FROM animales a
      LEFT JOIN animales madre ON madre.animal_id=a.madre_id
      LEFT JOIN animales padre ON padre.animal_id=a.padre_id
      WHERE a.animal_id=?", params = list(id))
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "No registrado")
  output$ficha_estados <- renderTable({
    dbGetQuery(conexion, "SELECT estado_codigo AS Estado, fecha_inicio AS Inicio, fecha_fin AS Fin, motivo AS Motivo
      FROM animal_estado_historial WHERE animal_id=? AND anulado_en IS NULL ORDER BY fecha_inicio DESC, estado_historial_id DESC",
      params = list(animal_ficha()))
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$ficha_grupos <- renderTable({
    dbGetQuery(conexion, "SELECT g.nombre AS Grupo, h.fecha_inicio AS Entrada, h.fecha_fin AS Salida, h.motivo AS Motivo
      FROM animal_grupo_historial h JOIN grupos g ON g.grupo_id=h.grupo_id
      WHERE h.animal_id=? AND h.anulado_en IS NULL ORDER BY h.fecha_inicio DESC, h.movimiento_id DESC",
      params = list(animal_ficha()))
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$ficha_pesajes <- renderTable({
    dbGetQuery(conexion, "SELECT fecha AS Fecha, peso_kg AS `Peso (kg)`, observaciones AS Observaciones
      FROM pesajes WHERE animal_id=? AND anulado_en IS NULL ORDER BY fecha DESC, pesaje_id DESC", params = list(animal_ficha()))
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_ocupacion_actual <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT p.nombre AS Potrero, g.nombre AS Grupo, o.fecha_inicio AS Desde
      FROM ocupacion_potrero o JOIN potreros p ON p.potrero_id=o.potrero_id JOIN grupos g ON g.grupo_id=o.grupo_id
      WHERE o.anulado_en IS NULL AND o.fecha_fin IS NULL ORDER BY p.nombre, g.nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s")
  output$tabla_potreros <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT nombre AS Potrero, area_ha AS `Área (ha)`, pastura_predominante AS Pastura, observaciones AS Observaciones FROM potreros WHERE activo=1 AND anulado_en IS NULL ORDER BY nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$ficha_genealogia <- renderTable({
    id <- animal_ficha()
    madre <- dbGetQuery(conexion, "SELECT 'Madre' AS Relación, a.animal_id AS ID, a.arete_hierro AS `Arete / hierro`, a.nombre AS Nombre, a.fecha_nacimiento AS `Fecha nacimiento` FROM animales a JOIN animales h ON h.madre_id=a.animal_id WHERE h.animal_id=? AND a.anulado_en IS NULL", params = list(id))
    crias <- dbGetQuery(conexion, "SELECT 'Cría' AS Relación, a.animal_id AS ID, a.arete_hierro AS `Arete / hierro`, a.nombre AS Nombre, a.fecha_nacimiento AS `Fecha nacimiento` FROM animales a WHERE a.madre_id=? AND a.anulado_en IS NULL ORDER BY a.fecha_nacimiento, a.animal_id", params = list(id))
    resultado <- rbind(madre, crias)
    if (!nrow(resultado)) data.frame(Relacion = "Sin datos", ID = "Sin genealogia registrada", `Arete / hierro` = NA, Nombre = NA, `Fecha nacimiento` = NA, check.names = FALSE) else resultado
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$ficha_arbol_genealogico <- renderUI({
    id <- animal_ficha()
    nodo <- function(relacion, fila, principal = FALSE) {
      if (!nrow(fila)) return(tags$div(class = "genealogia-nodo", tags$div(class = "genealogia-relacion", relacion), "Sin registrar"))
      nombre <- ifelse(is.na(fila$nombre[1]) || !nzchar(fila$nombre[1]), "", paste0(" — ", fila$nombre[1]))
      arete <- ifelse(is.na(fila$arete_hierro[1]) || !nzchar(fila$arete_hierro[1]), "Sin arete", paste0("Arete: ", fila$arete_hierro[1]))
      fecha <- ifelse(is.na(fila$fecha_nacimiento[1]) || !nzchar(fila$fecha_nacimiento[1]), "Fecha no registrada", paste0("Nac.: ", fila$fecha_nacimiento[1]))
      tags$div(class = paste("genealogia-nodo", if (principal) "principal" else ""), tags$div(class = "genealogia-relacion", relacion), tags$strong(paste0(fila$animal_id[1], nombre)), tags$div(arete), tags$div(fecha))
    }
    actual <- dbGetQuery(conexion, "SELECT animal_id, nombre, arete_hierro, fecha_nacimiento FROM animales WHERE animal_id=? AND anulado_en IS NULL", params = list(id))
    padres <- dbGetQuery(conexion, "SELECT animal_id, nombre, arete_hierro, fecha_nacimiento, CASE WHEN sexo='HEMBRA' THEN 'Madre' ELSE 'Padre' END AS relacion FROM animales WHERE animal_id IN (SELECT madre_id FROM animales WHERE animal_id=? UNION SELECT padre_id FROM animales WHERE animal_id=?) AND anulado_en IS NULL", params = list(id, id))
    hijos <- dbGetQuery(conexion, "SELECT animal_id, nombre, arete_hierro, fecha_nacimiento FROM animales WHERE madre_id=? AND anulado_en IS NULL ORDER BY fecha_nacimiento, animal_id", params = list(id))
    padres_nodos <- if (nrow(padres)) lapply(seq_len(nrow(padres)), function(i) nodo(padres$relacion[i], padres[i, , drop = FALSE])) else list(nodo("Madre / padre", data.frame()))
    hijos_nodos <- if (nrow(hijos)) lapply(seq_len(nrow(hijos)), function(i) nodo("Cría", hijos[i, , drop = FALSE])) else list(nodo("Crías", data.frame()))
    tags$div(class = "genealogia-arbol",
      tags$div(class = "genealogia-relacion", "Progenitores"), tags$div(class = "genealogia-fila", padres_nodos),
      tags$div(class = "genealogia-flecha", "↓"),
      tags$div(class = "genealogia-fila", nodo("Animal seleccionado", actual, TRUE)),
      tags$div(class = "genealogia-flecha", "↓"),
      tags$div(class = "genealogia-relacion", "Crías registradas"), tags$div(class = "genealogia-fila", hijos_nodos)
    )
  })
  output$tabla_infraestructura <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT p.nombre AS Potrero, i.tipo_codigo AS Tipo, i.nombre AS Detalle, i.cantidad AS Cantidad
      FROM potrero_infraestructura i JOIN potreros p ON p.potrero_id=i.potrero_id
      WHERE i.anulado_en IS NULL ORDER BY p.nombre, i.tipo_codigo")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_reproduccion <- renderTable({
    recargar()
    dbGetQuery(conexion, "
      SELECT e.fecha AS Fecha, e.hembra_id AS Hembra, e.tipo_codigo AS Evento, e.resultado_codigo AS Resultado,
        COALESCE(e.macho_reproductor_id, e.origen_macho) AS `Macho / origen`, e.observaciones AS Observaciones
      FROM eventos_reproductivos e WHERE e.anulado_en IS NULL
      ORDER BY e.fecha DESC, e.evento_reproductivo_id DESC")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_sanidad <- renderTable({
    recargar()
    dbGetQuery(conexion, "
      SELECT e.fecha AS Fecha, e.tipo_codigo AS Evento,
        COALESCE(e.animal_id, 'Grupo: ' || g.nombre) AS `Aplicado a`,
        COALESCE(i.nombre, ep.producto_externo) AS Producto, ep.dosis AS Dosis, ep.unidad_medida AS Unidad,
        e.diagnostico_motivo AS `Motivo / diagnóstico`, e.observaciones AS Observaciones
      FROM eventos_sanitarios e LEFT JOIN grupos g ON g.grupo_id=e.grupo_id
      LEFT JOIN evento_sanitario_productos ep ON ep.evento_sanitario_id=e.evento_sanitario_id
      LEFT JOIN items_inventario i ON i.item_id=ep.item_id
      WHERE e.anulado_en IS NULL ORDER BY e.fecha DESC, e.evento_sanitario_id DESC")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_existencias <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT nombre AS Producto, unidad_medida AS Unidad, ROUND(cantidad_actual, 2) AS Existencia,
      stock_minimo AS `Mínimo`, CASE WHEN cantidad_actual<=0 THEN 'Agotado' WHEN cantidad_actual<=stock_minimo THEN 'Stock bajo' ELSE 'Disponible' END AS Estado
      FROM v_existencias_inventario ORDER BY nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s")
  output$tabla_vencimientos <- renderTable({
    recargar()
    dbGetQuery(conexion, "
      SELECT i.nombre AS Producto, COALESCE(l.codigo_lote, 'Sin código') AS Lote, l.fecha_vencimiento AS Vence,
        ROUND(SUM(CASE m.tipo_codigo WHEN 'ENTRADA' THEN m.cantidad WHEN 'DEVOLUCION' THEN m.cantidad WHEN 'AJUSTE_POSITIVO' THEN m.cantidad ELSE -m.cantidad END),2) AS Cantidad
      FROM inventario_lotes l JOIN items_inventario i ON i.item_id=l.item_id
      LEFT JOIN movimientos_inventario m ON m.lote_id=l.lote_id AND m.anulado_en IS NULL
      WHERE l.fecha_vencimiento IS NOT NULL AND l.fecha_vencimiento <= date('now','+90 days')
      GROUP BY l.lote_id, i.item_id, i.nombre, l.codigo_lote, l.fecha_vencimiento HAVING Cantidad > 0 ORDER BY l.fecha_vencimiento")
  }, striped = TRUE, bordered = TRUE, spacing = "s")
  output$tabla_movimientos_inventario <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT m.fecha AS Fecha, i.nombre AS Producto, m.tipo_codigo AS Movimiento, m.cantidad AS Cantidad,
      i.unidad_medida AS Unidad, COALESCE(l.codigo_lote, '—') AS Lote, m.motivo AS Observaciones
      FROM movimientos_inventario m JOIN items_inventario i ON i.item_id=m.item_id LEFT JOIN inventario_lotes l ON l.lote_id=m.lote_id
      WHERE m.anulado_en IS NULL ORDER BY m.fecha DESC, m.movimiento_id DESC LIMIT 25")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_activos <- renderTable({
    recargar()
    dbGetQuery(conexion, "
      SELECT nombre AS Activo, categoria_codigo AS Categoría, marca AS Marca, modelo AS Modelo,
        placa AS Placa, serial AS Serial, ubicacion AS Ubicación, estado_codigo AS Estado
      FROM activos WHERE anulado_en IS NULL ORDER BY nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_mantenimientos <- renderTable({
    recargar()
    dbGetQuery(conexion, "
      SELECT m.fecha AS Fecha, a.nombre AS Activo, m.tipo_codigo AS Tipo, m.descripcion AS `Trabajo realizado`,
        m.costo AS Costo, m.observaciones AS Observaciones
      FROM mantenimientos_activos m JOIN activos a ON a.activo_id=m.activo_id
      WHERE m.anulado_en IS NULL ORDER BY m.fecha DESC, m.mantenimiento_id DESC LIMIT 20")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  finanzas_resumen <- reactive({
    recargar()
    dbGetQuery(conexion, "SELECT
      COALESCE(SUM(CASE WHEN tipo='INGRESO' THEN valor_total ELSE 0 END), 0) AS ingresos,
      COALESCE(SUM(CASE WHEN tipo='EGRESO' THEN valor_total ELSE 0 END), 0) AS egresos,
      COALESCE(SUM(valor_total - valor_pagado), 0) AS pendiente
      FROM movimientos_financieros WHERE anulado_en IS NULL")
  })
  output$fin_ingresos <- renderText({ paste0("Ingresos acumulados: $ ", format(round(finanzas_resumen()$ingresos[1], 2), big.mark = ".", decimal.mark = ",", nsmall = 2)) })
  output$fin_egresos <- renderText({ paste0("Egresos acumulados: $ ", format(round(finanzas_resumen()$egresos[1], 2), big.mark = ".", decimal.mark = ",", nsmall = 2)) })
  output$fin_balance <- renderText({
    saldo <- finanzas_resumen()$ingresos[1] - finanzas_resumen()$egresos[1]
    paste0("Balance: $ ", format(round(saldo, 2), big.mark = ".", decimal.mark = ",", nsmall = 2))
  })
  output$fin_pendiente <- renderText({ paste0("Saldo pendiente: $ ", format(round(finanzas_resumen()$pendiente[1], 2), big.mark = ".", decimal.mark = ",", nsmall = 2)) })
  output$tabla_finanzas <- renderTable({
    recargar()
    datos <- dbGetQuery(conexion, "
      SELECT m.fecha AS Fecha, m.tipo AS Tipo, c.nombre AS Categoría, t.nombre AS Tercero,
        m.concepto AS Concepto, m.valor_total AS Total, m.valor_pagado AS Pagado,
        m.estado_pago AS `Estado pago`, m.origen_tipo AS Origen
      FROM movimientos_financieros m JOIN categorias_financieras c ON c.categoria_financiera_id=m.categoria_financiera_id
      LEFT JOIN terceros t ON t.tercero_id=m.tercero_id
      WHERE m.anulado_en IS NULL ORDER BY m.fecha DESC, m.movimiento_financiero_id DESC LIMIT 25")
    datos$Total <- formato_pesos(datos$Total); datos$Pagado <- formato_pesos(datos$Pagado); datos
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  detalle_venta_seleccionada <- reactive({
    ids <- input$venta_animales
    if (is.null(ids) || length(ids) == 0L) return(data.frame())
    marcadores <- paste(rep("?", length(ids)), collapse = ",")
    datos <- dbGetQuery(conexion, paste0("
      SELECT a.animal_id AS Animal, a.nombre AS Nombre, p.peso_kg AS `Peso (kg)`
      FROM animales a JOIN pesajes p ON p.pesaje_id=(SELECT p2.pesaje_id FROM pesajes p2
        WHERE p2.animal_id=a.animal_id AND p2.anulado_en IS NULL ORDER BY p2.fecha DESC, p2.pesaje_id DESC LIMIT 1)
      WHERE a.animal_id IN (", marcadores, ") ORDER BY a.animal_id"), params = as.list(ids))
    precio <- if (is.na(input$venta_precio_kg)) 0 else input$venta_precio_kg
    datos$`Precio/kg` <- precio
    datos$Valor <- round(datos$`Peso (kg)` * precio, 2)
    datos
  })
  output$resumen_venta <- renderTable({
    detalle <- detalle_venta_seleccionada()
    if (nrow(detalle) == 0L) return(data.frame(Mensaje = "Seleccione animales para ver el resumen."))
    rbind(detalle, data.frame(Animal = "TOTAL", Nombre = "", `Peso (kg)` = sum(detalle$`Peso (kg)`),
      `Precio/kg` = NA_real_, Valor = sum(detalle$Valor), check.names = FALSE))
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_compradores <- renderTable({
    recargar()
    dbGetQuery(conexion, "SELECT nombre AS Comprador, documento AS Documento, telefono AS Teléfono, correo AS Correo
      FROM terceros WHERE activo=1 AND tipo_codigo='COMPRADOR' ORDER BY nombre")
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_ventas <- renderTable({
    recargar()
    datos <- dbGetQuery(conexion, "
      SELECT v.venta_id AS Venta, v.fecha AS Fecha, t.nombre AS Comprador,
        ROUND(x.kg_total, 2) AS `Kg totales`, ROUND(x.precio_promedio_kg, 2) AS `Precio promedio/kg`,
        ROUND(x.valor_total, 2) AS Total, f.estado_pago AS Pago
      FROM v_ventas_ganado_totales x JOIN ventas_ganado v ON v.venta_id=x.venta_id
      JOIN terceros t ON t.tercero_id=v.comprador_id LEFT JOIN movimientos_financieros f ON f.movimiento_financiero_id=v.movimiento_financiero_id
      ORDER BY v.fecha DESC, v.venta_id DESC LIMIT 20")
    datos$`Precio promedio/kg` <- formato_pesos(datos$`Precio promedio/kg`); datos$Total <- formato_pesos(datos$Total); datos
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_compras_ganado <- renderTable({
    recargar()
    datos <- dbGetQuery(conexion, "SELECT m.fecha AS Fecha, t.nombre AS Vendedor, m.concepto AS Concepto, m.valor_total AS Total, m.valor_pagado AS Pagado, m.estado_pago AS `Estado pago`, m.observaciones AS Observaciones FROM movimientos_financieros m LEFT JOIN terceros t ON t.tercero_id=m.tercero_id WHERE m.anulado_en IS NULL AND m.origen_tipo='COMPRA_GANADO' ORDER BY m.fecha DESC, m.movimiento_financiero_id DESC LIMIT 25")
    datos$Total <- formato_pesos(datos$Total); datos$Pagado <- formato_pesos(datos$Pagado); datos
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  observe({
    recargar()
    categorias <- dbGetQuery(conexion, "SELECT categoria_financiera_id, nombre, tipo FROM categorias_financieras ORDER BY nombre, tipo")
    etiquetas <- ifelse(categorias$nombre == "Otros", paste0("Otros (", categorias$tipo, ")"), categorias$nombre)
    updateSelectInput(session, "hist_categoria", choices = c("Todas" = "TODAS", setNames(as.character(categorias$categoria_financiera_id), etiquetas)))
  })
  output$tabla_movimientos_historicos <- renderTable({
    recargar()
    tipo <- if (is.null(input$hist_tipo) || input$hist_tipo == "TODOS") NULL else input$hist_tipo
    categoria <- if (is.null(input$hist_categoria) || input$hist_categoria == "TODAS") NULL else trimws(as.character(input$hist_categoria))
    concepto <- trimws(if (is.null(input$hist_concepto)) "" else input$hist_concepto)
    condiciones <- c(if (!is.null(tipo)) "AND m.tipo=?", if (!is.null(categoria)) "AND m.categoria_financiera_id=CAST(? AS BIGINT)", if (nzchar(concepto)) "AND LOWER(m.concepto) LIKE LOWER(?)")
    params <- c(if (!is.null(tipo)) list(tipo), if (!is.null(categoria)) list(categoria), if (nzchar(concepto)) list(paste0("%", concepto, "%")))
    sql <- paste0("SELECT m.fecha AS Fecha, m.tipo AS Tipo, c.nombre AS Categoría, t.nombre AS Tercero, m.concepto AS Concepto, m.valor_total AS Total, m.valor_pagado AS Pagado, m.estado_pago AS `Estado pago`, m.origen_tipo AS Origen FROM movimientos_financieros m JOIN categorias_financieras c ON c.categoria_financiera_id=m.categoria_financiera_id LEFT JOIN terceros t ON t.tercero_id=m.tercero_id WHERE m.anulado_en IS NULL ", if (length(condiciones)) paste(condiciones, collapse = " ") else "", " ORDER BY m.fecha DESC, m.movimiento_financiero_id DESC")
    sql <- sub("SELECT m.fecha", "SELECT m.movimiento_financiero_id AS __id_movimiento, m.fecha", sql, fixed = TRUE)
    datos <- dbGetQuery(conexion, sql, params = params)
    session$userData$historial_movimientos_ids <- datos[["__id_movimiento"]]
    datos[["__id_movimiento"]] <- NULL
    if (nrow(datos)) { datos$Total <- formato_pesos(datos$Total); datos$Pagado <- formato_pesos(datos$Pagado) }
    datos
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  output$tabla_ventas_leche <- renderTable({
    recargar()
    datos <- dbGetQuery(conexion, "SELECT CAST(p.produccion_leche_id AS INTEGER) AS ID, p.fecha AS Fecha, t.nombre AS Comprador, p.litros AS Litros, p.precio_litro AS `Precio/litro`, p.observaciones AS Observaciones FROM produccion_leche p LEFT JOIN terceros t ON t.tercero_id=p.comprador_id WHERE p.anulado_en IS NULL ORDER BY p.fecha DESC, p.produccion_leche_id DESC LIMIT 25")
    datos$`Precio/litro` <- formato_pesos(datos$`Precio/litro`); datos
  }, striped = TRUE, bordered = TRUE, spacing = "s", na = "—")
  observeEvent(input$editar_venta_leche_id, {
    id <- as.integer(input$editar_venta_leche_id)
    venta <- dbGetQuery(conexion, "SELECT p.*, m.movimiento_financiero_id FROM produccion_leche p LEFT JOIN movimientos_financieros m ON m.movimiento_financiero_id=p.movimiento_financiero_id WHERE p.produccion_leche_id=? AND p.anulado_en IS NULL", params = list(id))
    if (!nrow(venta)) return()
    session$userData$venta_leche_edicion_id <- id
    showModal(modalDialog(title = "Editar venta de leche",
      dateInput("editar_leche_fecha", "Fecha", value = as.Date(venta$fecha[1]), format = "yyyy-mm-dd", startview = "year", language = "es"),
      numericInput("editar_leche_litros", "Litros", value = venta$litros[1], min = 0.01, step = 0.1),
      numericInput("editar_leche_precio", "Precio por litro", value = venta$precio_litro[1], min = 0, step = 10),
      selectInput("editar_leche_comprador", "Comprador", choices = c("Sin comprador" = ""), selected = ifelse(is.na(venta$comprador_id[1]), "", venta$comprador_id[1])),
      textAreaInput("editar_leche_obs", "Observaciones", value = ifelse(is.na(venta$observaciones[1]), "", venta$observaciones[1]), rows = 3),
      footer = tagList(modalButton("Cancelar"), actionButton("guardar_edicion_venta_leche", "Guardar cambios", class = "btn-primary")), easyClose = FALSE))
    compradores <- dbGetQuery(conexion, "SELECT tercero_id, nombre FROM terceros WHERE activo=1 ORDER BY nombre")
    updateSelectInput(session, "editar_leche_comprador", choices = c("Sin comprador" = "", setNames(compradores$tercero_id, compradores$nombre)), selected = ifelse(is.na(venta$comprador_id[1]), "", venta$comprador_id[1]))
  })
  observeEvent(input$guardar_edicion_venta_leche, {
    id <- session$userData$venta_leche_edicion_id
    if (is.null(id) || is.na(input$editar_leche_litros) || input$editar_leche_litros <= 0 || is.na(input$editar_leche_precio) || input$editar_leche_precio < 0) { showNotification("Revisa litros y precio.", type = "error"); return() }
    total <- input$editar_leche_litros * input$editar_leche_precio
    tryCatch({
      dbWithTransaction(conexion, {
        dbExecute(conexion, "UPDATE produccion_leche SET fecha=?, litros=?, precio_litro=?, comprador_id=?, observaciones=? WHERE produccion_leche_id=?", params = list(as.character(input$editar_leche_fecha), input$editar_leche_litros, input$editar_leche_precio, if (nzchar(input$editar_leche_comprador)) as.integer(input$editar_leche_comprador) else NA_integer_, if (nzchar(trimws(input$editar_leche_obs))) trimws(input$editar_leche_obs) else NA_character_, id))
        dbExecute(conexion, "UPDATE movimientos_financieros SET fecha=?, tercero_id=?, valor_total=?, valor_pagado=?, fecha_pago=?, observaciones=? WHERE origen_tipo='PRODUCCION_LECHE' AND origen_id=? AND anulado_en IS NULL", params = list(as.character(input$editar_leche_fecha), if (nzchar(input$editar_leche_comprador)) as.integer(input$editar_leche_comprador) else NA_integer_, total, total, as.character(input$editar_leche_fecha), if (nzchar(trimws(input$editar_leche_obs))) trimws(input$editar_leche_obs) else NA_character_, as.character(id)))
      })
      removeModal(); recargar(recargar() + 1L); showNotification("Venta de leche actualizada.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo actualizar la venta de leche:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$editar_compra_reciente, {
    mov <- dbGetQuery(conexion, "SELECT movimiento_financiero_id, fecha, concepto, valor_total, valor_pagado, estado_pago, observaciones FROM movimientos_financieros WHERE concepto=? AND origen_tipo='COMPRA_GANADO' AND anulado_en IS NULL ORDER BY fecha DESC, movimiento_financiero_id DESC LIMIT 1", params = list(trimws(input$editar_compra_reciente)))
    if (!nrow(mov)) return()
    session$userData$compra_edicion_id <- mov$movimiento_financiero_id[1]
    showModal(modalDialog(title = "Editar compra de ganado",
      dateInput("editar_compra_fecha", "Fecha", value = as.Date(mov$fecha[1]), format = "yyyy-mm-dd", startview = "year", language = "es"),
      numericInput("editar_compra_total", "Valor total", value = mov$valor_total[1], min = 0.01, step = 1000),
      selectInput("editar_compra_pago", "Estado del pago", c("Pagado" = "PAGADO", "Pendiente" = "PENDIENTE", "Parcial" = "PARCIAL"), selected = mov$estado_pago[1]),
      numericInput("editar_compra_pagado", "Valor pagado", value = mov$valor_pagado[1], min = 0, step = 1000),
      textAreaInput("editar_compra_obs", "Observaciones", value = ifelse(is.na(mov$observaciones[1]), "", mov$observaciones[1]), rows = 3),
      footer = tagList(modalButton("Cancelar"), actionButton("guardar_edicion_compra", "Guardar cambios", class = "btn-primary")), easyClose = FALSE))
  })
  observeEvent(input$guardar_edicion_compra, {
    id <- session$userData$compra_edicion_id; total <- input$editar_compra_total; pagado <- input$editar_compra_pagado
    if (input$editar_compra_pago == "PAGADO") pagado <- total
    if (input$editar_compra_pago == "PENDIENTE") pagado <- 0
    if (is.na(total) || total <= 0 || is.na(pagado) || pagado < 0 || pagado > total || (input$editar_compra_pago == "PARCIAL" && (pagado <= 0 || pagado >= total))) { showNotification("Revisa el valor total y el pago.", type = "error"); return() }
    tryCatch({
      dbExecute(conexion, "UPDATE movimientos_financieros SET fecha=?, valor_total=?, estado_pago=?, valor_pagado=?, fecha_pago=?, observaciones=? WHERE movimiento_financiero_id=? AND origen_tipo='COMPRA_GANADO' AND anulado_en IS NULL", params = list(as.character(input$editar_compra_fecha), total, input$editar_compra_pago, pagado, if (input$editar_compra_pago == "PENDIENTE") NA_character_ else as.character(input$editar_compra_fecha), if (nzchar(trimws(input$editar_compra_obs))) trimws(input$editar_compra_obs) else NA_character_, id))
      removeModal(); recargar(recargar() + 1L); showNotification("Compra actualizada.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo actualizar la compra:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$arete_hierro, {
    arete_busqueda <- trimws(input$arete_hierro %||% "")
    if (!nzchar(arete_busqueda)) return()
    existente <- dbGetQuery(conexion, "SELECT a.animal_id, a.madre_id
      FROM animales a WHERE a.arete_hierro=? AND a.anulado_en IS NULL LIMIT 1", params = list(arete_busqueda))
    if (nrow(existente) && !is.na(existente$madre_id[1]) && nzchar(existente$madre_id[1])) {
      updateSelectInput(session, "madre_id", selected = existente$madre_id[1])
      showNotification(paste("Animal existente detectado:", existente$animal_id[1],
        "Madre sugerida:", existente$madre_id[1]), type = "message", duration = 5)
    }
  }, ignoreInit = TRUE)
  avisar_madre_existente <- function(valor) {
    arete <- trimws(valor %||% "")
    if (!nzchar(arete)) return()
    existente <- dbGetQuery(conexion, "SELECT animal_id, nombre, anulado_en FROM animales WHERE LOWER(TRIM(arete_hierro))=LOWER(TRIM(?)) LIMIT 1", params = list(arete))
    if (nrow(existente) && is.na(existente$anulado_en[1])) {
      etiqueta <- if (is.na(existente$nombre[1]) || !nzchar(existente$nombre[1])) "" else paste0(" — ", existente$nombre[1])
      showNotification(paste("Arete ya registrado:", existente$animal_id[1], etiqueta, "Se reutilizará esa ficha como madre."), type = "message", duration = 7)
    }
  }
  observeEvent(input$animal_madre_arete, {
    avisar_madre_existente(input$animal_madre_arete)
    if (nzchar(trimws(input$animal_madre_arete %||% ""))) updateSelectInput(session, "madre_id", selected = "")
  }, ignoreInit = TRUE)
  observeEvent(input$cria_madre_arete, { avisar_madre_existente(input$cria_madre_arete) }, ignoreInit = TRUE)

  observeEvent(input$guardar_animal, {
    vacio_a_na <- function(x) if (is.null(x) || !nzchar(trimws(x))) NA_character_ else trimws(x)
    fecha_entrada <- input$fecha_nacimiento
    fecha_nacimiento <- if (is.null(fecha_entrada) || length(fecha_entrada) == 0L || all(is.na(fecha_entrada)) || !nzchar(trimws(as.character(fecha_entrada[1])))) NA_character_ else as.character(fecha_entrada[1])
    madre_arete <- vacio_a_na(input$animal_madre_arete)
    madre_id_guardar <- vacio_a_na(input$madre_id)
    # Si se escribió un arete provisional, ese dato tiene prioridad sobre el selector.
    if (!is.na(madre_arete)) {
      madre_id_guardar <- NA_character_
      madre_existente <- dbGetQuery(conexion, "SELECT animal_id, anulado_en FROM animales WHERE LOWER(TRIM(arete_hierro))=LOWER(TRIM(?)) AND anulado_en IS NULL LIMIT 1", params = list(madre_arete))
      if (nrow(madre_existente)) {
        madre_id_guardar <- madre_existente$animal_id[1]
      } else {
        madre_id_guardar <- siguiente_animal_id(conexion, "HEMBRA")
        dbExecute(conexion, "INSERT INTO animales(animal_id, sexo, arete_hierro, fecha_registro, observaciones) VALUES (?, 'HEMBRA', ?, date('now'), ?)", params = list(madre_id_guardar, madre_arete, "Ficha provisional creada desde Registrar animal"))
        dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo) VALUES (?, 'ACTIVO', date('now'), 'Madre creada desde registro de animal')", params = list(madre_id_guardar))
        showNotification(paste("Se creó una ficha provisional para la madre", madre_id_guardar), type = "message", duration = 8)
      }
    }
    arete <- vacio_a_na(input$arete_hierro)
    nombre_normalizado <- vacio_a_na(input$nombre)
    padre_guardar <- vacio_a_na(input$padre_id)
    raza_guardar <- vacio_a_na(input$raza)
    fecha_param <- if (is.na(fecha_nacimiento)) NA_character_ else fecha_nacimiento
    if (!is.na(arete)) {
      existente <- dbGetQuery(conexion, "SELECT animal_id, nombre FROM animales WHERE LOWER(TRIM(arete_hierro))=LOWER(TRIM(?)) AND anulado_en IS NULL LIMIT 1", params = list(arete))
    } else {
      existente <- dbGetQuery(conexion, "SELECT animal_id, nombre FROM animales WHERE anulado_en IS NULL
        AND sexo=? AND COALESCE(NULLIF(LOWER(TRIM(nombre)),''),'')=COALESCE(NULLIF(LOWER(TRIM(?)),''),'')
        AND COALESCE(fecha_nacimiento,'')=COALESCE(?, '') AND COALESCE(madre_id,'')=COALESCE(?, '')
        AND COALESCE(padre_id,'')=COALESCE(?, '') LIMIT 1",
        params = list(input$sexo, nombre_normalizado, fecha_param, madre_id_guardar, padre_guardar))
    }
    if (nrow(existente)) {
        session$userData$animal_duplicado_id <- existente$animal_id[1]
        showModal(modalDialog(
          title = "ANIMAL REGISTRADO ANTERIORMENTE",
          p(paste("Ya existe un animal con estos datos en", existente$animal_id[1], ifelse(is.na(existente$nombre[1]) || existente$nombre[1] == '', '', paste0(" — ", existente$nombre[1])))),
          footer = tagList(modalButton("Aceptar"), actionButton("buscar_numero_registrado", "Buscar número registrado", class = "btn-primary")),
          easyClose = FALSE
        ))
        return()
    }
    animal_id <- siguiente_animal_id(conexion, input$sexo)
    if (!is.na(madre_id_guardar) && identical(madre_id_guardar, animal_id)) {
      showNotification("La madre seleccionada coincide con el animal que estás registrando. Verifica el ID o el arete de la madre.", type = "error", duration = 10)
      return()
    }
    if (!is.na(madre_id_guardar)) {
      sexo_madre <- dbGetQuery(conexion, "SELECT sexo FROM animales WHERE animal_id=? AND anulado_en IS NULL", params = list(madre_id_guardar))
      if (!nrow(sexo_madre) || sexo_madre$sexo[1] != "HEMBRA") {
        showNotification("La madre seleccionada no corresponde a una hembra registrada.", type = "error", duration = 10)
        return()
      }
    }

    tryCatch({
      dbWithTransaction(conexion, {
        dbExecute(conexion, "
          INSERT INTO animales(animal_id, sexo, nombre, arete_hierro, fecha_nacimiento,
                               madre_id, padre_id, raza_composicion, fecha_registro, observaciones)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, date('now','localtime'), ?)",
            params = list(animal_id, input$sexo, nombre_normalizado, arete,
                        fecha_nacimiento,
                        madre_id_guardar, padre_guardar, raza_guardar,
                        vacio_a_na(input$observaciones)))
        dbExecute(conexion, "
          INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo)
          VALUES (?, 'ACTIVO', date('now'), 'Registro inicial')", params = list(animal_id))
        if (!is.null(input$animal_grupo_inicial) && nzchar(input$animal_grupo_inicial)) {
          dbExecute(conexion, "INSERT INTO animal_grupo_historial(animal_id, grupo_id, fecha_inicio, motivo) VALUES (?, ?, date('now'), 'Grupo inicial al registrar el animal')",
            params = list(animal_id, as.integer(input$animal_grupo_inicial)))
        }
      })
      showNotification(paste("Animal", animal_id, "guardado correctamente."), type = "message")
      updateTextInput(session, "nombre", value = "")
      updateTextInput(session, "arete_hierro", value = "")
      updateDateInput(session, "fecha_nacimiento", value = NA)
      updateTextInput(session, "animal_madre_arete", value = "")
      updateTextInput(session, "raza", value = "")
      updateSelectInput(session, "animal_grupo_inicial", selected = "")
      updateTextAreaInput(session, "observaciones", value = "")
      recargar(recargar() + 1L)
    }, error = function(e) {
      showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL)
    })
  })

  observeEvent(input$guardar_grupo, {
    nombre <- trimws(input$grupo_nombre)
    if (!nzchar(nombre)) {
      showNotification("Escribe un nombre para el grupo.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO grupos(nombre, descripcion) VALUES (?, ?)",
                params = list(nombre, if (nzchar(trimws(input$grupo_descripcion))) trimws(input$grupo_descripcion) else NA_character_))
      updateTextInput(session, "grupo_nombre", value = "")
      updateTextAreaInput(session, "grupo_descripcion", value = "")
      recargar(recargar() + 1L)
      showNotification("Grupo creado.", type = "message")
    }, error = function(e) showNotification(conditionMessage(e), type = "error"))
  })

  observeEvent(input$guardar_movimiento, {
    if (is.null(input$mov_animal) || !nzchar(input$mov_animal) || is.null(input$mov_grupo) || !nzchar(input$mov_grupo)) {
      showNotification("Primero registra un animal y crea o elige un grupo.", type = "error")
      return()
    }
    fecha <- as.character(input$mov_fecha)
    tryCatch({
      dbWithTransaction(conexion, {
        dbExecute(conexion, "
          UPDATE animal_grupo_historial SET fecha_fin = ?
          WHERE animal_id = ? AND fecha_fin IS NULL AND anulado_en IS NULL",
          params = list(fecha, input$mov_animal))
        dbExecute(conexion, "
          INSERT INTO animal_grupo_historial(animal_id, grupo_id, fecha_inicio, motivo)
          VALUES (?, ?, ?, ?)", params = list(input$mov_animal, as.integer(input$mov_grupo), fecha,
                                                if (nzchar(trimws(input$mov_motivo))) trimws(input$mov_motivo) else NA_character_))
      })
      updateTextInput(session, "mov_motivo", value = "")
      recargar(recargar() + 1L)
      showNotification("Movimiento de grupo registrado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo registrar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_peso, {
    if (is.null(input$peso_animal) || !nzchar(input$peso_animal) || is.na(input$peso_kg) || input$peso_kg <= 0) {
      showNotification("Elige un animal y escribe un peso mayor que cero.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO pesajes(animal_id, fecha, peso_kg, observaciones) VALUES (?, ?, ?, ?)",
                params = list(input$peso_animal, as.character(input$peso_fecha), input$peso_kg,
                              if (nzchar(trimws(input$peso_observaciones))) trimws(input$peso_observaciones) else NA_character_))
      updateNumericInput(session, "peso_kg", value = NA)
      updateTextAreaInput(session, "peso_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Pesaje guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_estado, {
    if (is.null(input$estado_animal) || !nzchar(input$estado_animal)) {
      showNotification("Selecciona el animal al que le vas a cambiar el estado.", type = "error")
      return()
    }
    fecha <- as.character(input$estado_fecha)
    tryCatch({
      dbWithTransaction(conexion, {
        if (input$estado_nuevo == "SIN_MARCAR") dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=? WHERE animal_id=? AND fecha_fin IS NULL AND anulado_en IS NULL AND estado_codigo='SIN_MARCAR'", params = list(fecha, input$estado_animal))
        if (input$estado_nuevo != "SIN_MARCAR") dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=?
          WHERE animal_id=? AND fecha_fin IS NULL AND anulado_en IS NULL AND estado_codigo <> 'SIN_MARCAR'", params = list(fecha, input$estado_animal))
        dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo, observaciones)
          VALUES (?, ?, ?, ?, ?)", params = list(input$estado_animal, input$estado_nuevo, fecha,
          if (nzchar(trimws(input$estado_motivo))) trimws(input$estado_motivo) else NA_character_,
          if (nzchar(trimws(input$estado_observaciones))) trimws(input$estado_observaciones) else NA_character_))
      })
      updateTextInput(session, "estado_motivo", value = "")
      updateTextAreaInput(session, "estado_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Estado actualizado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo actualizar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_potrero, {
    nombre <- trimws(input$potrero_nombre)
    if (!nzchar(nombre)) {
      showNotification("Escribe el nombre del potrero.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO potreros(nombre, area_ha, pastura_predominante, observaciones) VALUES (?, ?, ?, ?)",
        params = list(nombre, if (is.na(input$potrero_area)) NA_real_ else input$potrero_area,
          if (nzchar(trimws(input$potrero_pastura))) trimws(input$potrero_pastura) else NA_character_,
          if (nzchar(trimws(input$potrero_observaciones))) trimws(input$potrero_observaciones) else NA_character_))
      updateTextInput(session, "potrero_nombre", value = "")
      updateNumericInput(session, "potrero_area", value = NA)
      updateTextInput(session, "potrero_pastura", value = "")
      updateTextAreaInput(session, "potrero_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Potrero creado.", type = "message")
    }, error = function(e) showNotification(conditionMessage(e), type = "error"))
  })

  observeEvent(input$guardar_infra, {
    if (is.null(input$infra_potrero) || !nzchar(input$infra_potrero) || is.na(input$infra_cantidad) || input$infra_cantidad <= 0) {
      showNotification("Elige un potrero y una cantidad válida.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO potrero_infraestructura(potrero_id, tipo_codigo, nombre, cantidad) VALUES (?, ?, ?, ?)",
        params = list(as.integer(input$infra_potrero), input$infra_tipo,
          if (nzchar(trimws(input$infra_nombre))) trimws(input$infra_nombre) else NA_character_, input$infra_cantidad))
      updateTextInput(session, "infra_nombre", value = "")
      updateNumericInput(session, "infra_cantidad", value = 1)
      recargar(recargar() + 1L)
      showNotification("Infraestructura registrada.", type = "message")
    }, error = function(e) showNotification(conditionMessage(e), type = "error"))
  })

  observeEvent(input$guardar_ocupacion, {
    if (is.null(input$ocup_grupo) || !nzchar(input$ocup_grupo) || is.null(input$ocup_potrero) || !nzchar(input$ocup_potrero)) {
      showNotification("Crea o selecciona un grupo y un potrero.", type = "error")
      return()
    }
    fecha <- as.character(input$ocup_fecha)
    tryCatch({
      dbWithTransaction(conexion, {
        dbExecute(conexion, "UPDATE ocupacion_potrero SET fecha_fin=? WHERE grupo_id=? AND fecha_fin IS NULL AND anulado_en IS NULL",
                  params = list(fecha, as.integer(input$ocup_grupo)))
        dbExecute(conexion, "INSERT INTO ocupacion_potrero(grupo_id, potrero_id, fecha_inicio, observaciones) VALUES (?, ?, ?, ?)",
          params = list(as.integer(input$ocup_grupo), as.integer(input$ocup_potrero), fecha,
            if (nzchar(trimws(input$ocup_observaciones))) trimws(input$ocup_observaciones) else NA_character_))
      })
      updateTextAreaInput(session, "ocup_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Ocupación registrada.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo registrar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_reproduccion, {
    if (is.null(input$repro_hembra) || !nzchar(input$repro_hembra)) {
      showNotification("Primero registra y selecciona una hembra.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "
        INSERT INTO eventos_reproductivos(hembra_id, fecha, tipo_codigo, resultado_codigo,
          macho_reproductor_id, origen_macho, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?)", params = list(
          input$repro_hembra, as.character(input$repro_fecha), input$repro_tipo,
          if (nzchar(input$repro_resultado)) input$repro_resultado else NA_character_,
          if (nzchar(input$repro_macho)) input$repro_macho else NA_character_,
          if (nzchar(trimws(input$repro_origen_macho))) trimws(input$repro_origen_macho) else NA_character_,
          if (nzchar(trimws(input$repro_observaciones))) trimws(input$repro_observaciones) else NA_character_))
      updateSelectInput(session, "repro_resultado", selected = "")
      updateSelectInput(session, "repro_macho", selected = "")
      updateTextInput(session, "repro_origen_macho", value = "")
      updateTextAreaInput(session, "repro_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Evento reproductivo guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_cria, {
    vacio_a_na <- function(x) if (is.null(x) || !nzchar(trimws(x))) NA_character_ else trimws(x)
    madre_seleccionada <- vacio_a_na(input$cria_madre)
    madre_arete <- vacio_a_na(input$cria_madre_arete)
    if (is.na(madre_seleccionada) && is.na(madre_arete)) {
      showNotification("Selecciona una madre o escribe el arete de una madre aún no registrada.", type = "error")
      return()
    }
    madre_id <- madre_seleccionada
    if (is.na(madre_id) && !is.na(madre_arete)) {
      encontrada <- dbGetQuery(conexion, "SELECT animal_id FROM animales WHERE arete_hierro=? AND anulado_en IS NULL LIMIT 1", params = list(madre_arete))
      if (nrow(encontrada)) {
        madre_id <- encontrada$animal_id[1]
      } else {
        madre_id <- siguiente_animal_id(conexion, "HEMBRA")
        dbExecute(conexion, "INSERT INTO animales(animal_id, sexo, arete_hierro, fecha_registro, observaciones) VALUES (?, 'HEMBRA', ?, date('now'), ?)",
          params = list(madre_id, madre_arete, "Ficha provisional creada al registrar un parto histórico"))
        dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo) VALUES (?, 'ACTIVO', date('now'), 'Madre creada desde parto histórico')", params = list(madre_id))
        showNotification(paste("Se creó una ficha provisional para la madre", madre_id, "con arete", madre_arete), type = "message", duration = 8)
      }
    }
    ultimo_parto <- dbGetQuery(conexion, "SELECT MAX(fecha) AS fecha FROM eventos_reproductivos WHERE hembra_id=? AND tipo_codigo='PARTO' AND anulado_en IS NULL", params = list(madre_id))$fecha[1]
    if (!is.na(ultimo_parto) && nzchar(ultimo_parto)) {
      fecha_cria <- as.Date(input$cria_fecha)
      fecha_minima <- seq.Date(as.Date(ultimo_parto), by = "month", length.out = 9)[9]
      if (fecha_cria < fecha_minima) {
        showNotification(paste("Advertencia: el último parto de esta vaca fue el", ultimo_parto, "y la nueva fecha está a menos de 8 meses."), type = "warning", duration = 10)
      }
    }
    fecha <- as.character(input$cria_fecha)
    cria_arete <- vacio_a_na(input$cria_arete)
    existente_cria <- if (!is.na(cria_arete)) dbGetQuery(conexion, "SELECT animal_id FROM animales WHERE arete_hierro=? AND anulado_en IS NULL LIMIT 1", params = list(cria_arete)) else data.frame()
    cria_id <- if (nrow(existente_cria)) existente_cria$animal_id[1] else siguiente_animal_id(conexion, input$cria_sexo)
    if (identical(madre_id, cria_id)) {
      showNotification("La madre y la cría no pueden ser el mismo animal. Verifica el arete o el ID.", type = "error", duration = 10)
      return()
    }
    tryCatch({
      dbWithTransaction(conexion, {
        if (nrow(existente_cria)) {
          dbExecute(conexion, "UPDATE animales SET madre_id=?, padre_id=COALESCE(?, padre_id), fecha_nacimiento=COALESCE(fecha_nacimiento, ?), nombre=COALESCE(NULLIF(?, ''), nombre), raza_composicion=COALESCE(NULLIF(?, ''), raza_composicion) WHERE animal_id=?", params = list(madre_id, if (nzchar(input$cria_padre)) input$cria_padre else NA_character_, fecha, vacio_a_na(input$cria_nombre), vacio_a_na(input$cria_raza), cria_id))
        } else {
        dbExecute(conexion, "
          INSERT INTO animales(animal_id, sexo, nombre, arete_hierro, fecha_nacimiento, madre_id, padre_id,
            raza_composicion, fecha_registro, observaciones)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, date('now'), ?)",
          params = list(cria_id, input$cria_sexo, vacio_a_na(input$cria_nombre), cria_arete, fecha,
            madre_id, if (nzchar(input$cria_padre)) input$cria_padre else NA_character_,
            vacio_a_na(input$cria_raza), vacio_a_na(input$cria_observaciones)))
        dbExecute(conexion, "INSERT INTO animal_procedencias(animal_id, tipo_codigo, fecha, observaciones)
          VALUES (?, 'NACIMIENTO_FINCA', ?, 'Registrado desde el evento de parto')", params = list(cria_id, fecha))
        dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo)
          VALUES (?, 'ACTIVO', ?, 'Nacimiento en finca')", params = list(cria_id, fecha))
        }
        if (identical(input$cria_sin_marcar, "SI")) {
          dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=? WHERE animal_id=? AND estado_codigo='SIN_MARCAR' AND fecha_fin IS NULL AND anulado_en IS NULL", params = list(fecha, cria_id))
          dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo) VALUES (?, 'SIN_MARCAR', ?, 'Cría registrada sin hierro')", params = list(cria_id, fecha))
        }
        if (!is.null(input$cria_grupo) && nzchar(input$cria_grupo)) {
          dbExecute(conexion, "INSERT INTO animal_grupo_historial(animal_id, grupo_id, fecha_inicio, motivo) VALUES (?, ?, ?, 'Grupo asignado al registrar la cría')", params = list(cria_id, as.integer(input$cria_grupo), fecha))
        }
        if (identical(input$pasar_madre_pequenos, "SI")) {
          grupo_pequenos <- dbGetQuery(conexion, "SELECT grupo_id FROM grupos WHERE activo=1 AND UPPER(nombre)='PEQUEÑOS' LIMIT 1")
          if (!nrow(grupo_pequenos)) stop("No existe el grupo PEQUEÑOS. Créalo antes de registrar el parto.")
          dbExecute(conexion, "UPDATE animal_grupo_historial SET fecha_fin=CASE WHEN fecha_inicio <= ? THEN ? ELSE fecha_inicio END WHERE animal_id=? AND fecha_fin IS NULL AND anulado_en IS NULL", params = list(fecha, fecha, madre_id))
          dbExecute(conexion, "INSERT INTO animal_grupo_historial(animal_id, grupo_id, fecha_inicio, motivo) VALUES (?, ?, ?, 'Madre trasladada automáticamente tras registrar parto')", params = list(madre_id, grupo_pequenos$grupo_id[1], fecha))
        }
        dbExecute(conexion, "
          INSERT INTO eventos_reproductivos(hembra_id, fecha, tipo_codigo, macho_reproductor_id, origen_macho, observaciones)
          VALUES (?, ?, 'PARTO', ?, ?, ?)", params = list(madre_id, fecha,
            if (nzchar(input$cria_padre)) input$cria_padre else NA_character_, vacio_a_na(input$cria_origen_padre),
            paste("Nacimiento de", cria_id, if (nzchar(trimws(input$cria_observaciones))) paste0(". ", trimws(input$cria_observaciones)) else "")))
      })
      updateTextInput(session, "cria_nombre", value = "")
      updateTextInput(session, "cria_arete", value = "")
      updateTextInput(session, "cria_madre_arete", value = "")
      updateSelectInput(session, "cria_sin_marcar", selected = "NO")
      updateRadioButtons(session, "pasar_madre_pequenos", selected = "NO")
      updateSelectInput(session, "cria_padre", selected = "")
      updateTextInput(session, "cria_origen_padre", value = "")
      updateTextInput(session, "cria_raza", value = "")
      updateTextAreaInput(session, "cria_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification(paste(if (nrow(existente_cria)) "Animal existente vinculado al parto. ID:" else "Nacimiento registrado. ID de la cría:", cria_id), type = "message", duration = NULL)
    }, error = function(e) showNotification(paste("No se pudo registrar el nacimiento:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$guardar_destete, {
    if (is.null(input$destete_animal) || !nzchar(input$destete_animal)) { showNotification('Selecciona el animal destetado.', type='error'); return() }
    tryCatch({
      dbExecute(conexion, "INSERT INTO eventos_destete(animal_id, fecha, observaciones) VALUES (?, ?, ?)", params = list(input$destete_animal, as.character(input$destete_fecha), if (nzchar(trimws(input$destete_observaciones))) trimws(input$destete_observaciones) else NA_character_))
      updateTextAreaInput(session, 'destete_observaciones', value = '')
      recargar(recargar() + 1L)
      showNotification('Destete registrado.', type='message')
    }, error = function(e) showNotification(paste('No se pudo registrar el destete:', conditionMessage(e)), type='error', duration=NULL))
  })

  observeEvent(input$guardar_sanidad, {
    es_animal <- identical(input$sanidad_alcance, "ANIMAL")
    destino <- if (es_animal) input$sanidad_animal else input$sanidad_grupo
    if (is.null(destino) || !nzchar(destino)) {
      showNotification("Selecciona el animal o grupo al que se aplicó el evento.", type = "error")
      return()
    }
    usa_inventario <- identical(input$sanidad_origen_producto, "INVENTARIO")
    usa_externo <- identical(input$sanidad_origen_producto, "EXTERNO")
    producto_externo <- if (usa_externo) trimws(input$sanidad_producto) else ""
    if (usa_inventario && (is.null(input$sanidad_item) || !nzchar(input$sanidad_item) || is.na(input$sanidad_dosis) || input$sanidad_dosis <= 0)) {
      showNotification("Para usar inventario, elige un producto y escribe la cantidad a descontar.", type = "error")
      return()
    }
    if (usa_externo && !nzchar(producto_externo)) {
      showNotification("Escribe el nombre del producto externo.", type = "error")
      return()
    }
    observaciones <- trimws(input$sanidad_observaciones)
    if (nzchar(trimws(input$sanidad_responsable))) {
      observaciones <- paste(c(if (nzchar(observaciones)) observaciones, paste("Responsable:", trimws(input$sanidad_responsable))), collapse = " | ")
    }
    tryCatch({
      dbWithTransaction(conexion, {
        evento_id <- insertar_con_id(conexion, "INSERT INTO eventos_sanitarios(fecha, tipo_codigo, animal_id, grupo_id, diagnostico_motivo, observaciones)
          VALUES (?, ?, ?, ?, ?, ?)", params = list(as.character(input$sanidad_fecha), input$sanidad_tipo,
          if (es_animal) destino else NA_character_, if (es_animal) NA_integer_ else as.integer(destino),
          if (nzchar(trimws(input$sanidad_motivo))) trimws(input$sanidad_motivo) else NA_character_,
           if (nzchar(observaciones)) observaciones else NA_character_), "evento_sanitario_id")
        unidad <- if (nzchar(trimws(input$sanidad_unidad))) trimws(input$sanidad_unidad) else NA_character_
        dosis <- if (is.na(input$sanidad_dosis)) NA_real_ else input$sanidad_dosis
        if (usa_inventario) {
          movimiento_id <- insertar_con_id(conexion, "INSERT INTO movimientos_inventario(item_id, fecha, tipo_codigo, cantidad, motivo, referencia_tipo, referencia_id)
            VALUES (?, ?, 'SALIDA', ?, 'Uso sanitario', 'EVENTO_SANITARIO', ?)",
            params = list(as.integer(input$sanidad_item), as.character(input$sanidad_fecha), dosis, as.character(evento_id)),
            "movimiento_id")
          dbExecute(conexion, "INSERT INTO evento_sanitario_productos(evento_sanitario_id, item_id, movimiento_inventario_id, dosis, unidad_medida)
            VALUES (?, ?, ?, ?, ?)", params = list(evento_id, as.integer(input$sanidad_item), movimiento_id, dosis, unidad))
        } else if (usa_externo) {
          dbExecute(conexion, "INSERT INTO evento_sanitario_productos(evento_sanitario_id, producto_externo, dosis, unidad_medida)
            VALUES (?, ?, ?, ?)", params = list(evento_id, producto_externo, dosis, unidad))
        }
      })
      updateTextInput(session, "sanidad_producto", value = "")
      updateSelectInput(session, "sanidad_item", selected = "")
      updateNumericInput(session, "sanidad_dosis", value = NA)
      updateTextInput(session, "sanidad_unidad", value = "")
      updateTextInput(session, "sanidad_motivo", value = "")
      updateTextInput(session, "sanidad_responsable", value = "")
      updateTextAreaInput(session, "sanidad_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Evento sanitario guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_item, {
    nombre <- trimws(input$inv_nombre)
    unidad <- trimws(input$inv_unidad)
    if (!nzchar(nombre) || !nzchar(unidad)) {
      showNotification("Escribe el nombre y la unidad de medida.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO items_inventario(nombre, categoria_codigo, unidad_medida, stock_minimo, ubicacion) VALUES (?, ?, ?, ?, ?)",
        params = list(nombre, input$inv_categoria, unidad, input$inv_stock_minimo,
          if (nzchar(trimws(input$inv_ubicacion))) trimws(input$inv_ubicacion) else NA_character_))
      updateTextInput(session, "inv_nombre", value = "")
      updateTextInput(session, "inv_unidad", value = "")
      updateNumericInput(session, "inv_stock_minimo", value = 0)
      updateTextInput(session, "inv_ubicacion", value = "")
      recargar(recargar() + 1L)
      showNotification("Producto creado.", type = "message")
    }, error = function(e) showNotification(conditionMessage(e), type = "error"))
  })

  observeEvent(input$guardar_mov_inv, {
    if (is.null(input$mov_inv_item) || !nzchar(input$mov_inv_item) || is.na(input$mov_inv_cantidad) || input$mov_inv_cantidad <= 0) {
      showNotification("Selecciona un producto y escribe una cantidad mayor que cero.", type = "error")
      return()
    }
    es_entrada <- identical(input$mov_inv_tipo, "ENTRADA")
    vencimiento <- if (is.null(input$mov_inv_vencimiento) || is.na(input$mov_inv_vencimiento)) NA_character_ else as.character(input$mov_inv_vencimiento)
    tryCatch({
      dbWithTransaction(conexion, {
        lote_id <- if (!es_entrada && nzchar(input$mov_inv_lote_existente)) as.integer(input$mov_inv_lote_existente) else NA_integer_
        if (es_entrada) {
          lote_id <- insertar_con_id(conexion, "INSERT INTO inventario_lotes(item_id, codigo_lote, fecha_ingreso, fecha_vencimiento, costo_unitario)
            VALUES (?, ?, ?, ?, ?)", params = list(as.integer(input$mov_inv_item),
            if (nzchar(trimws(input$mov_inv_lote_nuevo))) trimws(input$mov_inv_lote_nuevo) else NA_character_,
            as.character(input$mov_inv_fecha), vencimiento,
            if (is.na(input$mov_inv_costo)) NA_real_ else input$mov_inv_costo), "lote_id")
        }
        dbExecute(conexion, "INSERT INTO movimientos_inventario(item_id, lote_id, fecha, tipo_codigo, cantidad, costo_unitario, motivo)
          VALUES (?, ?, ?, ?, ?, ?, ?)", params = list(as.integer(input$mov_inv_item), lote_id,
          as.character(input$mov_inv_fecha), input$mov_inv_tipo, input$mov_inv_cantidad,
          if (is.na(input$mov_inv_costo)) NA_real_ else input$mov_inv_costo,
          if (nzchar(trimws(input$mov_inv_observaciones))) trimws(input$mov_inv_observaciones) else NA_character_))
      })
      updateNumericInput(session, "mov_inv_cantidad", value = NA)
      updateTextInput(session, "mov_inv_lote_nuevo", value = "")
      updateDateInput(session, "mov_inv_vencimiento", value = NULL)
      updateNumericInput(session, "mov_inv_costo", value = NA)
      updateTextAreaInput(session, "mov_inv_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Movimiento de inventario guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_activo, {
    nombre <- trimws(input$activo_nombre)
    if (!nzchar(nombre)) {
      showNotification("Escribe el nombre del activo.", type = "error")
      return()
    }
    vacio_a_na <- function(x) if (is.null(x) || !nzchar(trimws(x))) NA_character_ else trimws(x)
    fecha_adquisicion <- if (is.null(input$activo_fecha_adquisicion) || is.na(input$activo_fecha_adquisicion)) NA_character_ else as.character(input$activo_fecha_adquisicion)
    tryCatch({
      dbExecute(conexion, "
        INSERT INTO activos(nombre, categoria_codigo, marca, modelo, placa, serial, fecha_adquisicion,
          valor_adquisicion, ubicacion, estado_codigo, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        params = list(nombre, input$activo_categoria, vacio_a_na(input$activo_marca), vacio_a_na(input$activo_modelo),
          vacio_a_na(input$activo_placa), vacio_a_na(input$activo_serial), fecha_adquisicion,
          if (is.na(input$activo_valor)) NA_real_ else input$activo_valor, vacio_a_na(input$activo_ubicacion),
          input$activo_estado, vacio_a_na(input$activo_observaciones)))
      updateTextInput(session, "activo_nombre", value = "")
      updateTextInput(session, "activo_marca", value = "")
      updateTextInput(session, "activo_modelo", value = "")
      updateTextInput(session, "activo_placa", value = "")
      updateTextInput(session, "activo_serial", value = "")
      updateDateInput(session, "activo_fecha_adquisicion", value = NULL)
      updateNumericInput(session, "activo_valor", value = NA)
      updateTextInput(session, "activo_ubicacion", value = "")
      updateTextAreaInput(session, "activo_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Activo guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_mantenimiento, {
    if (is.null(input$mant_activo) || !nzchar(input$mant_activo) || !nzchar(trimws(input$mant_descripcion))) {
      showNotification("Selecciona un activo y describe el trabajo realizado.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "
        INSERT INTO mantenimientos_activos(activo_id, fecha, tipo_codigo, descripcion, costo, observaciones)
        VALUES (?, ?, ?, ?, ?, ?)",
        params = list(as.integer(input$mant_activo), as.character(input$mant_fecha), input$mant_tipo,
          trimws(input$mant_descripcion), if (is.na(input$mant_costo)) NA_real_ else input$mant_costo,
          if (nzchar(trimws(input$mant_observaciones))) trimws(input$mant_observaciones) else NA_character_))
      updateTextAreaInput(session, "mant_descripcion", value = "")
      updateNumericInput(session, "mant_costo", value = NA)
      updateTextAreaInput(session, "mant_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Mantenimiento guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_finanza, {
    concepto <- trimws(input$fin_concepto)
    if (is.null(input$fin_categoria) || !nzchar(input$fin_categoria) || !nzchar(concepto) ||
        is.na(input$fin_valor_total) || input$fin_valor_total <= 0) {
      showNotification("Selecciona categoría y escribe un concepto y valor total válidos.", type = "error")
      return()
    }
    total <- input$fin_valor_total
    estado_pago <- input$fin_estado_pago
    valor_pagado <- if (estado_pago == "PAGADO") total else if (estado_pago == "PENDIENTE") 0 else input$fin_valor_pagado
    if (is.na(valor_pagado) || (estado_pago == "PARCIAL" && (valor_pagado <= 0 || valor_pagado >= total))) {
      showNotification("Para un pago parcial, escribe un valor mayor que cero y menor que el total.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO movimientos_financieros(fecha, tipo, categoria_financiera_id, tercero_id,
        concepto, valor_total, estado_pago, valor_pagado, fecha_pago, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", params = list(as.character(input$fin_fecha), input$fin_tipo,
        as.integer(input$fin_categoria), if (nzchar(input$fin_tercero)) as.integer(input$fin_tercero) else NA_integer_,
        concepto, total, estado_pago, valor_pagado, if (estado_pago == "PENDIENTE") NA_character_ else as.character(input$fin_fecha_pago),
        if (nzchar(trimws(input$fin_observaciones))) trimws(input$fin_observaciones) else NA_character_))
      updateTextInput(session, "fin_concepto", value = "")
      updateNumericInput(session, "fin_valor_total", value = NA)
      updateNumericInput(session, "fin_valor_pagado", value = NA)
      updateTextAreaInput(session, "fin_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Movimiento financiero guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_personal, {
    nombre <- trimws(input$personal_nombre)
    rol <- trimws(input$personal_rol)
    if (!nzchar(nombre) || !nzchar(rol)) {
      showNotification("Escribe el nombre y el rol del personal.", type = "error")
      return()
    }
    tryCatch({
      dbExecute(conexion, "INSERT INTO terceros(tipo_codigo, nombre, observaciones, activo) VALUES ('PERSONAL', ?, ?, 1)",
        params = list(nombre, paste("Rol:", rol)))
      updateTextInput(session, "personal_nombre", value = "")
      updateTextInput(session, "personal_rol", value = "")
      recargar(recargar() + 1L)
      showNotification("Personal registrado y disponible como tercero.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo registrar el personal:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_comprador, {
    nombre <- trimws(input$comprador_nombre)
    if (!nzchar(nombre)) {
      showNotification("Escribe el nombre o razón social del comprador.", type = "error")
      return()
    }
    vacio_a_na <- function(x) if (is.null(x) || !nzchar(trimws(x))) NA_character_ else trimws(x)
    tryCatch({
      dbExecute(conexion, "INSERT INTO terceros(tipo_codigo, nombre, documento, telefono, correo, observaciones)
        VALUES ('COMPRADOR', ?, ?, ?, ?, ?)", params = list(nombre, vacio_a_na(input$comprador_documento),
          vacio_a_na(input$comprador_telefono), vacio_a_na(input$comprador_correo), vacio_a_na(input$comprador_observaciones)))
      updateTextInput(session, "comprador_nombre", value = "")
      updateTextInput(session, "comprador_documento", value = "")
      updateTextInput(session, "comprador_telefono", value = "")
      updateTextInput(session, "comprador_correo", value = "")
      updateTextAreaInput(session, "comprador_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Comprador guardado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo guardar:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_venta_leche, {
    if (is.na(input$leche_litros) || input$leche_litros <= 0 || is.na(input$leche_precio_litro) || input$leche_precio_litro < 0) {
      showNotification("Escribe litros y un precio por litro válido.", type = "error")
      return()
    }
    total <- input$leche_litros * input$leche_precio_litro
    tryCatch({
      dbWithTransaction(conexion, {
        categoria <- dbGetQuery(conexion, "SELECT categoria_financiera_id FROM categorias_financieras WHERE tipo='INGRESO' AND nombre='Leche' AND activo=1 LIMIT 1")
        if (nrow(categoria) == 0L) stop("No existe la categoría financiera 'Leche'.")
        leche_id <- insertar_con_id(conexion, "INSERT INTO produccion_leche(fecha, litros, precio_litro, comprador_id, observaciones) VALUES (?, ?, ?, ?, ?)",
          params = list(as.character(input$leche_fecha), input$leche_litros, input$leche_precio_litro,
            if (nzchar(input$leche_comprador)) as.integer(input$leche_comprador) else NA_integer_,
            if (nzchar(trimws(input$leche_observaciones))) trimws(input$leche_observaciones) else NA_character_),
          "produccion_leche_id")
        movimiento_id <- insertar_con_id(conexion, "INSERT INTO movimientos_financieros(fecha, tipo, categoria_financiera_id, tercero_id, concepto, valor_total, estado_pago, valor_pagado, fecha_pago, origen_tipo, origen_id) VALUES (?, 'INGRESO', ?, ?, ?, ?, 'PAGADO', ?, ?, 'PRODUCCION_LECHE', ?)",
          params = list(as.character(input$leche_fecha), categoria$categoria_financiera_id[1],
            if (nzchar(input$leche_comprador)) as.integer(input$leche_comprador) else NA_integer_, paste('Venta de leche #', leche_id), total, total, as.character(input$leche_fecha), as.character(leche_id)),
          "movimiento_financiero_id")
        dbExecute(conexion, "UPDATE produccion_leche SET movimiento_financiero_id=? WHERE produccion_leche_id=?", params = list(movimiento_id, leche_id))
      })
      updateNumericInput(session, "leche_litros", value = NA)
      # El precio por litro se conserva para facilitar registros consecutivos;
      # solo cambia cuando el usuario lo modifica manualmente.
      updateTextAreaInput(session, "leche_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Venta de leche registrada e ingreso financiero creado.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo registrar la venta de leche:", conditionMessage(e)), type = "error", duration = NULL))
  })
  observeEvent(input$guardar_compra_ganado, {
    if (is.na(input$compra_ganado_valor) || input$compra_ganado_valor <= 0) {
      showNotification("Indica un valor total válido para la compra.", type = "error"); return()
    }
    pagado <- if (is.na(input$compra_ganado_pagado)) 0 else input$compra_ganado_pagado
    if (input$compra_ganado_estado_pago == "PAGADO") pagado <- input$compra_ganado_valor
    if (input$compra_ganado_estado_pago == "PENDIENTE") pagado <- 0
    if (pagado < 0 || pagado > input$compra_ganado_valor) {
      showNotification("El monto pagado no puede superar el valor total.", type = "error"); return()
    }
    tryCatch({
      dbWithTransaction(conexion, {
        categoria <- dbGetQuery(conexion, "SELECT categoria_financiera_id FROM categorias_financieras WHERE tipo='EGRESO' AND nombre='Compra de ganado' AND activo=1 LIMIT 1")
        if (!nrow(categoria)) stop("No existe la categoría financiera Compra de ganado.")
        dbExecute(conexion, "INSERT INTO movimientos_financieros(fecha, tipo, categoria_financiera_id, tercero_id, concepto, valor_total, estado_pago, valor_pagado, fecha_pago, origen_tipo, observaciones) VALUES (?, 'EGRESO', ?, ?, 'Compra de ganado', ?, ?, ?, ?, 'COMPRA_GANADO', ?)",
          params = list(as.character(input$compra_ganado_fecha), categoria$categoria_financiera_id[1], if (nzchar(input$compra_ganado_tercero)) as.integer(input$compra_ganado_tercero) else NA_integer_, input$compra_ganado_valor, input$compra_ganado_estado_pago, pagado, if (input$compra_ganado_estado_pago == 'PENDIENTE') NA_character_ else as.character(input$compra_ganado_fecha), if (nzchar(trimws(input$compra_ganado_observaciones))) trimws(input$compra_ganado_observaciones) else NA_character_))
      })
      updateNumericInput(session, "compra_ganado_valor", value = NA); updateNumericInput(session, "compra_ganado_pagado", value = NA); updateTextAreaInput(session, "compra_ganado_observaciones", value = "")
      recargar(recargar() + 1L); showNotification("Compra de ganado registrada como egreso financiero.", type = "message")
    }, error = function(e) showNotification(paste("No se pudo registrar la compra:", conditionMessage(e)), type = "error", duration = NULL))
  })

  observeEvent(input$guardar_venta, {
    detalle <- detalle_venta_seleccionada()
    if (is.null(input$venta_comprador) || !nzchar(input$venta_comprador) || nrow(detalle) == 0L ||
        is.na(input$venta_precio_kg) || input$venta_precio_kg < 0) {
      showNotification("Selecciona comprador y animales, e indica un precio por kg válido.", type = "error")
      return()
    }
    total <- sum(detalle$Valor)
    estado_pago <- input$venta_estado_pago
    valor_pagado <- if (estado_pago == "PAGADO") total else if (estado_pago == "PENDIENTE") 0 else input$venta_valor_pagado
    if (is.na(valor_pagado) || (estado_pago == "PARCIAL" && (valor_pagado <= 0 || valor_pagado >= total))) {
      showNotification("Para un pago parcial, escribe un monto mayor que cero y menor que el total.", type = "error")
      return()
    }
    fecha <- as.character(input$venta_fecha)
    ids <- detalle$Animal
    tryCatch({
      dbWithTransaction(conexion, {
        categoria <- dbGetQuery(conexion, "SELECT categoria_financiera_id FROM categorias_financieras
          WHERE tipo='INGRESO' AND nombre='Venta de ganado' AND activo=1 LIMIT 1")
        if (nrow(categoria) == 0L) stop("No existe la categoría financiera 'Venta de ganado'.")
        venta_id <- insertar_con_id(conexion, "INSERT INTO ventas_ganado(fecha, comprador_id, precio_kg_referencial, observaciones)
          VALUES (?, ?, ?, ?)", params = list(fecha, as.integer(input$venta_comprador), input$venta_precio_kg,
          if (nzchar(trimws(input$venta_observaciones))) trimws(input$venta_observaciones) else NA_character_), "venta_id")
        for (i in seq_len(nrow(detalle))) {
          dbExecute(conexion, "INSERT INTO venta_animales(venta_id, animal_id, peso_kg, precio_kg_aplicado, valor_animal)
            VALUES (?, ?, ?, ?, ?)", params = list(venta_id, detalle$Animal[i], detalle$`Peso (kg)`[i],
              detalle$`Precio/kg`[i], detalle$Valor[i]))
        }
        movimiento_id <- insertar_con_id(conexion, "INSERT INTO movimientos_financieros(fecha, tipo, categoria_financiera_id, tercero_id,
          concepto, valor_total, estado_pago, valor_pagado, fecha_pago, origen_tipo, origen_id)
          VALUES (?, 'INGRESO', ?, ?, ?, ?, ?, ?, ?, 'VENTA_GANADO', ?)", params = list(fecha,
          categoria$categoria_financiera_id[1], as.integer(input$venta_comprador), paste("Venta de ganado #", venta_id),
          total, estado_pago, valor_pagado, if (estado_pago == "PENDIENTE") NA_character_ else fecha, as.character(venta_id)),
          "movimiento_financiero_id")
        dbExecute(conexion, "UPDATE ventas_ganado SET movimiento_financiero_id=? WHERE venta_id=?", params = list(movimiento_id, venta_id))
        for (animal_id in ids) {
          dbExecute(conexion, "UPDATE animal_estado_historial SET fecha_fin=?
            WHERE animal_id=? AND fecha_fin IS NULL AND anulado_en IS NULL", params = list(fecha, animal_id))
          dbExecute(conexion, "INSERT INTO animal_estado_historial(animal_id, estado_codigo, fecha_inicio, motivo)
            VALUES (?, 'VENDIDO', ?, ?)", params = list(animal_id, fecha, paste("Venta #", venta_id)))
          dbExecute(conexion, "UPDATE animal_grupo_historial SET fecha_fin=?
            WHERE animal_id=? AND fecha_fin IS NULL AND anulado_en IS NULL", params = list(fecha, animal_id))
        }
      })
      updateCheckboxGroupInput(session, "venta_animales", selected = character(0))
      updateNumericInput(session, "venta_precio_kg", value = NA)
      updateNumericInput(session, "venta_valor_pagado", value = NA)
      updateTextAreaInput(session, "venta_observaciones", value = "")
      recargar(recargar() + 1L)
      showNotification("Venta registrada, ingreso financiero creado y animales marcados como vendidos.", type = "message", duration = NULL)
    }, error = function(e) showNotification(paste("No se pudo registrar la venta:", conditionMessage(e)), type = "error", duration = NULL))
  })
}

# La barrera de acceso se sirve antes de montar la interfaz principal. Por eso,
# la cinemática de bienvenida y la conexión a PostgreSQL solo se inician después
# de validar la contraseña de la aplicación.
ui <- fluidPage(
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1, viewport-fit=cover"),
    tags$meta(name = "theme-color", content = "#173a63"),
    tags$link(rel = "icon", type = "image/png", sizes = "32x32", href = "app-icon-32.png"),
    tags$link(rel = "apple-touch-icon", sizes = "180x180", href = "apple-touch-icon.png"),
    tags$link(rel = "manifest", href = "site.webmanifest"),
    tags$style(HTML(" 
      html, body { min-height: 100%; margin: 0; background: #edf3f8; }
      .acceso-app { min-height: 100vh; display: flex; align-items: center; justify-content: center;
        padding: 24px; background: linear-gradient(145deg, #173a63, #2f6b9a); }
      .acceso-app__tarjeta { width: min(100%, 430px); padding: 32px; border-radius: 16px;
        background: #fffdf8; box-shadow: 0 12px 38px rgba(0, 0, 0, .23); }
      .acceso-app__logo { display: block; width: min(100%, 250px); max-height: 130px;
        object-fit: contain; margin: 0 auto 22px; }
      .acceso-app__titulo { margin: 0 0 8px; text-align: center; color: #173a63; font-weight: 700; }
      .acceso-app__ayuda { margin-bottom: 22px; text-align: center; color: #526477; }
      .acceso-app__error { min-height: 22px; margin: 8px 0 0; color: #a32632; font-weight: 600; }
      .acceso-app .btn-primary { width: 100%; margin-top: 10px; background: #2f6b9a; border: 0; }
      .acceso-app .form-control { min-height: 44px; }
      @media (max-width: 480px) { .acceso-app { padding: 16px; }
        .acceso-app__tarjeta { padding: 24px 20px; } }
    "))
  ),
  uiOutput("pantalla_acceso_app")
)

server <- function(input, output, session) {
  password_app <- Sys.getenv("FINCA_APP_PASSWORD", unset = "")
  if (!nzchar(password_app)) {
    stop("Falta la variable secreta FINCA_APP_PASSWORD para proteger el acceso a la aplicación.")
  }

  autenticado <- reactiveVal(FALSE)

  output$pantalla_acceso_app <- renderUI({
    if (isTRUE(autenticado())) return(ui_aplicacion)
    tagList(
      div(class = "acceso-app",
        div(class = "acceso-app__tarjeta",
          tags$img(src = "logo-la-machacada.png", class = "acceso-app__logo", alt = "La Machacada Ganadería"),
          h2(class = "acceso-app__titulo", "Acceso a la aplicación"),
          p(class = "acceso-app__ayuda", "Ingresa la contraseña para continuar."),
          passwordInput("contrasena_entrada_app", "Contraseña"),
          actionButton("entrar_app", "Entrar", class = "btn-primary")
        )
      )
    )
  })

  observeEvent(input$entrar_app, {
    clave_ingresada <- if (is.null(input$contrasena_entrada_app)) "" else as.character(input$contrasena_entrada_app)
    if (identical(clave_ingresada, password_app)) {
      autenticado(TRUE)
      updateTextInput(session, "contrasena_entrada_app", value = "")
    }
  }, ignoreInit = TRUE)

  observeEvent(autenticado(), {
    if (isTRUE(autenticado())) server_aplicacion(input, output, session)
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)
 
