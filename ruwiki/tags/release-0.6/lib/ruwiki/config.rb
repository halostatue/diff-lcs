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
    # Ruwiki configuration.
  class Config
    TEMPLATES = [ :body, :content, :error, :edit, :controls, :save ]

      # Adds additional information to the (rare) error reports. Defaults to
      # +false+.
    attr_accessor :debug
      # The default page for display when Ruwiki is called without any
      # arguments. Defaults to +ProjectIndex+
    attr_accessor :default_page
      # The default project for display when Ruwiki is called without any
      # arguments or a project specification. Defaults to +Default+
    attr_accessor :default_project
      # The storage type as a Symbol. Corresponds to a filename that will be
      # found in ruwiki/backend. In this version of Ruwiki, only flatfiles.rb
      # (e.g., :flatfiles) is defined. Defaults to <tt>:flatfiles</tt>.
    attr_accessor :storage_type
      # The path for flatfile storage. Defaults to <tt>./data/</tt>.
    attr_accessor :data_path
      # The path for templates. Defaults to <tt>./templates/</tt>.
    attr_accessor :template_path
      # The name of the Wiki. Defaults to <tt>ruwiki</tt>
    attr_accessor :title
      # The email address of the webmaster for the Wiki. Defaults to +nil+.
    attr_accessor :webmaster
      # The name of the Ruwiki CSS file. Defaults to <tt>ruwiki.css</tt>.
    attr_accessor :css
      # The template set. Templates are always named as
      # <template_path>/<template_set>/<template_kind>.
      #Template filename. Must be reachable by File#read.
    attr_accessor :template_set

      # Returns the template string
    def template(kind = :body)
      raise ConfigError, "No template for #{kind.inspect} in template set #{@template_set}" unless TEMPLATES.include?(kind)
      File.read(File.join(@template_path, @template_set, "#{kind.to_s}.tmpl"))
    end

      # Returns the CSS stylesheet content for the Wiki. This previously
      # returned the <link> to the stylesheet, but instead returns a <style>
      # block in the head so that the CSS is kept with the template set, which
      # may be kept outside of the HTML area.
    def css_link
      %Q[<style>#{File.read(File.join(@template_path, @template_set, @css))}</style>]
    end

      # Creates a new configuration object.
    def initialize
      @debug            = false
      @default_project  = "Default"
      @default_page     = "ProjectIndex"
      @storage_type     = :flatfiles
      @data_path        = "./data/"
      @template_path    = "./templates/"
      @template_set     = "default"
      @css              = "ruwiki.css"
      @webmaster        = nil
      @title            = "Ruwiki"
    end

      # Verifies that required configuration options are actually set. Right
      # now, it only checks the values that are defaulted to +nil+.
    def verify
      raise ConfigError, "Configuration error: Webmaster is unset." if @webmaster.nil?
    end

    class ConfigError < StandardError #:nodoc:
    end
  end
end
