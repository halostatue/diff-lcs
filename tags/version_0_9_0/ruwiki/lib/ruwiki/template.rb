#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# This file is originally from rdoc by Dave Thomas (dave@pragprog.com).
#
# $Id$
#++
require 'cgi'

  # Ruwiki templating, based originally on RDoc's "cheap-n-cheerful" HTML
  # page template system, which is a line-oriented, text-based templating
  # system.
  #
  # Templates can contain:
  # 
  # * The directive !INCLUDE!, which will include the next template from the
  #   provided list. This is processed before any template substitution, so
  #   repeating and optional blocks work on the values within the template
  #   substitution.
  # * Substitutable variable values between percent signs (<tt>%key%</tt>).
  #   Optional variable values can be preceded by a question mark
  #   (<tt>%?key%</tt>).
  # * Label values between hash marks (<tt>#key#</tt>). Optional label
  #   values can be preceded by a question mark (<tt>#?key#</tt>).
  # * Links (<tt>HREF:ref:name:</tt>).
  # * Repeating substitution values (<tt>[:key| stuff :]</tt>). The value of
  #   +key+ may be an integer value or a range (in which case key will be
  #   used as an iterator, providing the current value of key on successive
  #   values), an array of scalar values (substituting each value), or an
  #   array of hashes (in which case it works like repeating blocks, see
  #   below). These must NOT be nested. Note that integer value counting is
  #   one-based.
  # * Optional substitution values (<tt>[?key| stuff ?]</tt> or <tt>[!key|
  #   stuff ?]</tt>. These must NOT be nested.
  # * Repeating blocks:
  #     START:key
  #       ... stuff
  #     END:key
  # * Optional blocks:
  #     IF:key
  #       ... stuff
  #     ENDIF:key
  #   or:
  #     IFNOT:key
  #       ... stuff
  #     ENDIF:key
  #
  # When generating the output, a hash of values is provided and an optional
  # hash of labels is provided. Simple variables are resolved directly from
  # the hash; labels are resolved as Symbols from the label hash or are
  # otherwise treated as variables. Labels are always resolved from a single
  # message hash.
  #
  # The +key+ for repeating blocks (one-line or multi-line) must be an array
  # of hashes. The repeating block will be generated once for each entry.
  # Blocks can be nested arbitrarily deeply.
  #
  # Optional blocks will only be generated if the test is true. IF blocks
  # test for the presence of +key+ or that +key+ is non-+nil+; IFNOT blocks
  # look for the absence or +nil+ value of +key+. IFBLANK blocks test for
  # the absence, +nil+ value, or emptiness of +key+; IFNOTBLANK blocks test
  # for the presence of +key+ and that it is neither +nil+ nor empty.
  #
  # Usage: Given a set of templates <tt>T1</tt>, <tt>T2</tt>, etc.
  #
  #     values = { "name" => "Dave", "state" => "TX" }
  #     fr = { :name => "Nom", :state => "Etat" }
  #     en = { :name => "Name", :state => "State" }
  #     tt = TemplatePage.new(T1, T2, T3)
  #
  #     res = ""
  #     tt.process(res, values, fr)
  #     tt.process(res, values, en)
  #
class Ruwiki::TemplatePage
  BLOCK_RE      = %r{^\s*(IF|IFNOT|IFBLANK|IFNOTBLANK|ENDIF|START|END):(\w+)?}
  HREF_RE       = %r{HREF:(\w+?):(\w+?):}
  LABEL_RE      = %r{#(\??)(-?)(\w+?)#}
  VARIABLE_RE   = %r{%(\??)(-?)(\w+?)%}
  IFLINE_RE     = %r{\[([?!])(\w+?)\|(.*?)\?\]}
  BLOCKLINE_RE  = %r{\[:(\w+?)\|(.*?):\]}
  INCLUDE_RE    = %r{!INCLUDE!}

  DDLB_RES      = [
    [ :check,     %r{%check:(\w+?)%} ], 
    [ :date,      %r{%date:(\w+?)%} ],
    [ :popup,     %r{%popup:(\w+?):(\w+?)%} ],
    [ :ddlb,      %r{%ddlb:(\w+?):(\w+?)%} ],
    [ :vsortddlb, %r{%vsortddlb:(\w+?):(\w+?)%} ],
    [ :radio,     %r{%radio:(\w+?):(\w+?)%} ],
    [ :radioone,  %r{%radioone:(\w+?):(\w+?)%} ],
    [ :input,     %r{%input:(\w+?):(\d+?):(\d+?)%} ],
    [ :text,      %r{%text:(\w+?):(\d+?):(\d+?)%} ],
    [ :pwinput,   %r{%pwinput:(\w+?):(\d+?):(\d+?)%} ],
    [ :pair,      %r{%pair(\d)?:([^:]+)(\w+?)%} ]
  ]

    # Nasty hack to allow folks to insert tags if they really, really want to
  OPEN_TAG      = "\001"
  CLOSE_TAG     = "\002"
  BR            = "#{OPEN_TAG}br#{CLOSE_TAG}"

    # A Context holds a stack of key/value pairs (like a symbol table). When
    # asked to resolve a key, it first searches the top of the stack, then the
    # next level, and so on until it finds a match (or runs out of entries).
  class Context
    def initialize
      @stack = []
    end

    def push(hash)
      @stack.push(hash)
    end

    def pop
      @stack.pop
    end

      # Find a scalar value, throwing an exception if not found. This method is
      # used when substituting the %xxx% constructs
    def find_scalar_raw(key)
      @stack.reverse_each do |level|
        if level.has_key?(key)
          val = level[key]
          return val unless val.kind_of?(Array)
        end
      end
      raise "Template error: can't find variable '#{key}'."
    end

    def find_scalar(key)
      find_scalar_raw(key) || ''
    end

      # Lookup any key in the stack of hashes
    def lookup(key)
      @stack.reverse_each do |level|
        return level[key] if level.has_key?(key)
      end
      nil
    end
  end

    # Simple class to read lines out of a string
  class LineReader
    attr_reader :lines
    def initialize(lines)
      @lines = lines
    end

      # read the next line 
    def read
      @lines.shift
    end

      # Return a list of lines up to the line that matches a pattern. That last
      # line is discarded.
    def read_up_to(pattern)
      res = []
      while line = read
        if pattern.match(line)
          return LineReader.new(res) 
        else
          res << line
        end
      end
      raise "Missing end tag in template: #{pattern.source}"
    end

      # Return a copy of ourselves that can be modified without affecting us
    def dup
      LineReader.new(@lines.dup)
    end
  end

    # +templates+ is an array of strings containing the templates. We start at
    # the first, and substitute in subsequent ones where the string
    # <tt>!INCLUDE!</tt> occurs. For example, we could have the overall page
    # template containing
    #
    #   <html><body>
    #     <h1>Master</h1>
    #     !INCLUDE!
    #   </body></html>
    #
    # and substitute subpages in to it by passing [master, sub_page]. This
    # gives us a cheap way of framing pages
  def initialize(*templates)
    result = templates.shift.dup
    templates.each { |content| result.sub!(INCLUDE_RE, content) }
    @lines = LineReader.new(result.split(/\r?\n/))
  end

  attr_reader :lines

  def set_options(opts = {})
    @message = opts[:messages] || {}
    @output = opts[:output] || $stdout
  end

    # Render templates as HTML. Compatibility method for Rublog and
    # Rdoc.
  def write_html_on(op, value_hash, message_hash = {})
    to_html(value_hash, { :output => op, :messages => message_hash })
  end

    # Render templates as HTML
  def to_html(value_hash, options = {})
    set_options(options)
    esc = proc { |str| CGI.escapeHTML(str) }
    @output << process(value_hash, esc)
  end

    # Render templates as TeX. Compatibility method for Rublog and
    # Rdoc.
  def write_tex_on(op, value_hash, message_hash = {})
    to_tex(value_hash, { :output => op, :messages => message_hash })
  end

    # Render templates as TeX
  def to_tex(value_hash, options = {})
    set_options(options)

    esc = proc do |str|
      str.
        gsub(/&lt;/, '<').
        gsub(/&gt;/, '>').
        gsub(/&amp;/) { '\\&' }.
        gsub(/([$&%\#{}_])/) { "\\#$1" }.
        gsub(/>/, '$>$').
        gsub(/</, '$<$')
    end
    str = ""
    
    str << process(value_hash, esc)
    @output << str
  end

    # Render templates as plain text. Compatibility method for Rublog and
    # Rdoc.
  def write_plain_on(op, value_hash, message_hash = {})
    to_plain(value_hash, { :output => op, :messages => message_hash })
  end

    # Render templates as plain text.
  def to_plain(value_hash, options = {})
    set_options(options)
    esc = proc {|str| str}
    @output << process(value_hash, esc)
  end

    # Render the templates. The The <tt>value_hash</tt> contains key/value
    # pairs used to drive the substitution (as described above). The
    # +escaper+ is a proc which will be used to sanitise the contents of the
    # template.
  def process(value_hash, escaper)
    @context = Context.new
    sub(@lines.dup, value_hash, escaper).
      tr("\000", '\\').
      tr(OPEN_TAG, '<').
      tr(CLOSE_TAG, '>')
  end

    # Substitute a set of key/value pairs into the given template. Keys with
    # scalar values have them substituted directly into the page. Those with
    # array values invoke <tt>substitute_array</tt> (below), which examples a
    # block of the template once for each row in the array.
    #
    # This routine also copes with the <tt>IF:</tt>_key_ directive, removing
    # chunks of the template if the corresponding key does not appear in the
    # hash, and the START: directive, which loops its contents for each value
    # in an array
  def sub(lines, values, escaper)
    @context.push(values)
    skip_to = nil
    result = []

    while line = lines.read
      mv = line.match(BLOCK_RE)

      if mv.nil?
        result << expand(line.dup, escaper)
        next
      else
        cmd = mv.captures[0]
        tag = mv.captures[1]
      end

      case cmd
      when "IF", "IFNOT", "IFNOTBLANK", "IFBLANK"
        raise "#{cmd}: must have a key to test." if tag.nil?

        val  = @context.lookup(tag)
        case cmd  # Skip lines if the value is...
        when "IF"         # false or +nil+ (not false => true)
          test = (not val)
        when "IFBLANK"    # +nil+ or empty
          test = (not (val.nil? or val.empty?))
        when "IFNOT"
          test = val
        when "IFNOTBLANK" #
          test = (val.nil? or val.empty?)
        end
        lines.read_up_to(/^\s*ENDIF:#{tag}/) if test
      when "ENDIF"
        nil
      when "START"
        raise "#{cmd}: must have a key." if tag.nil?

        body = lines.read_up_to(/^\s*END:#{tag}/)
        inner = @context.lookup(tag)
        raise "unknown tag: #{tag}" unless inner
        raise "not array: #{tag}" unless inner.kind_of?(Array)
        inner.each { |vals| result << sub(body.dup, vals, escaper) }
        result << "" # Append the missing \n
      else
        result << expand(line.dup, escaper)
      end
    end

    @context.pop

    result.join("\n")
  end

    # Given an individual line, we look for %xxx%, %?xxx%, #xxx#, #?xxx#,
    # [:key| xxx :], [?key| stuff ?], [!key| stuff ?] and HREF:ref:name:
    # constructs, substituting as appropriate.
  def expand(line, escaper)
      # Generate a cross-reference if a reference is given. Otherwise, just
      # fill in the name part.
    line = line.gsub(HREF_RE) do
      ref = @context.lookup($1)
      name = @context.find_scalar($2)

      if ref and not ref.kind_of?(Array)
        %Q(<a href="#{ref}">#{name}</a>)
      else
        name
      end
    end

      # Look for optional content.
    line = line.gsub(IFLINE_RE) do
      type  = $1
      name  = $2
      stuff = $3

      case type
      when '?'
        test = @context.lookup(name)
      when '!'
        test = (not @context.lookup(name))
      end

      if test
        stuff
      else
        ""
      end
    end

      # Look for repeating content.
    line = line.gsub(BLOCKLINE_RE) do |match|
      name  = $1
      stuff = $2

      val = @context.lookup(name)
      ss = ""
      case val
      when nil
        nil
      when Fixnum
        val.times { |ii| ss << stuff.sub(/%#{name}%/, "#{ii + 1}") }
      when Range
        val.each { |ii| ss << stuff.sub(/%#{name}%/, "#{ii}") }
      when Array
        if not val.empty? and val[0].kind_of?(Hash)
          val.each do |vv|
            @context.push(vv)
            ss << expand(stuff, escaper)
            @context.pop
          end
        else
          val.each { |ee| ss << stuff.sub(/%#{name}%/, "#{ee}") }
        end
      end
      ss
    end

      # Substitute in values for #xxx# constructs.
    line = line.gsub(LABEL_RE) do
      mandatory = $1.nil?
      escaped   = $2.nil?
      key       = $3.intern
      val       = @message[key]

      if val.nil?
        raise "Template error: can't find label '#{key}'." if mandatory
        ""
      else
        val = val.to_s
        val = escaper.call(val) if escaped
        val.tr('\\', "\000")
      end
    end

      # Substitute in values for %xxx% constructs.  This is made complex
      # because the replacement string may contain characters that are
      # meaningful to the regexp (like \1)
    line = line.gsub(VARIABLE_RE) do
      mandatory = $1.nil?
      escaped   = $2.nil?
      key       = $3
      val       = @context.lookup(key)

      if val.nil?
        raise "Template error: can't find variable '#{key}'." if mandatory
        ""
      else
        val = val.to_s
        val = escaper.call(val) if escaped
        val.tr('\\', "\000")
      end
    end

      # Substitute DDLB controls:
    DDLB_RES.each do |ddlb|
      line = line.gsub(ddlb[1]) do
        self.send(ddlb[0], Regexp.last_match.captures)
      end
    end

    line
  rescue Exception => ex
    raise "Error in template: #{ex}\nOriginal line: #{line}\n#{ex.backtrace[0]}"
  end

  def check(*args)
    value = @context.find_scalar_raw(args[0])
    checked = value ? " checked" : ""
    "<input type=\"checkbox\"  name=\"#{name}\"#{checked}>"
  end

  def vsortddlb(*args)
    ddlb(*(args.dup << true))
  end

  def ddlb(*args)
    value   = @context.find_scalar(args[0]).to_s
    options = @context.lookup(args[1])
    sort_on = args[2] || 0

    unless options and options.kind_of?(Hash)
      raise "Missing options #{args[1]} for ddlb #{args[0]}."
    end

    res = %Q(<select name="#{args[0]}">)

    sorted = options.to_a.sort do |aa, bb|
      if aa[0] == -1
        -1
      elsif bb[0] == -1
        1
      else
        aa[sort_on] <=> bb[sort_on]
      end
    end

    sorted.each do |key, val|
      selected = (key.to_s == value) ? " selected" : ""
      res << %Q(<option value="#{key}"#{selected}>#{val}</option>)
    end
    res << "</select>"
  end

  def date(*args)
    yy = "#{argv[0]}_y"
    mm = "#{argv[0]}_m"
    dd = "#{argv[0]}_d"
    %Q<#{input(yy, 4, 4)}&nbsp;.&nbsp;#{input(mm, 2, 2)}&nbsp;.&nbsp;#{input(dd, 2, 2)}>
  end

  def radioone(*args)
    radio(*(args.dup << ""))
  end

  def radio(*args)
    value   = @context.find_scalar(argv[0]).to_s
    options = @context.lookup(argv[1])
    br      = argv[2] || "<br />"

    unless options and options.kind_of?(Hash)
      raise "Missing options #{args[1]} for radio #{args[0]}."
    end

    res = ""
    options.keys.sort.each do |key|
      val = options[key]
      checked = (key.to_s == value) ? " checked" : ""
      res << %Q(<label>
                <input type="radio" name="#{args[0]}"
                       value="#{key}"#{checked}">#{val}</label>#{br})
    end
    res
  end

  def text(*args)
    value = @context.find_scalar(args[0]).to_s
    %Q(<textarea name="#{args[0]}" cols="#{args[1]}" rows="#{args[2]}">
#{CGI.escapeHTML(value)}
</textarea>)
  end

  def pwinput(*args)
    input(*(args.dup << "password"))
  end

  def input(*args)
    name    = args[0]
    value   = @context.find_scalar(name).to_s
    width   = args[1]
    max     = args[2]
    iptype  = args[3] || "text"
    %Q(<input type="#{iptype}" name="#{name}" value="#{value}" size="#{width}" maxsize="#{max}">)
  end

  def popup(*args)
    url  = CGI.escapeHTML(@context.find_scalar(args[0]).to_s)
    text = @context.find_scalar(args[1]).to_s
    %Q|<a href="#{url}" target="Popup" class="methodtitle" onClick="popup('#{url}'); return false;">#{text}</a>|
  end

  def pair(*args)
    label = args[0]
    name  = args[1]
    colsp = args[2]

    value = @context.find_scalar(name).to_s
    value = case value
            when "true" then "Yes"
            when "false" then "No"
            else value
            end
    td = (colsp.nil? or colsp.empty?) ? "<td>" : %Q{<td colspan="#{colsp}">}
    "#{Html.tag(label)}#{td}#{value}</td>"
  end
end
