#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#   Translation by Christian Neukirchen (chneukirchen@yahoo.de) on 22oct2003
#       Updated by Christian Neukirchen (purl.org/net/chneukirchen) on 27aug2004
#       Updated by Christian Neukirchen (purl.org/net/chneukirchen) on 09nov2004
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
    Message = Hash.new { |h, k| h[k] = "Sprachdatei-FEHLER: Unbekannter Nachrichten-Typ #{k.inspect}."; h[k] }
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
      :no_access_list_projects      => "Keine Berechtigung zum Auflisten der Projekte.",
      :no_access_list_topics        => "Keine Berechtigung zum Auflisten der Themen von Projekt %s.",
      :no_access_to_create_project  => "Keine Berechtigung um Projekt %s zu erzeugen.",                
      :no_access_to_destroy_project => "Keine Berechtigung um Projekt %s zu zerstören.",
      :no_access_to_destroy_topic   => "Keine Berechtigung um Thema %s::%s zu zerstören.",
      :no_access_to_read_topic      => "Keine Berechtigung um Thema %s::%s zu lesen.",
      :no_access_to_store_topic     => "Keine Berechtigung um Thema %s::%s zu speichern.",
      :page_not_in_backend_format   => "%s::%s ist in einem von Backend %s nicht unterstütztem Format.",
      :project_already_exists       => "Project %s existiert bereits.",                         
      :project_does_not_exist       => "Project %s existiert nicht.",                         
      :search_project_fail          => "Suche in Projekt %s nach Zeichenkette %s gescheitert.",
      :yaml_requires_182_or_higher  => "YAML-Flatfile-Support existiert nur für Ruby 1.8.2 oder höher.",
                                                                                             
        # Config-related messages.
      :config_not_ruwiki_config     => "Die Konfiguration muss von Typ der Klasse Ruwiki::Config sein.",
      :invalid_template_dir         => "Der angegebene Pfad für Schablonen (%s) existiert nicht oder ist kein Verzeichnis.",
      :no_template_found            => "Keine Schablone %s im Schablonen-Set '%s' gefunden.",
      :no_template_set              => "Es gibt kein Schablonen-Set '%s' im Schablonen-Pfad.",
      :no_webmaster_defined         => "Konfigurations-Fehler: Kein Webmaster definiert.",
        # Miscellaneous messages.
      :complete_utter_failure       => "Fataler Fehler",
      :editing                      => "Editieren",
      :error                        => "Fehler",
      :invalid_path_info_value      => "Fataler Fehler in der Web-Umgebung. PATH_INFO = %s",
        # Should this really get translated?  --chris
      :render_arguments             => "Ruwiki#render muss mit zwei oder mehr Argumenten aufgerufen werden.",
      :unknown_feature              => "Unbekanntes Feature %s.",
      :topics_for_project           => "Themen for Projekt ::%s",                            
      :project_topics_link          => "(Themen)",                                           
      :wiki_projects                => "Projekte in %s",                                     
      :no_projects                  => "Keine Projekte bekannt.",
      :no_topics                    => "Keine Themen in Projekt %s.",                           
      :search_results_for           => "= Suchergebnisse für: %s",                           
      :number_of_hits               => "%d Treffer",                                            

          # Labels
      :label_search_project         => "Durchsuche Projekt",
      :label_search_all             => "Alles",
      :label_search                 => "Suche: ",
      :label_project                => "Projekt: ",
      :label_topic                  => "Thema: ",
      :label_edit                   => "Editieren",
      :label_recent_changes         => "Aktuelle Änderungen",
      :label_topics                 => "Themen",
      :label_projects               => "Projekte",
      :label_editing                => "Editieren",
      :label_text                   => "Text:",
      :label_text_accelerator       => "T",
      :label_edit_comment           => "Anmerkung: ",
      :label_comment_accelerator    => "R",
      :label_save                   => "Speichern",
      :label_save_accelerator       => "S",
      :label_cancel                 => "Abbrechen",
      :label_cancel_accelerator     => "A",
      :label_preview                => "Vorschau",
      :label_preview_accelerator    => "V",
      :label_original_text          => "Ursprüngliche Version",
      :label_raw                    => "Formatfrei",
      :label_formatted              => "Formatiert",
      :label_send_report_by         => "Schicken Sie dem Webmaster einen Report via Email.",
      :label_send_report            => "Report schicken.",
      :label_saved_page             => "Gespeicherte Seite: ",

        # Note to translators: certain words should be left alone. These
        # will be marked in comments. Description lines are restricted to 40
        # characters and should be an array. Use this as a ruler.
        #                           => [ "----------------------------------------" ]
      :converter_usage              => "Benutzung: %1$s [Optionen] <Verzeichnis>+",
      :converter_format_desc        => [ "Konvertiert gefundene Dateien (Jetziges",
                                         "Format egal) in das angegebene Format",
                                         "Standard ist flatfiles. Erlaubte",
                                         "Formate sind:  yaml marshal flatfiles" ],
      :converter_backup_desc        => [ "Erzeugt Backups der aktualisierten",
                                         "Dateien. Standard ist --backup." ],
      :converter_backupext_desc     => [ 'Gibt die Backup-Erweiterung an. Standard',
                                         'ist "~", das dem Datendateinamen',
                                         'angehängt wird.' ],
      :converter_backupext_error    => "Die Backup-Erweiterung darf nicht leer sein.",
      :converter_extension_desc     => [ "Gibt die Erweiterung der Ruwiki-",
                                         "Datendateien an. Standard ist .ruwiki" ],
      :converter_extension_error    => "Die Erweiterung darf nicht leer sein.",
      :converter_noextension_desc   => [ "Gibt an, dass Ruwiki-Datendateien",
                                         "keine Dateierweiterung haben." ],
      :converter_quiet_desc         => [ "Still sein. Standard sind normale",
                                         "Mitteilungen." ],
      :converter_language_desc      => [ "Sprache auf LANG setzen. Standard ist",
                                         "en (Englisch). Bekannte Sprachen sind:",
                                         "en es de" ],
      :converter_verbose_desc       => [ "Gesprächig sein. Standard sind normale",
                                         "Mitteilungen." ],
      :converter_help_desc          => [ "Diesen Text zeigen." ],
      :converter_num_arguments      => "Fehler: Nicht genug Parameter.",
      :converter_directory          => "Verzeichnis",
      :converter_converting_from    => "Wandle von %1$s nach %2$s um... ",
      :converter_done               => "fertig.",
      :converter_not_ruwiki         => "Keine Ruwiki-Datei; übersprungen.",
      :converter_nosave_modified    => "Kann veränderte Datei %1$s nicht speichern.",

        # Messages from Ruwiki::Utils::Manager
      :manager_unknown_command      => "Unbekannter Befehl: %1$s",
      :manager_help_commands        => <<EOH ,
Es gibt diese 'ruwiki'-Befehle:

    ruwiki install              Standard-Entwicklungspaket installieren.
    ruwiki package              Ruwiki-Installation einpacken.
    ruwiki unpackage            Ruwiki-Installation auspacken.
    ruwiki service              Win32::Service für Ruwiki verwalten.

EOH
      :manager_help_help            => <<-EOH ,
Diese Hilfsnachricht zeigt, wie man mehr Informationen zu diesem
Kommandozeilenwerkzeug erhalten kann:

    ruwiki help commands        Alle 'ruwiki' Befehle anzeigen.
    ruwiki help <BEFEHL>        Hilfe zu <BEFEHL> zeigen.
                                  (e.g., 'ruwiki help install')

EOH
      :manager_missing_parameter    => "Fehlender Parameter für Option: %1$s",
      :manager_dest_not_directory   => "Das Ziel (%1$s) ist kein Verzeichnis.",
      :manager_install_help         => <<-EOH ,
    ruwiki install [OPTIONEN] [--to ZIEL]

Erzeugt eine neue Ruwiki-Instanz. Standardmäßig installiert dies die Daten,
Schablonen und eine Standard-Konfigurationsdatei im derzeitigen Verzeichnis.
Das Ziel kann mit --to geändert werden, und was installiert werden soll mit
der OPTIONEN-Liste. Die Elemente der OPTIONEN-Liste dürfen durch Leerzeichen,
Komma oder Semikola getrennt werden.  Daher haben

    ruwiki install data;servlet
    ruwiki install data,servlet
    ruwiki install data servlet

alle die gleiche Wirkung. Die Groß-/Kleinschreibung spielt keine Rolle.
Die OPTIONEN sind:

    servlet       # Den Ruwiki servlet stub installieren
    service       # Den Ruwiki Win32::Service stub installieren
    CGI           # Das Ruwiki CGI-Skript installieren
    data          # Ruwiki-Daten, Schablonen, und Konfiguration installieren

Optionen können durch voranstellen von '-' oder 'no' abgeschaltet werden:

    ruwiki install cgi -data
    ruwiki install cgi nodata

Dies würde das CGI-Skript, nicht aber die Daten installieren.
EOH
      :manager_package_help         => <<-EOH ,
    ruwiki package [QUELL] [--output PAKET] [--replace]
    ruwiki package [QUELL] [-o PAKET] [--replace]

Packt die Ruwiki-Dateien (Daten, Schablonen und Programme) vom angegebenen
QUELL-Verzeichnis oder dem derzeitigen Verzeichnis in das angegebene Paket
(oder "./%1$s"). Sollte QUELL eine Ruwuki-Konfigurationsdatei sein (z.B.
"%2$s"), dann wird sie verwendet, um Ort und Name der Daten- und Schablonen-
Verzeichnisse zu erfahren.

    MERKE: Der Einpack-Prozess normalisiert die Daten- und Schablonen-
           Verzeichnisnamen relativ zum Einpackverzeichnis. Es werden
           niemals absolute Pfade sein.
EOH
      :manager_unpackage_help       => <<-EOH ,
    ruwiki unpackage [QUELL] [--output VERZEICHNIS]
    ruwiki unpackage [QUELL] [-o VERZEICHNIS]

Entpackt das gegebene Rukwiki-Paket (Standard: "./%1$s") in das angebene
Verzeichnis (oder ".").
EOH
      :manager_service_lo_argcount  => "Ungenügene Parameteranzahl: %1$s",
      :manager_service_hi_argcount  => "Zu viele Parameter: %1$s",
      :manager_service_help         => <<-EOH ,
    ruwiki service install NAME [BESCHREIBUNG] [Optionen]
    ruwiki service start   NAME
    ruwiki service stop    NAME
    ruwiki service delete  NAME

Verwaltet das Ruwiki WEBrick servlet als Windows-Service. Der Service muss
benannt (NAME) sein. install unterstützt folgende zusätzliche Optionen:

  --rubybin RUBYPFAD        Der Pfad zum Ruby-Binärverzeichnis.
  --exec    SERVICEPFAD     Der Pfad zum Service-Programm.
  --home    PFADNACHAHAUSE  Der Pfad zum Heimverzeichnis.
EOH
      :manager_package_exists       => "Das Paket %1$s existiert bereits.",
      :manager_service_installed    => "Service %1$s installiert.",
      :manager_one_moment           => "Moment, %1$s ...",
      :manager_service_started      => "Service %1$s gestartet.",
      :manager_service_stopped      => "Service %1$s gestoppt.",
      :manager_service_deleted      => "Service %1$s gelöscht.",

        # Messages from Ruwiki::Utils::Converter
        # Note to translators: certain words should be left alone. These
        # will be marked in comments. Description lines are restricted to 40
        # characters and should be an array. Use this as a ruler.
        #                           => [ "----------------------------------------" ]
      :runner_usage                 => "Verwendung: %1$s [Optionen]",
      :runner_general_options       => "Allgemeine Optionen:",
      :runner_saveconfig_desc       => [ "Sichert die Konfiguration nach FILENAME",
                                         "und beendet. Falls FILENAME nicht",
                                         "gegben ist, wird die Standardkonfig-",
                                         "urationsdatei verwendet. Alle Optionen",
                                         "werden von der bestehenen Konfiguration",
                                         "und der Kommandozeile und gesichert.",
                                         "Das Servlet wird nicht gestartet.",
                                         "Der Standardname ist:" ],
      :runner_config_desc           => [ "Standardkonfiguration von FILENAME",
                                         "statt der Standardkonfigurationsdatei",
                                         "lesen. Optionen die bislang gesetzt",
                                         "wurden werden zu den Werten, die in der",
                                         "Konfigurationsdatei stehen,",
                                         " zurückgesetzt." ],
      :runner_webrick_options       => "WEBrick-Optionen:",
      :runner_port_desc             => [ "Lässt das Ruwiki-Servlet auf dem gegebenen",
                                         "Port laufen. Standard: 8808." ],
      :runner_address_desc          => [ "Schränkt das Ruwiki-Servlet so ein, dass",
                                         "es nur die (Komma-separierten) Adressen",
                                         "akzepiert. Kann mehrfach angegeben werden",
                                         "Standardmäßig wird nicht eingeschränkt." ],
      :runner_local_desc            => [ "Lässt das Ruwiki-Servlet nur lokale",
                                         "Verbindungen akzeptieren (127.0.0.1).",
                                         "Hebt vorige -A Adressen auf." ],
      :runner_mountpoint_desc       => [ "Die relative URI unter der Ruwiki",
                                         'zugreifbar wird. Standard: "/".' ],
      :runner_log_desc              => [ "Protokolliere WEBrick. Standard ist --log." ],
      :runner_logfile_desc          => [ "Die Datei, in die das WEBrick-Protokoll",
                                         "geschrieben wird. Standard: Standard-",
                                         "fehlerausgabe." ],
      :runner_threads_desc          => [ "Setzt den WEBrick-Threadcount." ],
      :runner_ruwiki_options        => "Ruwiki-Optionen:",
      :runner_language_desc         => [ 'Wählt die Oberflächensprache für Ruwiki.',
                                         'Standard: "en". Kann "en", "de", oder',
                                         '"es" sein.' ],
      :runner_webmaster_desc        => [ 'Die Ruwiki-Wwebmaster Email-Adresse.',
                                         'Standard: "webmaster@domain.tld".' ],
      :runner_debug_desc            => [ 'Aktiviert Ruwuki-Debugging. Standard:',
                                         '--no-debug.' ],
      :runner_title_desc            => [ 'Gibt den Ruwiki-Titel an. Standard ist',
                                         '"Ruwiki".' ],
      :runner_defaultpage_desc      => [ 'Eine andere Standardseite. Standard ist',
                                         '"ProjectIndex".' ],
      :runner_defaultproject_desc   => [ 'Eine andere Standardprojektseite.',
                                         'Standard ist "Default".' ],
      :runner_templatepath_desc     => [ 'Ort, an dem Ruwiki-Schablonen sind.',
                                         'Standard ist "./templates".' ],
      :runner_templatename_desc     => [ 'Name der Ruwiki-Schablonen. Default',
                                         'Standard ist "default".' ],
      :runner_cssname_desc          => [ 'Name der CSS-Datei im Schablonenpfad',
                                         'Standard ist "ruwiki.css".' ],
      :runner_storage_desc          => [ 'Wähle den Speichertyp:' ],
      :runner_datapath_desc         => [ 'Ort, an dem Datendateien gespeichert sind.',
                                         'Standard ist "./data".' ],
      :runner_extension_desc        => [ 'Dateierweiterung für Datendateien.',
                                         'Standard ist "ruwiki".' ],
      :runner_gemdata_desc          => [ 'Lässt Ruwiki mit den Daten des Standard-',
                                         'RubyGem-Orts laufen .' ],
      :runner_general_info          => "Allgemeine Information:",
      :runner_help_desc             => [ "Zeigt diesen Text an." ],
      :runner_version_desc          => [ "Zeigt die Ruwuki-Version." ],
      :runner_rejected_address      => "Adresse %1$s abgewiesen. Nur Verbindungen von %2$s werden akzeptiert.",
      :runner_banner                => <<-BANNER ,
%1$s

WEBrick-Optionen:
  Port                  %2$d
  Erlaubte Adressen     %3$s
  Mount Point           %4$s
  Protokollieren?       %5$s
  Protokollpfad         %6$s
  Threads               %7$s

Ruwiki-Options:
  Webmaster             %8$s
  Debugging?            %9$s
  Titel                 %10$s
  Standardprojekt       %11$s
  Standardseite         %12$s
  Schablonenpfad        %13$s
  Schablone             %14$s
  CSS-Datei             %15$s

  Speichertyp           %16$s
  Datenpfad             %17$s
  Dateierweiterung      %18$s
BANNER
    }
    message.each { |k, v| Message[k] = v }
  end
end
