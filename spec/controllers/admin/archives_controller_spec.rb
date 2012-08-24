# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ArchivesController do 
  let(:org) {mock_model(Organism, title: 'test archives', base_name:'spec/support/assotest.sqlite3')}
  let(:arch) {mock_model(Archive)}
  let(:cu) {mock_model(User)}


    # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TransfersController. Be sure to keep this updated too.
  def valid_session
    {user:cu.id, org_db:'assotest'}
  end

  
  before(:each) do
    ActiveRecord::Base.stub!(:use_org_connection).and_return(true)  # pour éviter
    # l'appel d'establish_connection dans le before_filter find_organism
    Organism.stub(:first).and_return(org)
    controller.stub(:current_period).and_return(nil)
    org.stub_chain(:archives, :new).and_return(arch) 
  end

  describe 'GET index' do
  
    let(:arch2) {mock_model(Archive)}
    
    before(:each) do
      org.stub_chain(:archives, :all).and_return([arch, arch2])
    end

    it 'render index' do

      get :index, {organism_id: org.id}, valid_session
      response.should render_template('index')
    end

    it 'assigns @archives' do

      get :index, {organism_id: org.id}, valid_session
      assigns[:archives].should == [arch, arch2]
    end
  end

  describe 'GET new' do

    it 'render new' do
      get :new,{ :organism_id=>org.id}, valid_session
      response.should render_template('new')
    end

  end

   describe 'POST create' do

    before(:each) do
      
    end

    it 'doit créer une archive' do
      org.should_receive(:archives).and_return @a = double(Arel)
      @a.should_receive(:new).with( {"comment"=>'spec'}).and_return(arch)
      arch.stub(:save)
      post :create, {:organism_id=>org.id, archive: {comment: 'spec'}}, valid_session
    end

    it 'le controller doit recevoir send_file' do
      org.stub_chain(:archives, :new).and_return(arch)
      arch.stub(:save).and_return(true)
      controller.should_receive(:send_file)
      controller.stub(:render) # sinon le spec tente quand même d'appeler un render par défaut
      post :create, {:organism_id=>org.id, archive: {comment: 'spec'}}, valid_session
    end

    it 'si echec rend new' do
      org.stub_chain(:archives, :new).and_return(arch)
      arch.stub(:save).and_return(false)
      post :create,{ :organism_id=>org.id, archive: {comment: 'spec'}}, valid_session
      response.should render_template('new')
    end

    

  end
end

