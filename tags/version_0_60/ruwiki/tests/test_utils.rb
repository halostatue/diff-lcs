#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (austin@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

content = 

module Test_Utils
  TEST_UTILS_DEFAULT_CONTENT = "id: 0
topic: TestPage
#EHDR
Test page for unit test.
"

  # create and delete a test page file, used for testing
  def testing_page(op, topic='TestPage', content=TEST_UTILS_DEFAULT_CONTENT)
    testdir  = '../data/Default'
    testpage = testdir + '/' + topic
    case op
    when :set_up
      unless FileTest.exist?(testdir)
        raise StandardError, "Error #{testdir} doesn't exist"
      end
      if FileTest.exist?(testpage)
        raise StandardError, "Error #{testpage} already exists"
      end
      open(testpage, 'w') { |tph| tph.print content }
      
    when :tear_down
      File.unlink(testpage)
    end
  end
end
