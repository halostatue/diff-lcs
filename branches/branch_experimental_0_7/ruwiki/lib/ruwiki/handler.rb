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
class Ruwiki
  class Handler
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

      # REpresents an abstract incoming request. This insulates the rest of
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

        # Yields each parameter key in succession.
      def each_parameter #:yields: key, value
        @parameters.each { |k, v| yield k, v }
      end

      def each_environment #:yields: key, value
        @environment.each { |k, v| yield k, v }
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
        super
      end
    end

      # Request for WEBrick based servlet activity to ruwiki.
    class WEBrickRequest < AbstractWebRequest
      def initialize(req)
        @environment  = req.meta_vars
        @parameters   = req.query
        super
      end
    end

      # Used to write responses in different execution environments such as
      # CGI and Webrick.
      #
      # If you want to create a new response object, you'll need to implement
      # #add_header, #write_headers, and #<<.
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

        # output_stream must respond to #<< and #puts.
      def initialize(output_stream = $stdout)
        @headers = {}
        @output_stream = output_stream
      end
    end

      # CGIResponse is the response object for CGI mode.
    class CGIResponse < AbstractResponse
        # output_stream must respond to #<< and #puts.
      def initialize(cgi, output_stream = $stdout)
        @cgi = cgi
        super(output_stream)
      end

        # Add the header pair for later output as a CGI header.
      def add_header(key, value)
        @headers[key] = value
      end

        # Write the headers to the stream. The headers can only be written
        # once.
      def write_headers
        return if @written
        @headers.each { |key, value| @output_stream.puts "#{key}: #{value}\r\n" }
        @output_stream.puts
        @written = true
      end

        # Output the string to the stream provided.
      def <<(string)
        @output_stream << string
      end
    end

      # WEBrickResponse is the response object for WEBrick servlet mode.
    class WEBrickResponse < AbstractResponse
      def initialize(webrick_response)
        @response = webrick_response
      end

      def add_header(key,value)
        @response[key] = value
      end

      def write_headers
        # Webrick will take care of this on its own.
      end

      def <<(string)
        @response.body << string
      end
    end
  end
end
