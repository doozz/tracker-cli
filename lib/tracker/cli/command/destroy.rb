module Tracker
  class Cli
    module Command
      class Destroy
        attr_reader :cli, :arguments
        
        def initialize(cli: , object_type: , **arguments)
          @cli = cli
          @arguments = arguments
          
          case object_type
          when 'project' then destroy_project(**arguments)
          end
        end
        
        def destroy_project(object_id: , **arguments)
          project = cli.connection.get("projects/#{object_id}").body
          
          print "Warning: Destructive Action!\n\n"
          confirm = View::Confirm.new(project['name'])
          
          if confirm.confirmed?
            print cli.connection.delete("projects/#{object_id}").body
          end
        end
      end
    end
  end
end
