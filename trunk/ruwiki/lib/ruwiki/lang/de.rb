#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#   Translation by Christian Neukirchen (chneukirchen@yahoo.de) on 22oct2003
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
module Ruwiki::Lang
    # Ruwiki::Lang::DE is the German-language output module. It contains a
    # hash, *Message*, that contains the messages that may be reported by
    # any method in the Ruwiki library. The messages are identified by a
    # Symbol.
  module DE
    Message = Hash.new { |h, k| "Sprachdatei-FEHLER: Unbekannter Nachrichten-Typ #{k.inspect}." }
    message = {
        # The encoding for the webpages. This should match the encoding used
        # to create these messages.
      :charset_encoding             => "iso-8859-15",
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
      :no_access_list_projects      => "Keine Berechtigung um das Projektliste",
      :no_access_list_topics        => "Keine Berechtigung um das Themaliste (%s).",
      :search_project_fail          => "Suchprojektausfallen %s Zeichenkette %s",

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

          # Labels
      :label_search_project         => "SuchcProjeckt",
      :label_search_all             => "Alles",
      :label_search                 => "Suchc: ",
      :label_project                => "Projekt: ",
      :label_topic                  => "Thema: ",
      :label_edit                   => "Edit",
      :label_recent_changes         => "Neue Änderungen",
      :label_topics                 => "Themaliste",
      :label_projects               => "ProjektListe",
      :label_editing                => "Editieren",
      :label_text                   => "Text:",
      :label_text_accelerator       => "T",
      :label_edit_comment           => "Redigieren Sie Anmerkung: ",
      :label_comment_accelerator    => "R",
      :label_save                   => "Außer",
      :label_save_accelerator       => "A",
      :label_cancel                 => "Löschen",
      :label_cancel_accelerator     => "L",
      :label_preview                => "Preview",
      :label_preview_accelerator    => "P",
      :label_original_text          => "Ursprüngliche Version",
      :label_raw                    => "Formatfreie",
      :label_formatted              => "Formatierte",
      :label_send_report_by         => "Schicken Sie dem webmaster einen Report durch email.",
      :label_send_report            => "Schicken Report.",
      :label_saved_page             => "Gespeicherte Seite: ",
    }
    message.each { |k, v| Message[k] = v }
  end
end
