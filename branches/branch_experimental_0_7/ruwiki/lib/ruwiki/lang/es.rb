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
class Ruwiki
  module Lang
      # Ruwiki::Lang::ES is the English-language output module. It contains a
      # hash, *Message*, that contains the messages that may be reported by
      # any method in the Ruwiki library. The messages are identified by a
      # Symbol.
    module ES
      Message = {
          # The encoding for the webpages. This should match the encoding used
          # to create these messages.
        :encoding                     => "iso-8859-1",
          # Backend-related messages.
        :backend_unknown              => "Clase Backend desconocida: %s.",
        :cannot_create_project        => "No puede crearse el proyecto %s: %s",
        :cannot_destroy_project       => "No puede borrarse el proyecto %s: %s",
        :cannot_destroy_topic         => "No puede borrarse %s::%s: %s",
        :cannot_obtain_lock           => "Imposible obtener acceso exclusivo sobre %s::%s. Reinténtelo en breve.",
        :cannot_release_lock          => "Imposible liberar acceso exclusivo sobre %s::%s. Reinténtelo en breve.",
        :cannot_retrieve_topic        => "No puede leerse %s::%s: %s",
        :cannot_store_topic           => "No puede archivarse %s::%s: %s",
        :error_creating_lock          => "Error al crear el cerrojo sobre %s::%s: %s",
        :error_releasing_lock         => "Error al liberar el cerrojo sobre %s::%s: %s",
        :flatfiles_no_data_directory  => "El directorio de datos (%s) no existe.",
        :no_access_to_create_project  => "Permiso denegado al crear el proyecto %s.",
        :no_access_to_destroy_project => "Permiso denegado al borrar el proyecto %s::%s.",
        :no_access_to_destroy_topic   => "Permiso denegado al borrar el nodo %s::%s.",
        :no_access_to_read_topic      => "Permiso denegado al leer el nodo %s::%s.",
        :no_access_to_store_topic     => "Permiso denegado al salvar el nodo %s::%s.",
        :project_already_exists       => "El proyecto %s ya existe.",
        :project_does_not_exist       => "El proyecto %s no existe.",
        :no_access_list_projects      => "Permiso denegado al lista del proyecto.",
        :no_access_list_topics        => "Permiso denagado al lista del nodo, procecto: %s.",
        :search_project_fail          => "Falta que busca proyecto %s con la secuencia %s.",

          # Config-related messages.
        :config_not_ruwiki_config     => "La configuración debe ser de clase Ruwiki::Config.",
        :invalid_template_dir         => "El path especificado para plantillas (%s) no existe o no es un directorio.",
        :no_template_found            => "No se encontró ninguna plantilla para %s en el conjunto %s.",
        :no_template_set              => "No hay ningún juego de plantillas '%s' en el path.",
        :no_webmaster_defined         => "Error de configuración: Webmaster no está definido.",
          # Miscellaneous messages.
        :complete_utter_failure       => "Fallo total y absoluto.",
        :editing                      => "Editando",
        :error                        => "Error",
        :invalid_path_info_value      => "Algo huele a podrido en su entorno Web. PATH_INFO = %s",
        :render_arguments             => "Ruwiki#render debe ser llamado con cero o dos argumentos.",
        :unknown_feature              => "Clase Feature desconocida: %s."
      }
      Message.default = proc { |h, k| "ERROR De la Lengua: Llave desconocida del mensaje #{k.inspect}." }
    end
  end
end
