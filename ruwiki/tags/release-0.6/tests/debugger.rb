require 'ruwiki/config'

require 'rw_config.rb'

module Markup_Debug
  def projectlist
  end

  def pagelist
  end
  
  def parse(in_pagecontent,project=$rw_default_project)
    pagecontent = in_pagecontent.dup
    pd          = Parse_Data.new
    tokens      = Array.new

    # pass 1 scan and replace
    Token_Base.tokenlist.each do |token_class|
      pagecontent.gsub!(token_class.regexp) { |match|
        md = Regexp.last_match
        tc = token_class.new(md,pd,project)
        tokens.push( tc )
        "TOKEN_#{tokens.size - 1}"
      }
    end

    # pass 2 fill in token replaces
    pagecontent.gsub!(/TOKEN_(\d*)/) { |match|
      md     = Regexp.last_match
      itoken = md[1].to_i
      tokens[itoken].replace
    }

    # pass 3 run fixups for each token type
    tokens.reverse_each { |token|
      token.post_replace(pagecontent)
    }

    return [pagecontent, pd]
  end
end
