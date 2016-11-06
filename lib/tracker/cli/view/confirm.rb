module Tracker
  class Cli
    module View
      class Confirm
        def initialize(confirm_string)
          @confirm_string = confirm_string
          print "Type \"#{confirm_string}\" to confirm: "
          @response_string = $stdin.gets.chomp
          print "\n\n"
        end
        
        def confirmed?
          @confirm_string == @response_string
        end
      end
    end
  end
end
