#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
class Ruwiki
  module Lang
      # Ruwiki::Lang::EN is the English-language output module. It contains a
      # hash, *Message*, that contains the messages that may be reported by
      # any method in the Ruwiki library. The messages are identified by a
      # Symbol.
    module EN
      Message = {
        :backend_cannot_obtain_lock   => "Unable to obtain a lock on project [%s] topic %s. Try again later.",
        :backend_cannot_release_lock  => "Unable to release the lock on project [%s] topic %s. Try again later.",
        :backend_no_access_create     => "No access to create project.",
        :backend_no_access_dproject   => "No access to destroy project.",
        :backend_no_access_dtopic     => "No access to destroy topic.",
        :backend_no_access_read       => "No access to retrieve the topic.",
        :backend_no_access_store      => "No access to store the topic.",
        :cannot_create_project        => "Cannot create project [%s]: %s",
        :cannot_destroy_project       => "Cannot destroy project [%s]: %s",
        :cannot_destroy_topic         => "Cannot destroy project [%s] topic [%s]%s: %s",
        :cannot_retrieve_topic        => "Cannot retrieve project [%s] topic [%s]%s: %s",
        :cannot_store_topic           => "Cannot store project [%s] topic [%s]%s: %s",
        :complete_utter_failure       => "Complete and Utter Failure",
        :config_not_ruwiki_config     => "Configuration must be of class Ruwiki::Config.",
        :editing                      => "Editing",
        :error                        => "Error",
        :error_creating_lock          => "Error creating lock on project [%s] topic [%s]%s: %s",
        :error_releasing_lock         => "Error releasing lock on project [%s] topic [%s]%s: %s",
        :file                         => "File",
        :invalid_template_dir         => "The specified path for templates (%s) does not exist or is not a directory.",
        :invalid_path_info_value      => "Something has gone seriously wrong with the web environment. PATH_INFO = %s",
        :no_data_directory            => "The data directory (%s) does not exist",
        :no_template_found            => "No template of %s found in template set %s.",
        :no_template_set              => "There is no template set '%s' in the template path.",
        :no_webmaster_defined         => "Configuration error: Webmaster is unset.",
        :project_already_exists       => "Project %s already exists.",
        :project_does_not_exist       => "Project %s does not exist.",
        :render_arguments             => "Ruwiki#render must be called with zero or two arguments.",
        :unknown_backend              => "Unknown backend %s.",
        :unknown_feature              => "Unknown feature %s."
      }
    end
  end
end
