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

  # == Synopsis
  # Generalises a marshaling format that is easily read and edited by humans
  # and is relatively easy to manage by software. When an attribute is marked
  # #exportable, the name of the attribute is transformed and stored in
  # a two-level hash, e.g.:
  #
  #   exportable_group 'group1'
  #   exportable :var_1
  #   exportable :var_2
  #   exportable_group 'group2'
  #   exportable :var_3
  #   exportable :var_4
  #
  # Results in an exportable hash of:
  #
  #   { 'group1' =>
  #     { 'var-1' => @var1,
  #       'var-2' => @var2, },
  #     'group2' =>
  #     { 'var-3' => @var3,
  #       'var-4' => @var4, }, }
  #
module Ruwiki::Exportable
  class InvalidFormatError < RuntimeError; end

  class << self
      # Adds two methods and an attribute to the class that is including Exportable
      #
      # <tt>__exportables</tt>::    Contains the list of exportable symbols by group.
      # <tt>exportable_group</tt>:: Defines the current group for exportable
      #                             symbols. Default is 'default'.
      # <tt>exportable</tt>::       Accepts two arguments, the attribute being
      #                             exported and an option hash, containing the
      #                             values :name and :group, where :name
      #                             indicates the name of the attribute (so
      #                             that the default name transformation is
      #                             not applied) and :group overrides the
      #                             current #exportable_group. By default, the
      #                             name of the attribute is transformed such
      #                             that underscores are converted to dashes
      #                             (<tt>var_1</tt> becomes 'var-1').
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

      # Looks for comments. Comments may ONLY be on single lines.
    COMMENT_RE  = %r{^#}
      # Looks for newlines
    NL_RE       = %r{\n}
      # Looks for a line that indicates an exportable value. See #dump.
    HEADER_RE   = %r{^([a-z][-a-z]+)!([a-z][-a-z]+):[ \t](.*)$}
      # Looks for an indented group indicating that the last group is
      # a multiline value.
    FIRST_TAB   = %r{^[ \t]}

      # Dumps the provided exportable hash in the form:
      #
      #   section!name:<Tab>Value
      #   section!name:<Space>Value
      #
      # Multiline values are indented either one space or one tab:
      #
      #   section!name:<Tab>Value Line 1
      #   <Tab>Value Line 2
      #   <Tab>Value Line 3
      #   <Tab>Value Line 4
      #
      # All values in the exportable hash are converted to string
      # representations, so only values that can meaningfully be reinstantiated
      # from string representations should be stored in the exportable hash. It
      # is the responsibility of the class preparing the exportable hash
      # through Exportable#export to make the necessary transformations.
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

      # Loads a buffer in the form provided by #dump into an exportable hash.
      # Skips comment lines.
    def load(buffer)
      hash = {}
      return hash if buffer.nil? or buffer.empty?

        # Split the buffer and eliminate comments.
      buffer = buffer.split(NL_RE).delete_if { |line| line =~ COMMENT_RE }

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

    # Converts #exportable attributes to an exportable hash, in the form:
    #   { 'group1' =>
    #     { 'var-1' => @var1,
    #       'var-2' => @var2, },
    #     'group2' =>
    #     { 'var-3' => @var3,
    #       'var-4' => @var4, }, }
    #
    # Classes that #include Exportable are encouraged to override export to
    # ensure safe transformations of values. An example use might be:
    #
    #   class TimeClass
    #     include Ruwiki::Exportable
    #
    #     def export
    #       sym = super
    #
    #       sym['default']['time'] = sym['default']['time'].to_i
    #       sym
    #     end
    #
    # In this way, the 'time' value is converted to an integer rather than the
    # default string representation.
  def export
    sym = {}

    self.class.__exportables.each do |group, gval|
      gname = group || @__exportable_group || 'default'
      gsym = {}
      gval.each do |name, nval|
        val = self.instance_variable_get(nval)
        gsym[name] = val unless val.nil?
      end
      sym[gname] = gsym
    end

    sym
  end
end
