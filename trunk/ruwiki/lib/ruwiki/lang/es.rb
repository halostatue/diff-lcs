#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#   Mauricio Julio Fernández Pradier (batsman.geo@yahoo.com)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
module Ruwiki::Lang
    # Ruwiki::Lang::ES is the English-language output module. It contains a
    # hash, *Message*, that contains the messages that may be reported by
    # any method in the Ruwiki library. The messages are identified by a
    # Symbol.
  module ES
    Message = Hash.new { |h, k| h[k] = "ERROR: Identificador de mensaje desconocido: #{k.inspect}."; h[k] }
    message = {
        # The encoding for the webpages. This should match the encoding used
        # to create these messages.
      :charset_encoding             => "iso-8859-15",
        # Backend-related messages.
      :backend_unknown              => "Backend %1$s desconocido.",
      :cannot_create_project        => "No pudo crearse el proyecto %1$s: %2$s",
      :cannot_destroy_project       => "No pudo borrarse el proyecto %1$s: %2$s",
      :cannot_destroy_topic         => "No pudo borrarse %1$s::%2$s: %3$s",
      :cannot_obtain_lock           => "No pudo obtenerse el cerrojo para %1$s::%2$s. Reinténtelo de nuevo en breve.",
      :cannot_release_lock          => "No pudo liberarse el cerrojo para %1$s::%2$s. Reinténtelo de nuevo en breve.",
      :cannot_retrieve_topic        => "No pudo obtenerse %1$s::%2$s: %3$s",
      :cannot_store_topic           => "No pudo almacenarse %1$s::%2$s: %3$s",
      :cannot_list_topics           => "No se pudo listar los temas del proyecto %1$s: %2$s",
      :error_creating_lock          => "Error al crear el cerrojo para %1$s::%2$s: %3$s",
      :error_releasing_lock         => "Error al liberar el cerrojo para %1s::%2$s: %3$s",
      :flatfiles_no_data_directory  => "El directorio de datos (%1$s) no existe.",
      :no_access_list_projects      => "Permiso denegado al listar los proyectos.",
      :no_access_list_topics        => "Permiso denegado al listar los temas del proyecto %1$s.",
      :no_access_to_create_project  => "Permiso denegado al crear el proyecto %1$s.",
      :no_access_to_destroy_project => "Permiso denegado al borrar el proyecto %1$s::%2$s.",
      :no_access_to_destroy_topic   => "Permiso denegado al borrar el borrar el tema %1$s::%2$s.",
      :no_access_to_read_topic      => "Permiso denegado al acceder a %1$s::%2$s.",
      :no_access_to_store_topic     => "Permiso denegado al almacenar %1$s::%2$s.",
      :page_not_in_backend_format   => "%1$s::%2$s no está en un formato soportado por el backend %3$s.",
      :project_already_exists       => "El proyecto %1$s ya existe.",
      :project_does_not_exist       => "El proyecto %1$s no existe.",
      :search_project_fail          => "Error al buscar la cadena %2$s en el proyecto %1$s.",
      :yaml_requires_182_or_higher  => "El soporte para archivos YAML sólo está disponible en Ruby versión 1.8.2 o superior.",
      :not_editing_current_version  => <<EOM ,
Ha enviado una versión antigua de %1$s::%2$s. Las diferencias entre su versión
y la actual han sido fusionadas. En caso de conflicto, las líneas de ambas 
versiones serán mostradas. Asegúrese de editar la página en su totalidad
antes de salvar de nuevo.
EOM

        # Config-related messages.
      :config_not_ruwiki_config     => "La configuración debe ser de clase Ruwiki::Config.",
      :invalid_template_dir         => "El path para plantillas (%1$s) no existe o no es un directorio.",
      :no_template_found            => "No pudo encontrarse la plantilla para %1$s en el conjunto %2$s.",
      :no_template_set              => "No pudo encontrarse el conjunto de plantillas '%1$s' en el path.",
      :no_webmaster_defined         => "Error de configuración: Webmaster no está definido.",
        # Miscellaneous messages.
      :complete_utter_failure       => "Error catastrófico",
      :editing                      => "Edición",
      :error                        => "Error",
      :invalid_path_info_value      => "Algo huele a podrido en su entorno Web. PATH_INFO = %1$s",
      :render_arguments             => "Ruwiki#render debe ser llamado con cero o dos argumentos.",
      :unknown_feature              => "Característica desconocida: %1$s.",
      :topics_for_project           => "Temas del Proyecto ::%1$s",
      :project_topics_link          => "(temas)",
      :wiki_projects                => "Proyectos en %1$s",
      :no_projects                  => "Ningún proyecto.",
      :no_topics                    => "El proyecto %1$s no tiene nigún tema.",
      :search_results_for           => "= Resultados de la búsqueda de: %1$s",
      :number_of_hits               => "%1$d Resultados",

        # Labels
      :label_search_project         => "Buscar en projecto",
      :label_search_all             => "Todo",
      :label_search                 => "Buscar: ",
      :label_project                => "Proyecto: ",
      :label_topic                  => "Tema: ",
      :label_edit                   => "Editar",
      :label_recent_changes         => "Cambios recientes",
      :label_topics                 => "Temas",
      :label_projects               => "Proyectos",
      :label_editing                => "Edición",
      :label_text                   => "Texto:",
      :label_text_accelerator       => "T",
      :label_edit_comment           => "Editar Comentario: ",
      :label_comment_accelerator    => "O",
      :label_save                   => "Salvar",
      :label_save_accelerator       => "S",
      :label_cancel                 => "Cancelar",
      :label_cancel_accelerator     => "C",
      :label_preview                => "Previsualizar",
      :label_preview_accelerator    => "P",
      :label_original_text          => "Text Original",
      :label_raw                    => "Crudo",
      :label_formatted              => "Formateado",
      :label_send_report_by         => "Enviar notificación al administrador del Wiki por email.",
      :label_send_report            => "Enviar notificación.",
      :label_saved_page             => "Página salvada: ",

        # Messages from Ruwiki::Utils::Converter
        # Note to translators: certain words should be left alone. These
        # will be marked in comments. Description lines are restricted to 40
        # characters and should be an array. Use this as a ruler.
        #                           => [ "----------------------------------------" ]
      :converter_usage              => "Modo de empleo: %1$s [opciones] <dir.>",
      :converter_format_desc        => [ "Convertir los ficheros encontrados",
                                         "(independientemente de su formato), al",
                                         "formato especificado; por defecto ",
                                         "archivos planos. Formatos permitidos:",
                                         "   yaml marshal flatfiles" ],
      :converter_backup_desc        => [ "Crear copias de seguridad de ficheros ",
                                         "actualizados. La opción por defecto es ",
                                         "--backup." ],
      :converter_backupext_desc     => [ 'Especificar la extensión para las copias',
                                         'de seguridad (por defecto "~") que se',
                                         'añade al nombre del fichero de datos' ],
      :converter_backupext_error    => [ "La extensión para copias de seguridad",
                                         "no debe estar vacía." ],
      :converter_extension_desc     => [ "Especifica la extensión de los ficheros",
                                         "de datos de Ruwiki (por defecto .ruwiki)" ],
      :converter_extension_error    => "La extensión no debe estar vacía.",
      :converter_noextension_desc   => [ "Indica que los ficheros de datos de",
                                         "Ruwiki no tienen ninguna extensión." ],
      :converter_quiet_desc         => [ "Ejecución silenciosa. Por defecto se ",
                                         "ejecuta con mensajes normales." ],
      :converter_language_desc      => [ "Especifica el idioma a emplear con LANG.",
                                         "Por defecto 'en' (inglés).",
                                         "Idiomas disponibles:  en es de" ],
      :converter_verbose_desc       => [ "Información detallada de ejecución.",
                                         "Por defecto se ejecuta con un nivel de ",
                                         "detalle inferior." ],
      :converter_help_desc          => [ "Mostrar este texto." ],
      :converter_num_arguments      => "Error: número de argumentos insuficiente.",
      :converter_directory          => "directorio",
      :converter_converting_from    => "convertiendo de %1$s a %2$s ... ",
      :converter_done               => "hecho.",
      :converter_not_ruwiki         => "no es un fichero de Ruwiki; ignorando.",
      :converter_nosave_modified    => "no pudo salvarse %1$s.",
      :converter_page_format_error  => "Error: No pudo detectarse el formato de la página.",

        # Messages from Ruwiki::Utils::Manager
      :manager_unknown_command      => "Comando desconocido: %1$s",
      :manager_help_commands        => <<EOH ,
Los comandos reconocidos por 'ruwiki' son:

    ruwiki install              Instala el entorno por defecto.
    ruwiki package              Empaqueta una instalación de Ruwiki.
    ruwiki unpackage            Desempaqueta una instalación de Ruwiki.
    ruwiki service              Gestiona un Win32::Service para Ruwiki.

EOH
      :manager_help_help            => <<-EOH ,
Este es un mensaje de ayuda básico con referencias a información suplementaria
relativa a esta herramienta de la línea de comandos. Intente:

    ruwiki help commands        mostrar todos los comandos de ruwiki
    ruwiki help <COMANDO>       mostrar ayuda sobre <COMANDO>
                                  (p.ej., 'ruwiki help install')

EOH
      :manager_missing_parameter    => "Falta parámetro para la opción: %1$s",
      :manager_dest_not_directory   => "El destino (%1$s) no es un directorio.",
      :manager_install_help         => <<-EOH ,
    ruwiki install [OPCIONES] [--to DEST]

Crea una instancia de Ruwiki. Por defecto, se instala los ficheros de datos,
plantillas y la configuración por defecto en el directorio actual. El destino
puede ser cambiado con la opción --to, y los elementos a instalar con la lista
de OPCIONES, que puede ser delimitada por espacios, comas o puntos y comas.
Así pues,

    ruwiki install data;servlet
    ruwiki install data,servlet
    ruwiki install data servlet

son equivalentes. Las opciones pueden especificarse en mayúsculas/minúsculas.
Las opciones de instalación son:

    servlet       # Instala el stub para el servlet Ruwiki
    service       # Instala el stub para el Win32::Service Ruwiki
    CGI           # Instala el script CGI Ruwiki
    data          # Instala los datos, plantillas y configuración de Ruwiki

Las opciones pueden deshabilitarse precediéndolas de un guión o 'no':

    ruwiki install cgi -data
    ruwiki install cgi nodata

instalarán el script CGI pero no los datos.
EOH
      :manager_package_help         => <<-EOH ,
    ruwiki package [FUENTE] [--output PAQUETE] [--replace]
    ruwiki package [FUENTE] [-o PAQUETE] [--replace]

Empaqueta los ficheros de Ruwiki (datos, plantillas y ejecutables) de la
FUENTE especificada o el directorio actual en el archivo de salida
especificado (o "../%1$s"). Si la FUENTE es un fichero de configuración
de rukiwi (p.ej. "%2$s"), será empleado para determinar la localización
y el nombre de los directorios de datos y plantillas.

    NOTA: El proceso de empaquetado normaliza los nombres de los
          ficheros de datos y plantillas para que sean relativos al
          directorio de desempaquetado. NUNCA serán paths absolutos.

EOH
      :manager_unpackage_help       => <<-EOH ,
    ruwiki unpackage [FUENTE] [--output DIRECTORIO]
    ruwiki unpackage [FUENTE] [-o DIRECTORIO]

Desempaqueta el paquete de Ruwiki provisto (por defecto "./%1$s")
en el directorio indicado (por defecto ".").
EOH
      :manager_service_lo_argcount  => "Argumentos insuficientes: %1$s",
      :manager_service_hi_argcount  => "Demasiados argumentos: %1$s",
      :manager_service_help         => <<-EOH ,
    ruwiki service install NOMBRE [DESCRIPCION] [opciones]
    ruwiki service start   NOMBRE
    ruwiki service stop    NOMBRE
    ruwiki service delete  NOMBRE

Gestiona el servlet Ruwiki para WEBrick como un servicio de Windows, bajo el
NOMBRE indicado. install soporta además las opciones siguientes:

  --rubybin RUBYPATH      Path del ejecutable Ruby.
  --exec    SERVICEPATH   Path del ejecutable del servicio.
  --home    PATHTOHOME    Path del directorio home.
EOH
      :manager_package_exists       => "El paquete %1$s ya existe.",
      :manager_service_installed    => "Servicio %1$s instalado.",
      :manager_one_moment           => "Un momento, %1$s ...",
      :manager_service_started      => "Servicio %1$s iniciado.",
      :manager_service_stopped      => "Servicio %1$s parado.",
      :manager_service_deleted      => "Servicio %1$s borrado.",

        # Messages from Ruwiki::Utils::Converter
        # Note to translators: certain words should be left alone. These
        # will be marked in comments. Description lines are restricted to 40
        # characters and should be an array. Use this as a ruler.
        #                           => [ "----------------------------------------" ]
      :runner_usage                 => "Modo de empleo: %1$s [opciones]",
      :runner_general_options       => "Opciones generales:",
      :runner_saveconfig_desc       => [ "Salvar la configuración en FILENAME y",
                                         "salir. Si no se emplea FILENAME, la",
                                         "configuración por defecto será usada.",
                                         "Todas las opciones serán leídas del",
                                         "fichero existente y de la línea de",
                                         "comandos y salvadas. El servlet no se",
                                         "arrancará. El nombre por defecto es:" ],
      :runner_config_desc           => [ "Leer la configuración por defecto de",
                                         "FILENAME en vez del fichero por defecto",
                                         "Las opciones especificadas anteriormente",
                                         "serán sobrescritas" ],
      :runner_webrick_options       => "Opciones de WEBrick:",
      :runner_port_desc             => [ "Ejecutar el servlet Ruwiki en el puerto",
                                         "especificado; por defecto 8808." ],
      :runner_address_desc          => [ "Aceptar únicamente conexiones desde las",
                                         "direcciones especificadas (separadas por",
                                         "comas). Puede usarse repetidamente. Por",
                                         "defecto todas las direcciones serán",
                                         "aceptadas" ],
      :runner_local_desc            => [ "Aceptar únicamente conexiones locales",
                                         "(127.0.0.1). Anula las direcciones",
                                         "indicadas previamente en -A" ],
      :runner_mountpoint_desc       => [ "URI relativo en el que Ruwiki estará",
                                         'accesible. Por defecto "/".' ],
      :runner_log_desc              => [ "Realizar log de la actividad de WEBrick.",
                                         "Por defecto se usa --log." ],
      :runner_logfile_desc          => [ "Fichero en el que escribir los logs de",
                                         "WEBrick. Por defecto, el standard error." ],
      :runner_threads_desc          => [ "Asigna al threadcount de WEBrick." ],
      :runner_ruwiki_options        => "Opciones de Ruwiki:",
      :runner_language_desc         => [ 'Idioma de la inferfaz de Ruwiki.',
                                         'Por defecto "en". Puede ser "en", ',
                                         '"de", o  "es".' ],
      :runner_webmaster_desc        => [ 'Email del webmaster de Ruwiki.',
                                         'Por defecto "webmaster@domain.tld".' ],
      :runner_debug_desc            => [ 'Activa debugging de Ruwiki. Por defecto',
                                         'inhabilitado.' ],
      :runner_title_desc            => 'Título del Ruwiki. Por defecto "Ruwiki".',
      :runner_defaultpage_desc      => [ 'Página por defecto alternativa; por',
                                         'defecto "ProjectIndex".' ],
      :runner_defaultproject_desc   => [ 'Proyecto por defecto. Por defecto',
                                         '"Default".' ],
      :runner_templatepath_desc     => [ 'Localización de las plantillas.',
                                         'Por defecto "./templates".' ],
      :runner_templatename_desc     => [ 'Nombre de las plantillas. Por defecto',
                                         '"default".' ],
      :runner_cssname_desc          => [ 'Nombre del fichero CSS en el directorio',
                                         'de plantillas. Por defecto "ruwiki.css".' ],
      :runner_storage_desc          => [ 'Tipo de almacenamiento:' ],
      :runner_datapath_desc         => [ 'Path donde salvar los ficheros de datos.',
                                         'Por defecto; "./data".' ],
      :runner_extension_desc        => [ 'Extensión para ficheros de datos.',
                                         'Por defecto "ruwiki".' ],
      :runner_central_desc          => [ 'Ejecuta Ruwiki con los datos del',
                                         'directorio RubyGem.' ],
      :runner_general_info          => "Información general:",
      :runner_help_desc             => [ "Muestra este texto." ],
      :runner_version_desc          => [ "Muestra la versión de Ruwiki." ],
      :runner_rejected_address      => "Dirección remota %1$s rechazada. Sólo se admiten conexiones desde %2$s.",
      :runner_banner                => <<-BANNER ,
%1$s

Opciones de WEBrick:
  Puerto                 %2$d
  Direcciones admitidas  %3$s
  Punto de montaje       %4$s
  Logging?               %5$s
  Destino del log        %6$s
  Hebras                 %7$s

Opciones de Ruwiki:
  Webmaster              %8$s
  Debugging?             %9$s
  Título                 %10$s
  Proyecto por defecto   %11$s
  Página por defecto     %12$s
  Path para plantillas   %13$s
  Conjunto de plantillas %14$s
  Fuente CSS             %15$s

  Tipo de almacenamiento %16$s
  Path de datos          %17$s
  Extensión              %18$s
BANNER
    }
    message.each { |k, v| Message[k] = v }
  end
end
