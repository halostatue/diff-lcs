#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
module Ruwiki::Lang
    # Ruwiki::Lang::EN is the English-language output module. It contains a
    # hash, *Message*, that contains the messages that may be reported by
    # any method in the Ruwiki library. The messages are identified by a
    # Symbol.
  module EN
    Message = Hash.new { |h, k| h[k] = "Language ERROR: Unknown message key #{k.inspect}."; h[k] }
    message = {
        # The encoding for the webpages. This should match the encoding used
        # to create these messages.
      :charset_encoding             => "iso-8859-15",
        # Backend-related messages.
      :backend_unknown              => "Backend %1$s is unknown.",
      :cannot_create_project        => "Cannot create project %1$s: %2$s",
      :cannot_destroy_project       => "Cannot destroy project %1$s: %2$s",
      :cannot_destroy_topic         => "Cannot destroy %1$s::%2$s: %3$s",
      :cannot_obtain_lock           => "Unable to obtain a lock on %1$s::%2$s. Try again shortly.",
      :cannot_release_lock          => "Unable to release the lock on %1$s::%2$s. Try again shortly.",
      :cannot_retrieve_topic        => "Cannot retrieve %1$s::%2$s: %3$s",
      :cannot_store_topic           => "Cannot store %1$s::%2$s: %3$s",
      :cannot_list_topics           => "Cannot list topics for project %1$s: %2$s",
      :error_creating_lock          => "Error creating lock on %1$s::%2$s: %3$s",
      :error_releasing_lock         => "Error releasing lock on %1$s::%2$s: %3$s",
      :flatfiles_no_data_directory  => "The data directory (%1$s) does not exist.",
      :no_access_list_projects      => "No permission to list projects.",
      :no_access_list_topics        => "No permission to list topics in project %1$s.",
      :no_access_to_create_project  => "No permission to create project %1$s.",
      :no_access_to_destroy_project => "No permission to destroy project %1$s::%2$s.",
      :no_access_to_destroy_topic   => "No permission to destroy topic %1$s::%2$s.",
      :no_access_to_read_topic      => "No permission to retrieve the %1$s::%2$s.",
      :no_access_to_store_topic     => "No permission to store the %1$s::%2$s.",
      :page_not_in_backend_format   => "%1$s::%2$s is not in the format supported by the backend %3$s.",
      :project_already_exists       => "Project %1$s already exists.",
      :project_does_not_exist       => "Project %1$s does not exist.",
      :search_project_fail          => "Failure searching project %1$s with string %2$s.",
      :yaml_requires_182_or_higher  => "YAML flatfile support exists only for Ruby version 1.8.2 or higher.",
      :not_editing_current_version  => <<EOM ,
You have submitted an old version of %1$s::%2$s. The differences between
your version and the current version of this page have been merged.
Conflicting lines have both lines shown. Please ensure that you have edited
the entire page before saving again.
EOM

        # Config-related messages.
      :config_not_ruwiki_config     => "Configuration must be of class Ruwiki::Config.",
      :invalid_template_dir         => "The specified path for templates (%1$s) does not exist or is not a directory.",
      :no_template_found            => "No template of %1$s found in template set %2$s.",
      :no_template_set              => "There is no template set '%1$s' in the template path.",
      :no_webmaster_defined         => "Configuration error: Webmaster is unset.",
        # Miscellaneous messages.
      :complete_utter_failure       => "Complete and Utter Failure",
      :editing                      => "Editing",
      :error                        => "Error",
      :invalid_path_info_value      => "Something has gone seriously wrong with the web environment. PATH_INFO = %1$s",
      :render_arguments             => "Ruwiki#render must be called with zero or two arguments.",
      :unknown_feature              => "Unknown feature %1$s.",
      :topics_for_project           => "Topics for Project ::%1$s",
      :project_topics_link          => "(topics)",
      :wiki_projects                => "Projects in %1$s",
      :no_projects                  => "No known projects.",
      :no_topics                    => "No topics in project %1$s.",
      :search_results_for           => "= Search results for: %1$s",
      :number_of_hits               => "%1$d Hits",

          # Labels
      :label_search_project         => "Search Project",
      :label_search_all             => "All",
      :label_search                 => "Search: ",
      :label_project                => "Project: ",
      :label_topic                  => "Topic: ",
      :label_edit                   => "Edit",
      :label_recent_changes         => "Recent Changes",
      :label_topics                 => "Topics",
      :label_projects               => "Projects",
      :label_editing                => "Editing",
      :label_text                   => "Text:",
      :label_text_accelerator       => "T",
      :label_edit_comment           => "Edit Comment: ",
      :label_comment_accelerator    => "O",
      :label_save                   => "Save",
      :label_save_accelerator       => "S",
      :label_cancel                 => "Cancel",
      :label_cancel_accelerator     => "C",
      :label_preview                => "Preview",
      :label_preview_accelerator    => "P",
      :label_original_text          => "Original Text",
      :label_raw                    => "Raw",
      :label_formatted              => "Formatted",
      :label_send_report_by         => "Send the Wiki maintainer a report by email.",
      :label_send_report            => "Send report.",
      :label_saved_page             => "Saved page: ",

        # Messages from Ruwiki::Utils::Converter
        # Note to translators: certain words should be left alone. These
        # will be marked in comments. Description lines are restricted to 40
        # characters and should be an array. Use this as a ruler.
        #                           => [ "----------------------------------------" ]
      :converter_usage              => "Usage: %1$s [options] <directory>+",
      :converter_format_desc        => [ "Converts encountered files (regardless",
                                         "of the current format), to the specified",
                                         "format. Default is flatfiles. Allowed",
                                         "formats are:  yaml marshal flatfiles" ],
      :converter_backup_desc        => [ "Create backups of upgraded files.",
                                         "Default is --backup." ],
      :converter_backupext_desc     => [ 'Specify the backup extension. Default',
                                         'is "~", which is appended to the data',
                                         'filename.' ],
      :converter_backupext_error    => "The backup extension must not be empty.",
      :converter_extension_desc     => [ "Specifies the extension of Ruwiki data",
                                         "files. The default is .ruwiki" ],
      :converter_extension_error    => "The extension must not be empty.",
      :converter_noextension_desc   => [ "Indicates that the Ruwiki data files",
                                         "have no extension." ],
      :converter_quiet_desc         => [ "Runs quietly. Default is to run with",
                                         "normal messages." ],
      :converter_language_desc      => [ "Sets the language to LANG. Defaults",
                                         "to en (English). Known languages",
                                         "are: en es de" ],
      :converter_verbose_desc       => [ "Runs with full message. Default is to",
                                         "run with normal messages." ],
      :converter_help_desc          => [ "Shows this text." ],
      :converter_num_arguments      => "Error: not enough arguments.",
      :converter_directory          => "directory",
      :converter_converting_from    => "converting from %1$s to %2$s ... ",
      :converter_done               => "done.",
      :converter_not_ruwiki         => "not a Ruwiki file; skipping.",
      :converter_nosave_modified    => "cannot save modified %1$s.",
      :converter_page_format_error  => "Error: Cannot detect the page format.",

        # Messages from Ruwiki::Utils::Manager
      :manager_unknown_command      => "Unknown command: %1$s",
      :manager_help_commands        => <<EOH ,
The commands known to 'ruwiki' are:

    ruwiki install              Installs the default deployment package.
    ruwiki package              Packages a Ruwiki installation.
    ruwiki unpackage            Unpackages a Ruwiki installation.
    ruwiki service              Manages a Win32::Service for Ruwiki.

EOH
      :manager_help_help            => <<-EOH ,
This is a basic help message containing pointers to more information on how
to use this command-line tool. Try:

    ruwiki help commands        list all 'ruwiki' commands
    ruwiki help <COMMAND>       show help on <COMMAND>
                                  (e.g., 'ruwiki help install')

EOH
      :manager_missing_parameter    => "Missing parameter for option: %1$s",
      :manager_dest_not_directory   => "The destination (%1$s) is not a directory.",
      :manager_install_help         => <<-EOH ,
    ruwiki install [OPTIONS] [--to DEST]

Creates a new Ruwiki instance. By default this installs the data, templates,
and a default configuration file to the current directory. The destination
can be changed with the --to option, and what is installed can be specified
with the OPTIONS list. The OPTIONS list may be space, comma, or semi-colon
separated. Thus,

    ruwiki install data;servlet
    ruwiki install data,servlet
    ruwiki install data servlet

are all equivalent. The options may be specified in any case. The
installation OPTIONS are:

    servlet       # Installs the Ruwiki servlet stub
    service       # Installs the Ruwiki Win32::Service stub
    CGI           # Installs the Ruwiki CGI script
    data          # Installs the Ruwiki data, templates, and configuration

Options may be disabled with by prepending a dash or 'no':

    ruwiki install cgi -data
    ruwiki install cgi nodata

These will install the CGI script but not the data.
EOH
      :manager_package_help         => <<-EOH ,
    ruwiki package [SOURCE] [--output PACKAGE] [--replace]
    ruwiki package [SOURCE] [-o PACKAGE] [--replace]

Packages the Ruwiki files (data, templates, and executables) from the
specified SOURCE or the current directory into the specified output package
(or "./%1$s"). If the SOURCE is a ruwiki configuration file (e.g.,
"%2$s"), then that will be used to determine the location and name of
the data and template directories.

    NOTE: The packaging process will normalize the data and templates
          directory names to be relative to the unpacking directory. They
          will NEVER be absolute paths.
EOH
      :manager_unpackage_help       => <<-EOH ,
    ruwiki unpackage [SOURCE] [--output DIRECTORY]
    ruwiki unpackage [SOURCE] [-o DIRECTORY]

Unpackages the provided Ruwiki package (default "./%1$s") into the
specified directory (default ".").
EOH
      :manager_service_broken       => "Cannot manage a Win32 service if Win32::Service is not installed.", 
      :manager_service_lo_argcount  => "Insufficient arguments: %1$s",
      :manager_service_hi_argcount  => "Too many arguments: %1$s",
      :manager_service_help         => <<-EOH ,
    ruwiki service install NAME [DESCRIPTION] [options]
    ruwiki service start   NAME
    ruwiki service stop    NAME
    ruwiki service delete  NAME

Manages the Ruwiki WEBrick servlet as a Windows service. The service must be
NAMEd. install supports the following additional options:

  --rubybin RUBYPATH      The path to the Ruby binary.
  --exec    SERVICEPATH   The path to the service executable.
  --home    PATHTOHOME    The path to the home directory.
EOH
      :manager_package_exists       => "Package %1$s already exists.",
      :manager_service_installed    => "%1$s service installed.",
      :manager_one_moment           => "One moment, %1$s ...",
      :manager_service_started      => "%1$s service started.",
      :manager_service_stopped      => "%1$s service stopped.",
      :manager_service_deleted      => "%1$s service deleted.",

        # Messages from Ruwiki::Utils::Converter
        # Note to translators: certain words should be left alone. These
        # will be marked in comments. Description lines are restricted to 40
        # characters and should be an array. Use this as a ruler.
        #                           => [ "----------------------------------------" ]
      :runner_usage                 => "Usage: %1$s [options]",
      :runner_general_options       => "General options:",
      :runner_saveconfig_desc       => [ "Saves the configuration to FILENAME and",
                                         "exit. If FILENAME is not used, then the",
                                         "default configuration file will be",
                                         "used. All options will be read from the",
                                         "existing configuration file and the",
                                         "command-line and saved. The servlet",
                                         "will not start. The default name is:" ],
      :runner_config_desc           => [ "Read the default configuration from",
                                         "FILENAME instead of the default config",
                                         "file. Options set until this point will",
                                         "be reset to the values from those read",
                                         "configuration file." ],
      :runner_webrick_options       => "WEBrick options:",
      :runner_port_desc             => [ "Runs the Ruwiki servlet on the specified",
                                         "port. Default 8808." ],
      :runner_address_desc          => [ "Restricts the Ruwiki servlet to accepting",
                                         "connections from the specified address or",
                                         "(comma-separated) addresses. May be",
                                         "specified multiple times. Defaults to all",
                                         "addresses." ],
      :runner_local_desc            => [ "Restricts the Ruwiki servlet to accepting",
                                         "only local connections (127.0.0.1).",
                                         "Overrides any previous -A addresses." ],
      :runner_mountpoint_desc       => [ "The relative URI from which Ruwiki will",
                                         'be accessible. Defaults to "/".' ],
      :runner_log_desc              => [ "Log WEBrick activity. Default is --log." ],
      :runner_logfile_desc          => [ "The file to which WEBrick logs are",
                                         "written. Default is standard error." ],
      :runner_threads_desc          => [ "Sets the WEBrick threadcount." ],
      :runner_ruwiki_options        => "Ruwiki options:",
      :runner_language_desc         => [ 'The interface language for Ruwiki.',
                                         'Defaults to "en". May be "en", "de", or',
                                         '"es".' ],
      :runner_webmaster_desc        => [ 'The Ruwiki webmaster email address.',
                                         'Defaults to "webmaster@domain.tld".' ],
      :runner_debug_desc            => [ 'Turns on Ruwiki debugging. Defaults',
                                         'to --no-debug.' ],
      :runner_title_desc            => [ 'Provides the Ruwiki title. Default is',
                                         '"Ruwiki".' ],
      :runner_defaultpage_desc      => [ 'An alternate default page. Default is',
                                         '"ProjectIndex".' ],
      :runner_defaultproject_desc   => [ 'An alternate default project. Default is',
                                         '"Default".' ],
      :runner_templatepath_desc     => [ 'The location of Ruwiki templates. Default',
                                         'is "./templates".' ],
      :runner_templatename_desc     => [ 'The name of the Ruwiki templates. Default',
                                         'is "default".' ],
      :runner_cssname_desc          => [ 'The name of the CSS file in the template',
                                         'path. Default is "ruwiki.css".' ],
      :runner_storage_desc          => [ 'Select the storage type:' ],
      :runner_datapath_desc         => [ 'The path where data files are stored.',
                                         'Default is "./data".' ],
      :runner_extension_desc        => [ 'The extension for data files.',
                                         'Default is "ruwiki".' ],
      :runner_central_desc          => [ 'Runs Ruwiki with the data in the default',
                                         'RubyGem location.' ],
      :runner_general_info          => "General info:",
      :runner_help_desc             => [ "Shows this text." ],
      :runner_version_desc          => [ "Shows the version of Ruwiki." ],
      :runner_rejected_address      => "Rejected peer address %1$s. Connections are only accepted from %2$s.",
      :runner_banner                => <<-BANNER ,
%1$s

WEBrick options:
  Port                  %2$d
  Accepted Addresses    %3$s
  Mount Point           %4$s
  Logging?              %5$s
  Log Destination       %6$s
  Threads               %7$s

Ruwiki options:
  Webmaster             %8$s
  Debugging?            %9$s
  Title                 %10$s
  Default Project       %11$s
  Default Page          %12$s
  Template Path         %13$s
  Template Set          %14$s
  CSS Source            %15$s

  Storage Type          %16$s
  Data Path             %17$s
  Extension             %18$s
BANNER
    }
    message.each { |k, v| Message[k] = v }
  end
end
