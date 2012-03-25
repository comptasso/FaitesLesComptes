# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ArchivesController do 
  let(:org) {mock_model(Organism, title: 'test archives')}
  let(:arch) {mock_model(Archive)}

  
  before(:each) do
    Organism.stub(:find).and_return(org)
    controller.stub(:current_period).and_return(nil)
    org.stub_chain(:archives, :new).and_return(arch)
  end

  describe 'GET index' do
  
    let(:arch2) {mock_model(Archive)}
    
    before(:each) do
      org.stub_chain(:archives, :all).and_return([arch, arch2])
    end

    it 'render index' do

      get :index, organism_id: org.id
      response.should render_template('index')
    end

    it 'assigns @archives' do

      get :index, organism_id: org.id
      assigns[:archives].should == [arch, arch2]
    end
  end

  describe 'GET new' do

    it 'render new' do
      
      get :new, :organism_id=>org.id
      response.should render_template('new')
    end

  end

   describe 'POST create' do

    before(:each) do
      @d=Time.now.to_s[/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/].gsub(' ', '_')
      arch.stub(:title).and_return('test_archives_' + @d + '_UTC')
    end

    it 'le nom du fichier de sauvegarde doit comprendre le nom de l organisme' do
      arch.stub(:save).and_return(true)
      arch.stub(:collect_datas)
      arch.stub_chain(:datas, :to_yaml).and_return(' ')
      controller.stub(:render)
      controller.should_receive(:send_file)
      post :create, :organism_id=>org.id, archive: {comment: 'spec'}
    end

    it 'le nom du fichier doit comprendre le timestamp' do
      
      #e=d[/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/]
      #d.gsub!
      arch.stub(:save).and_return(true)
      arch.stub(:collect_datas)
      arch.stub(:title).and_return('test_archives_' + @d + '_UTC')
      arch.stub_chain(:datas, :to_yaml).and_return(' ')
      controller.stub(:render)
      post :create, :organism_id=>org.id, archive: {comment: 'spec'}
      assigns[:tmp_file_name].should == "#{Rails.root}/tmp/test_archives_#{@d}_UTC.yml"
    end

    

  end
end

