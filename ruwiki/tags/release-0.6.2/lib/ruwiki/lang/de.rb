#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#   Translation by Christian Neukirchen (chneukirchen@yahoo.de) on 22oct2003
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
class Ruwiki
  module Lang
      # Ruwiki::Lang::DE is the German-language output module. It contains a
      # hash, *Message*, that contains the messages that may be reported by
      # any method in the Ruwiki library. The messages are identified by a
      # Symbol.
    module DE
      Message = {
          # The encoding for the webpages. This should match the encoding used
          # to create these messages.
        :encoding                     => "iso-8859-1",
          # Backend-related messages.
        :backend_unknown              => "Unbekanntes Backend %s.",
        :cannot_create_project        => "Kann %s nicht erstellen: %s",
        :cannot_destroy_project       => "Kann %s nicht zerstören: %s",
        :cannot_destroy_topic         => "Kann %s::%s nicht zerstören: %s",
        :cannot_obtain_lock           => "Kann keine Sperre für %s::%s erhalten. Bitte in Kürze nochmal versuchen.",
        :cannot_release_lock          => "Kann die Sperre für %s::%s nicht lösen. Bitte später nochmal versuchen.",
        :cannot_retrieve_topic        => "Kann auf %s::%s nicht zugreifen: %s",
        :cannot_store_topic           => "Kann %s::%s nicht speichern: %s",
        :error_creating_lock          => "Fehler beim Erzeugen der Sperre von %s::%s: %s",
        :error_releasing_lock         => "Fehler beim Lösen der Sperre von %s::%s: %s",
        :flatfiles_no_data_directory  => "Das Daten-Verzeichnis (%s) existiert nicht.",
        :no_access_to_create_project  => "Keine Berechtigung um das Projekt (%s) zu erstellen.",
        :no_access_to_destroy_project => "Keine Berechtigung um das Projekt (%s) zu zerstören.",
        :no_access_to_destroy_topic   => "Kann %s::%s nicht zerstören: %s.",
        :no_access_to_read_topic      => "Kann auf %s::%s nicht zugreifen: %s.",
        :no_access_to_store_topic     => "Kann %s::%s nicht speichern: %s.",
        :project_already_exists       => "Das Projekt %s existiert bereits.",
        :project_does_not_exist       => "Das Projekt %s existiert nicht.",
          # Config-related messages.
        :config_not_ruwiki_config     => "Die Konfiguration muss von Typ der Klasse Ruwiki::Config sein.",
        :invalid_template_dir         => "Der angegebene Pfad für Schablonen (%s) existiert nicht oder ist kein Verzeichnis.",
        :no_template_found            => "Keine Schablone %s im Schablonen-Set '%s' gefunden.",
        :no_template_set              => "Es gibt kein Schablonen-Set '%s' im Schablonen-Pfad.",
        :no_webmaster_defined         => "Konfigurations-Fehler: Webmaster nicht definiert.",
          # Miscellaneous messages.
        :complete_utter_failure       => "Fataler Fehler",
        :editing                      => "Editieren",
        :error                        => "Fehler",
        :invalid_path_info_value      => "Fataler Fehler in der Web-Umgebung. PATH_INFO = %s",
          # Should this really get translated?  --chris
        :render_arguments             => "Ruwiki#render muss mit zwei oder mehr Argumenten aufgerufen werden.",
        :unknown_feature              => "Unbekanntes Feature %s."
      }
      Message.default = proc { |h, k| "Sprachdatei-FEHLER: Unbekannter Nachrichten-Typ #{k.inspect}." }
    end
  end
end
