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
class Ruwiki
  class Wiki
      # Produces Lists
    class Calendar < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?%calendar\s*\((?:(today)|(\d+),\s*(\d+))(?:,\s*(#{RE_PROJECT_WORD}))?\)}
      end

      def self.make(year, month)
        result = []
        t = Time.local(year, month, 1)
        r = Array.new(t.wday, nil)
        r << 1

        2.upto(31) do |i|
          break if Time.local(year, month, i).month != month
          r << i
        end

        r += Array.new((- r.size) % 7, nil)

        0.step(r.size - 1, 7) do |i|
          result << r[i, 7]
        end
        result
      end

      def make_month_link(project, year, month, state = nil)
        ym = "%04d%02d" % [year, month]
        case state
        when :prev
          title = "&laquo; #{year}.#{month}"
        when :next
          title = "#{year}.#{month} &raquo;"
        else
          title = "#{project}::#{year}.#{month}"
        end
        url = "#{@script}/#{project}/#{ym}"

        if @backend.page_exists?(ym, project)
          VIEW_LINK % [url, title]
        else
          EDIT_LINK % [title, "#{url}/_edit"]
        end
      end

      def replace
        today   = @match.captures[0]
        project = @match.captures[3] || @project
        now     = Time.now

        if today.nil?
          year  = @match.captures[1].to_i
          month = @match.captures[2].to_i
        else
          year  = now.year
          month = now.month
        end

        if (year == now.year) and (month == now.month)
          show_today = now.day
        else
          show_today = nil
        end

        result = <<-"CALENDAR_HEAD"
</p>
<div class="rw_calendar">
<table class="rw_calendar" summary="calendar for ::#{project}: #{year}.#{month}">
<thead>
        CALENDAR_HEAD

        result << %Q{  <tr>\n<th colspan="7" class="rw_calendar-current-month">}
        result << make_month_link(project, year, month)
        result << %Q{</th>\n  </tr>\n  <tr>\n<th colspan="2" class="rw_calendar-prev-month">}
        result << make_month_link(project, year, month - 1, :prev)
        result << %Q{</th>\n<th colspan="3"></th>\n<th colspan="2" class="rw_calendar-next-month">}
        result << make_month_link(project, year, month + 1, :next)
        result << "</th>\n"

        result << <<-"CALENDAR_HEAD2"
  </tr>
  <tr>
    <th class="rw_calendar-weekend">Su</th>
    <th class="rw_calendar-weekday">Mo</th>
    <th class="rw_calendar-weekday">Tu</th>
    <th class="rw_calendar-weekday">We</th>
    <th class="rw_calendar-weekday">Th</th>
    <th class="rw_calendar-weekday">Fr</th>
    <th class="rw_calendar-weekend">Sa</th>
  </tr>
</thead>
<tbody>
        CALENDAR_HEAD2

        Calendar.make(year, month).each do |week|
          result << "  <tr>\n"
          week.each do |day|
            if day.nil?
              result << %Q{    <td class="rw_calendar-day"></td>\n}
            else
              date = "%04d%02d%02d" % [year, month, day]
                # Add the ability to create pages based on date here.
              if show_today == day
                result << %Q{    <td class="rw_calendar-today">}
              else
                result << %Q{    <td class="rw_calendar-day">}
              end
              if @backend.page_exists?(date, project)
                result << VIEW_LINK % ["#{@script}/#{project}/#{date}", day]
              else
                result << EDIT_LINK % [day, "#{@script}/#{project}/#{date}/_edit"]
              end
              result << %Q{</td>\n}
            end
          end
          result << "  </tr>\n"
        end
        
        result << "</tbody>\n</table>\n</div>\n<p>"
        result
      end

      def restore
        @match[0][1 .. -1]
      end

      def self.post_replace(content)
        content.gsub!(%r{<p>(\s*</?div(?: [^>]+)?>\s*)</p>}, '\1')
        content.gsub!(%r{<p>(\s*</?table(?: [^>]+)?>\s*)</p>}, '\1')
        content.gsub!(%r{<p>(\s*</?t(?:head|body|r)(?: [^>]+)?>\s*)</p>}, '\1')
        content.gsub!(%r{<p>(\s*<t[hd].+?</t[hd]>\s*)</p>}, '\1')
        content
      end
    end
  end
end
