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

  # Ruwiki templating, based originally on RDoc's "cheap-n-cheerful" HTML page
  # template system, which is a line-oriented, text-based templating system.
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
  # * Label values between hash marks (<tt>#key#</tt>). Optional label values
  #   can be preceded by a question mark (<tt>#?key#</tt>).
  # * Links (<tt>HREF:ref:name:</tt>).
  # * Repeating substitution values (<tt>[:key| stuff :]</tt>). The value of
  #   +key+ may be an integer value or a range (in which case key will be used
  #   as an iterator, providing the current value of key on successive values),
  #   an array of scalar values (substituting each value), or an array of
  #   hashes (in which case it works like repeating blocks, see below). These
  #   must NOT be nested. Note that integer value counting is one-based.
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
  # hash of labels is provided. Simple variables are resolved directly from the
  # hash; labels are resolved as Symbols from the label hash or are otherwise
  # treated as variables. Labels are always resolved from a single label hash.
  #
  # The +key+ for repeating blocks (one-line or multi-line) must be an array of
  # hashes. The repeating block will be generated once for each entry. Blocks
  # can be nested arbitrarily deeply.
  #
  # Optional blocks will only be generated if +key+ has a non-nil value, or if
  # +key+ has a nil value in an IFNOT block.
  #
  # Usage: Given a set of templates <tt>T1</tt>, <tt>T2</tt>, etc.
  #
  #     values = { "name" => "Dave", "state" => "TX" }
  #     fr = { :name => "Nom", :state => "Etat" }
  #     en = { :name => "Name", :state => "State" }
  #     t = TemplatePage.new(T1, T2, T3)
  #
  #     res = ""
  #     t.process(res, values, fr)
  #     t.process(res, values, en)
  #
class Ruwiki::TemplatePage
  BLOCK_RE      = /^(IF|IFNOT|ENDIF|START|END):(\w+)?/
  HREF_RE       = /HREF:(\w+?):(\w+?):/
  LABEL_RE      = /#(\?)?(\w+?)#/
  VARIABLE_RE   = /%(\?)?(\w+?)%/
  IFLINE_RE     = /\[([?!])(\w+?)\|(.*?)\?\]/
  BLOCKLINE_RE  = /\[:(\w+?)\|(.*?):\]/

    # A context holds a stack of key/value pairs (like a symbol table). When
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
    def find_scalar(key)
      @stack.reverse_each do |level|
        return level[key] unless level[key].kind_of?(Array)
      end
      raise "Template error: can't find variable '#{key}'."
    end

      # Lookup any key in the stack of hashes
    def lookup(key)
      @stack.reverse_each do |level|
        return level[key] unless level[key].nil?
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
    result = "!INCLUDE!"
    templates.each { |content| result.sub!(/!INCLUDE!/, content) }
    @lines = LineReader.new(result.split(/\r?\n/))
  end

  attr_reader :lines

    # Render the templates, storing the result on +output+ using the method
    # <tt><<</tt> The <tt>value_hash</tt> contains key/value pairs used to
    # drive the substitution (as described above). The <tt>label_hash</tt>
    # contains key/value pairs used to drive the substitution of labels (see
    # above).
  def process(output, value_hash, message_hash = {})
    @context = Context.new
    @message = message_hash
    output << sub(@lines.dup, value_hash).tr("\000", '\\')
    output
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
  def sub(lines, values)
    @context.push(values)
    skip_to = nil
    result = []

    while line = lines.read
      mv = line.match(BLOCK_RE)

      if mv.nil?
        result << expand(line.dup)
        next
      else
        cmd = mv.captures[0]
        tag = mv.captures[1]
      end

      case cmd
      when "IF", "IFNOT"
        raise "#{cmd}: must have a key to test." if tag.nil?

        test = @context.lookup(tag).nil?
        test = (cmd == "IF") ? test : (not test)
        lines.read_up_to(/^ENDIF:#{tag}/) if test
      when "ENDIF"
        nil
      when "START"
        raise "#{cmd}: must have a key." if tag.nil?

        body = lines.read_up_to(/^END:#{tag}/)
        inner = @context.lookup(tag)
        raise "unknown tag: #{tag}" unless inner
        raise "not array: #{tag}" unless inner.kind_of?(Array)
        inner.each { |vals| result << sub(body.dup, vals) }
        result << "" # Append the missing \n
      else
        result << expand(line.dup)
      end
    end

    @context.pop

    result.join("\n")
  end

    # Given an individual line, we look for %xxx%, %?xxx%, #xxx#, #?xxx#,
    # [:key| xxx :], [?key| stuff ?], [!key| stuff ?] and HREF:ref:name:
    # constructs, substituting as appropriate.
  def expand(line)
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
      s = ""
      case val
      when nil
        nil
      when Fixnum
        val.times { |i| s << stuff.sub(/%#{name}%/, "#{i + 1}") }
      when Range
        val.each { |i| s << stuff.sub(/%#{name}%/, "#{i}") }
      when Array
        if not val.empty? and val[0].kind_of?(Hash)
          val.each do |v|
            @context.push(v)
            s << expand(stuff)
            @context.pop
          end
        else
          val.each { |e| s << stuff.sub(/%#{name}%/, "#{e}") }
        end
      end
      s
    end

      # Substitute in values for #xxx# constructs.
    line = line.gsub(LABEL_RE) do
      mandatory = $1.nil?
      key = $2.intern
      val = @message[key]

      if val.nil?
        raise "Template error: can't find label '#{key}'." if mandatory
        ""
      else
        "#{val}".tr('\\', "\000")
      end
    end

      # Substitute in values for %xxx% constructs.  This is made complex
      # because the replacement string may contain characters that are
      # meaningful to the regexp (like \1)
    line = line.gsub(VARIABLE_RE) do
      mandatory = $1.nil?
      key = $2
      val = @context.lookup(key)

      if val.nil?
        raise "Template error: can't find variable '#{key}'." if mandatory
        ""
      else
        "#{val}".tr('\\', "\000")
      end
    end

    line
  rescue Exception => e
    raise "Error in template: #{e}\nOriginal line: #{line}\n#{e.backtrace[0]}"
  end
end
