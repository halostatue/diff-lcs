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
class Ruwiki::Handler
  class << self
    # Generate a new Handler pair from a CGI request.
    def from_cgi(cgi, output_stream = $stdout)
      Ruwiki::Handler.new do |o|
        o.request   = Ruwiki::Handler::CGIRequest.new(cgi)
        o.response  = Ruwiki::Handler::CGIResponse.new(cgi, output_stream)
      end
    end

      # Generate a new Handler pair from a WEBrick request.
    def from_webrick(req, res)
      Ruwiki::Handler.new do |o|
        o.request   = Ruwiki::Handler::WEBrickRequest.new(req)
        o.response  = Ruwiki::Handler::WEBrickResponse.new(res)
      end
    end
  end

    # Returns the handler's request object.
  attr_accessor :request
    # Returns the handler's response object.
  attr_accessor :response

    # Creates the handler pair.
  def initialize(&block) #:yields: self
    @request  = nil
    @response = nil
    yield self if block_given?
  end

    # Essentially a clone of WEBrick::Cookie for use with Ruwiki.
  class Cookie
    attr_reader :name
    attr_accessor :value
    attr_accessor :version

    FIELDS = %w(domain path secure comment max_age expires)

    FIELDS.each { |field| attr_accessor field.intern }

    def initialize(name, value)
      @name     = name
      @value    = value
      @version  = 0       # Netscape Cookie

      FIELDS.each { |field| instance_variable_set("@#{field}", nil) }

      yield self if block_given?
    end

    def expires=(t) #:nodoc:
      @expires = t.kind_of?(Time) ? t : Time.parse(t)
    end

    def to_s
      ret = "#{@name}=#{@value}"
      ret << "; Version=#{@version.to_s}"               if @version > 0
      ret << "; Domain=#{@domain}"                      if @domain
      ret << "; Expires=#{CGI::rfc1123_date(@expires)}" if @expires
      ret << "; Max-Age=#{CGI::rfc1123_date(@max_age)}" if @max_age
      ret << "; Comment=#{@comment}"                    if @comment
      ret << "; Path=#{@path}"                          if @path
      ret << "; Secure"                                 if @secure
      ret
    end
  end

    # Represents an abstract incoming request. This insulates the rest of
    # the code from knowing whether parameters are passed as part of the
    # path, as parameters in the URL, or in some other fashion.
  class AbstractRequest
    def initialize(*args)
    end
  end

    # Handles all requests from web applications.
    #
    # Subclasses should provide:
    # @parameters::   Hash-like object that responds to #[] and #hash_key?]
    # @environment::  Hash-like object that responds to #[]
  class AbstractWebRequest < AbstractRequest
    # The parameters provided via the web request.
    attr_reader :parameters
      # The environment provided to the web request.
    attr_reader :environment
      # The request path.
    attr_reader :path

      # The list of cookies.
    attr_reader :cookies

    def each_parameter #:yields parameter, value:
      @parameters.each { |k, v| yield k, v }
    end

    def each_environment #:yields variable, value
      @environment.each { |k, v| yield k, v }
    end

    def each_cookie #:yields name, value:
      @cookies.each { |k, v| yield k, v }
    end

      # Return the URL of our server.
    def server_url
      res = "http://" # should detect whether we're in secure server mode.
      if @environment['HTTP_HOST']
      res << @environment['HTTP_HOST']
      else
        res << "#{@environment['SERVER_NAME']}:#{@environment['SERVER_PORT']}"
      end
    end

      # Return the URL of this script.
    def script_url
      server_url << @environment['SCRIPT_NAME'].to_s
    end

      # Return the URL of this request.
    def request_url
      res = script_url
      res << @environment['PATH_INFO'] if @environment['PATH_INFO']
      query = @environment['QUERY_STRING']
      res << "?#{@environment['QUERY_STRING']}" if query && !query.empty?
      res
    end

      # Convert a file path into a URL
    def make_url(project, path)
      "#{server_url}/#{project}/#{path}"
    end

    def determine_request_path
      @path = ""
      return @path if @environment['PATH_INFO'].nil?
      @path = @environment['PATH_INFO'].dup
    end
  end

    # Request for CGI-based activity to ruwiki.
  class CGIRequest < AbstractWebRequest
    def initialize(cgi, output_stream = $stdout)
      @environment    = ENV
      @cgi            = cgi
      @parameters     = {}
      cgi.params.each { |k, v| @parameters[k] = v[0] }
      @cookies        = {}
      cgi.cookies.each do |name, cookie|
        @cookies[name] = Handler::Cookie.new(name, cookie.value) do |oc|
          oc.version  = cookie.version
          oc.domain   = cookie.domain
          oc.path     = cookie.path
          oc.secure   = cookie.secure
          oc.comment  = cookie.comment
          oc.expires  = cookie.expires
        end
      end
      super
    end
  end

    # Request for WEBrick based servlet activity to ruwiki.
  class WEBrickRequest < AbstractWebRequest
    def initialize(req)
      @environment  = req.meta_vars
      @parameters   = req.query
      @cookies      = {}
      req.cookies.each do |rqc|
        @cookies[name] = Handler::Cookie.new(rqc.name, rqc.value) do |oc|
          oc.version  = cookie.version
          oc.domain   = cookie.domain
          oc.path     = cookie.path
          oc.secure   = cookie.secure
          oc.comment  = cookie.comment
          oc.expires  = cookie.expires
          oc.max_age  = cookie.max_age
        end
      end
      super
    end
  end

    # Used to write responses in different execution environments such as
    # CGI and Webrick.
    #
    # If you want to create a new response object, you'll need to implement
    # #add_header, #write_headers, #write_cookies, and #<<.
    #
    # The Response object is instantiated with an output stream which must
    # supply +<<+ and +puts+ methods.
  class AbstractResponse
    # Add to the list of headers to be sent back to the client.
    def add_header(key, value)
      raise "Not implemented"
    end

        # Write the accumulated headers back to the client.
    def write_headers
      raise "Not implemented"
    end

        # Write the string to the client.
    def <<(string)
      raise "Not implemented"
    end

    def add_cookies(*cookies)
      cookies.each do |cookie|
        @cookies << cookie
      end
    end

    def write_cookies
      raise "Not implemented"
    end

        # output_stream must respond to #<< and #puts.
    def initialize(output_stream = $stdout)
      @headers = {}
      @cookies = []
      @written = false
      @status  = nil
      @output_stream = output_stream
    end

    def written?
      @written
    end
  end

    # CGIResponse is the response object for CGI mode.
  class CGIResponse < AbstractResponse
    # output_stream must respond to #<< and #puts.
    def initialize(cgi, output_stream = $stdout)
      @cgi      = cgi
      @done     = {
        :headers  => false,
        :cookies  => false,
        :body     => false
      }
      super(output_stream)
    end

      # Add the header pair for later output as a CGI header.
    def add_header(key, value)
      @headers[key] = value
    end

      # Write the headers to the stream. The headers can only be written
      # once.
    def write_headers
      return if @done[:headers]
      @headers.each { |key, value| @output_stream.puts "#{key}: #{value}\r\n" }
      write_cookies
      @output_stream.puts
      @done[:headers] = true
    end

      # Write the cookies to the stream. The cookies can only be written
      # once.
    def write_cookies
      return if @done[:cookies]
      @cookies.each do |cookie|
        @output_stream.puts "Set-Cookie: #{cookie.to_s}"
      end
      @done[:cookes] = true
    end

      # Output the string to the stream provided.
    def <<(string)
      @output_stream << string
      @written = true
    end

    def write_status(status)
      unless status.nil?
        @output_stream << status
        @written = true
      end
    end
  end

    # WEBrickResponse is the response object for WEBrick servlet mode.
  class WEBrickResponse < AbstractResponse
    def initialize(webrick_response)
      @response = webrick_response
      @cookies  = []
      @done     = {
        :headers  => false,
        :cookies  => false,
        :body     => false
      }
    end

    def add_header(key, value)
      @response[key] = value
    end

      # Copy the cookies into the WEBrick::HTTPResponse cookies array.
    def write_cookies
      return if @done[:cookies]
      @cookies.each do |cookie|
        @response.cookies << cookie.to_s
      end
      @done[:cookes] = true
    end

    def write_headers
      write_cookies
        # Webrick will take care of this on its own.
    end

    def <<(string)
      @response.body << string.to_s
      @written = true
    end

    def write_status(status)
      unless status.nil?
        match = %r{^HTTP/(?:\d|\.)+ (\d+) .*}.match(status)
        @response.status = match.captures[0]
        @response.body << status
        @written = true
      end
    end
  end
end
