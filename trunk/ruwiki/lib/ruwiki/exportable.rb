#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

  # Adds a class method to mark methods exportable.
module Ruwiki::Exportable
  class InvalidFormatError < RuntimeError; end

  class << self
    def append_features(mod)
      super

      class << mod
        attr_reader :__exportables

        define_method(:exportable_group) do |name|
          @__exportable_group = name || 'default'
        end

        define_method(:exportable) do |*symset|
          symbol = symset.shift
          options = symset.shift || {}

          @__exportables ||= {}

          options[:name]  ||= symbol.to_s.gsub(/_/, '-')
          options[:group] ||= @__exportable_group || 'default'

          @__exportables[options[:group]] ||= {}
          @__exportables[options[:group]][options[:name]] = "@#{symbol.to_s}".intern
        end
      end
    end

    NL_RE     = /\n/
    HEADER_RE = /^([a-z][-a-z]+)!([a-z][-a-z]+):\t(.*)$/
    FIRST_TAB = /^\t/


    def dump(export_hash)
      dumpstr = ""

      export_hash.keys.sort.each do |sect|
        export_hash[sect].keys.sort.each do |item|
          val = export_hash[sect][item].to_s.split(NL_RE).join("\n\t")
          dumpstr << "#{sect}!#{item}:\t#{val}\n"
        end
      end

      dumpstr
    end

    def load(buffer)
      hash = {}
      return hash if buffer.empty?

      buffer = buffer.split(NL_RE)

      if HEADER_RE.match(buffer[0]).nil?
        raise Ruwiki::Exportable::InvalidFormatError
      end

      sect = item = nil
      
      buffer.each do |line|
        line.chomp!
        match = HEADER_RE.match(line)

          # If there is no match, add the current line to the previous match.
          # Remove the leading \t, though.
        if match.nil?
          raise Ruwiki::Exportable::InvalidFormatError if FIRST_TAB.match(line).nil?
          hash[sect][item] << "\n#{line.gsub(FIRST_TAB, '')}"
        else
          sect              = match.captures[0]
          item              = match.captures[1]
          hash[sect]      ||= {}
          hash[sect][item]  = match.captures[2]
        end
      end

      hash
    end
  end

  def export
    sym = {}

    self.class.__exportables.each do |group, gval|
      gname = group || @__exportable_group || 'default'
      gsym = {}
      gval.each { |name, nval| gsym[name] = self.instance_variable_get(nval) }
      sym[gname] = gsym
    end

    sym
  end
end
