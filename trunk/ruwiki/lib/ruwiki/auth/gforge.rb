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

begin
  require 'gforge_auth'
rescue LoadError
  class GForgeAuthenticator
    class AuthenticationResult
      def initialize(name = nil, groups = [])
        @user_name  = name
        @groups     = groups
      end

      def found?
        not @user_name.nil?
      end

      def user_name
        raise "No session associated with the given key was found" unless found?
        @user_name
      end

      def member?(unix_group_name)
        raise "No session associated with the given key was found" unless found?
        @groups.include?(unix_group_name) 
      end

      def groups
        raise "No session associated with the given key was found" unless found?
        @groups
      end
    end

    def self.authenticate(sessionkey, options = {})
      sql = %Q(SELECT user_name FROM users u, user_session us WHERE us.session_hash = '#{sessionkey}' AND us.user_id = u.user_id;)
      res = %x{psql -q -t -U #{options['user']} #{options['pass']} -c \"#{sql}\"}
      rows = res.split(/\n/)
      return AuthenticationResult.new if rows.size != 1

      user_name = rows[0].strip
      sql       = %Q(SELECT unix_group_name FROM groups g, users u, user_group ug WHERE u.user_user_name = #{user_name} AND ug.user_id = u.user_id AND g.group_id = ug.group_id)

      res       = %x(psql -q -t -U #{options['user']} #{options['pass']} -c \"#{sql}\")
      groups    = []
      res.split(/\n/).each {|row| groups << row.strip }
      AuthenticationResult.new(user_name, groups)
    end
  end
end

class Ruwiki::Auth::Gforge < Ruwiki::Auth
  def self.authenticate(request, response, options = {})
    options['user'] = options['user'].gsub!(%r{^(\w+)}, '\1')
    options['pass'] = options['pass'].gsub!(%r{^(\w+)}, '\1')
    session_key = request.cookies['session_ser'].value[0].split(%r{=-\*-})[-1]
    $stderr.puts session_key.inspect
    token = GForgeAuthenticator.authenticate(session_key, options)
    token = Ruwiki::Auth::Token.new(token.user_name, token.groups)
    token.permissions.default = true if token.found?
  rescue
    token = Ruwiki::Auth::Token.new
    token.permissions.default = false
  ensure
    return token
  end
end
