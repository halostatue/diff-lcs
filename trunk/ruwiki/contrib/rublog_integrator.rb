#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

# NOTE: This is not currently compatible with Ruwiki 0.8.0
#
# require 'ruwiki/wiki/handler'

class Ruwiki::RubLogHandler < Ruwiki::Wiki::Handler
  def initialize(entries)
    @entries = entries
  end

  def page_exists?(page, project)
#   puts "pP: #{page}, #{project}"
    matches = @entries.find_entries_with_root_name(page)
    matches.each { |entry| return true if(entry.dir_name =~ /#{project}/) }
    false
  end

  def project_exists?(project)
    true
  end

  def script_url
# request.environment['SCRIPT_NAME']
# !!SMELL!!
    ENV['SCRIPT_NAME']
  end
end

  # An experimental convertor for Ruwiki
class RuwikiConvertor < BaseConvertor
  handles "wiki"

  def get_title(f)
    title = "---Untitled---"
    loop do
      line = f.gets
      if(line =~ /^topic: (\S+)/) then
        title = $1
      elsif(line =~ /^\#EHDR/) then
        return title
      end
    end
  end

  def convert_html(file_entry, f, all_entries)
    title = get_title(f)
    markup = Ruwiki::Wiki.new('Default', Ruwiki::RubLogHandler.new(all_entries))
    body = markup.parse(f.readlines.join("\n"), file_entry.dir_name)
    HTMLEntry.new(title, body, self)
  end

    # FIXME: Need to check this one
  def convert_plain(file_name, f, all_entries)
    f.read
  end
end
