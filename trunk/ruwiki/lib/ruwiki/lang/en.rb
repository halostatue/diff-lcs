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
      :charset_encoding             => "iso-8859-1",
        # Backend-related messages.
      :backend_unknown              => "Backend %s is unknown.",
      :cannot_create_project        => "Cannot create project %s: %s",
      :cannot_destroy_project       => "Cannot destroy project %s: %s",
      :cannot_destroy_topic         => "Cannot destroy %s::%s: %s",
      :cannot_obtain_lock           => "Unable to obtain a lock on %s::%s. Try again shortly.",
      :cannot_release_lock          => "Unable to release the lock on %s::%s. Try again shortly.",
      :cannot_retrieve_topic        => "Cannot retrieve %s::%s: %s",
      :cannot_store_topic           => "Cannot store project %s::%s: %s",
      :error_creating_lock          => "Error creating lock on %s::%s: %s",
      :error_releasing_lock         => "Error releasing lock on %s::%s: %s",
      :flatfiles_no_data_directory  => "The data directory (%s) does not exist.",
      :no_access_to_create_project  => "No permission to create project %s.",
      :no_access_to_destroy_project => "No permission to destroy project %s::%s.",
      :no_access_to_destroy_topic   => "No permission to destroy topic %s::%s.",
      :no_access_to_read_topic      => "No permission to retrieve the %s::%s.",
      :no_access_to_store_topic     => "No permission to store the %s::%s.",
      :project_already_exists       => "Project %s already exists.",
      :project_does_not_exist       => "Project %s does not exist.",
      :no_access_list_projects      => "No permission to list projects.",
      :no_access_list_topics        => "No permission to list topics in project %s.",
      :search_project_fail          => "Failure searching project %s with string %s.",

        # Config-related messages.
      :config_not_ruwiki_config     => "Configuration must be of class Ruwiki::Config.",
      :invalid_template_dir         => "The specified path for templates (%s) does not exist or is not a directory.",
      :no_template_found            => "No template of %s found in template set %s.",
      :no_template_set              => "There is no template set '%s' in the template path.",
      :no_webmaster_defined         => "Configuration error: Webmaster is unset.",
        # Miscellaneous messages.
      :complete_utter_failure       => "Complete and Utter Failure",
      :editing                      => "Editing",
      :error                        => "Error",
      :invalid_path_info_value      => "Something has gone seriously wrong with the web environment. PATH_INFO = %s",
      :render_arguments             => "Ruwiki#render must be called with zero or two arguments.",
      :unknown_feature              => "Unknown feature %s.",
      :topics_for_project           => "Topics for Project ::%s",
      :project_topics_link          => "(topics)",
      :wiki_projects                => "Projects in %s",
      :no_projects                  => "No known projects.",
      :no_topics                    => "No topics in project.",
      :search_results_for           => "= Search results for: %s",
      :number_of_hits               => "%d Hits",

          # Labels
      :label_search_project         => "Search Project",
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
    }
    message.each { |k, v| Message[k] = v }
  end
end
