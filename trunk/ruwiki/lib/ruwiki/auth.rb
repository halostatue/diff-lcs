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
class Ruwiki::Auth
  class << self
    def [](name)
      @delegate ||= {}

      if @delegate.has_key?(name)
        @delegate[name]
      else
        require "ruwiki/auth/#{name}"
        @delegate[name] = Ruwiki::Auth.const_get(name.capitalize)
      end
    end
  end

  class Token
    def initialize(name = nil, groups = [], permissions = {})
      @user_name    = name
      @groups       = groups
      @permissions  = permissions
    end

    def found?
      not @user_name.nil?
    end

    def name
      @user_name
    end

    def member?(unix_group_name)
      @groups.include?(unix_group_name)
    end

    def groups
      @groups
    end

    def allowed?(action)
      @permission[action]
    end

    def permissions
      @permissions
    end
  end
end
