require 'spec_helper'

describe Tracker::Cli, config: true do
  let(:configuration) { { 'api_token' => 'abc123', 'project' => '123999' } }
  let(:stdout) { StringIO.new }

  around(:each) do |example|
    $stdout = stdout
    example.run
    $stdout = STDOUT
  end
  
  subject do
    Tracker::Cli.new(argv).tap { stdout.rewind }
  end
  
  describe '--list' do
    describe 'stories' do
      include_context 'list stories / basic'
      
      let(:argv) { [ '--list', 'stories' ] }
  
      it_behaves_like 'it validates configuration'
      
      it 'lists stories' do
        subject
        
        expect(stdout.read).to eq "00001\t\"Story #1\"\tunstarted\tfeature\n00002\t\"Story #2\"\tdelivered\tchore\n"
      end
      
      describe '--format json' do
        it 'spits out json' do
          argv.push('--format', 'json')
          
          subject
          
          expect(stdout.read).to eq JSON.dump(list_stories_response)
        end
      end
    end
  
    describe 'projects' do
      include_context 'list projects / basic'
      
      let(:argv) { [ '--list', 'projects' ] }
  
      it_behaves_like 'it validates configuration'
      
      it 'lists project' do
        subject
        
        expect(stdout.read).to eq "90001\t\"Project #1\"\n90002\t\"Project #2\"\n"
      end
      
      describe '--format json' do
        it 'spits out json' do
          argv.push('--format', 'json')
          
          subject
          
          expect(stdout.read).to eq JSON.dump(list_projects_response)
        end
      end
    end
  end
  
  describe '--fetch' do
    describe 'story' do
      describe '--id STORY_ID' do
        let(:argv) { [ '--fetch', 'story', '--id', '00001' ] }
      
        it_behaves_like 'it validates configuration'
      
        it 'fetches information about the story' do
          stub_api("stories/00001",
            'id' => '00001',
            'name' => 'Story #1'
          )
          
          subject
          
          expect(stdout.read).to eq "00001\t\"Story #1\"\n"
        end
      end
      
      describe '-i' do
        let(:argv) { [ '--fetch', 'story', '-i' ] }
  
        it_behaves_like 'it validates configuration'
  
        it 'lets user choose the story and fetches information about the selected story' do
          stub_api("projects/123999/stories", [
            { 'id' => '00001', 'name' => 'Story #1' },
            { 'id' => '00002', 'name' => 'Story #2' },
          ])
    
          allow($stdin).to receive(:gets).and_return("1\n")
          subject
    
          expect(stdout.read).to eq "(1) 00001 \"Story #1\"\n(2) 00002 \"Story #2\"\n\nWhich Story? \n00001\t\"Story #1\"\n"
        end
      end
    end
  end
end
