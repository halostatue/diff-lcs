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
  class << self
    def append_features(mod)
      super

      class << mod
        attr_reader :__exportables

        define_method(:exportable_group) do |name|
          @__exportable_group = name
        end

        define_method(:exportable) do |*symset|
          symbol = symset.shift
          options = symset.shift || {}

          @__exportables ||= {}

          options[:name]  ||= symbol.to_s.gsub(/_/, '-')
          options[:group] ||= @__exportable_group

          @__exportables[options[:group]] ||= {}
          @__exportables[options[:group]][options[:name]] = [
            "@#{symbol.to_s}".intern, options[:transforms]
          ]
        end
      end
    end
  end

  def export
    sym = {}

    self.class.__exportables.each do |group, gval|
      gname = group || @__exportable_group
      gsym = {}

      gval.each do |name, nval|
        val = self.instance_variable_get(nval[0])
        unless nval[1].nil?
          if nval[1].kind_of?(Symbol)
            val = val.send(nval[1])
          elsif nval[1].kind_of?(Array)
            nval[1].each { |transform| val = val.send(transform) }
          end
        end

        gsym[name] = val
      end

      if gname.nil?
        sym.merge!(gsym)
      else
        sym[gname] = gsym
      end
    end

    sym
  end
end
