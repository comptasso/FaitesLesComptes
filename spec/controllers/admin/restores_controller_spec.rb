# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

class RestoreError < StandardError; end 

describe Admin::RestoresController do 
  include ActionDispatch::TestProcess

  let(:cu) {mock_model(User)}
  let(:cu2) {mock_model(User)}

  def valid_session
    {user:cu.id}
  end

  describe 'GET new' do

    it 'render new' do
      get :new, {}, valid_session
      response.should render_template('new')
    end

  end

  describe 'POST create' do

    before(:each) do
      @file = fixture_file_upload('spec/fixtures/files/test.sqlite3', 'application/octet-stream')
      User.stub(:find_by_id).with(cu.id).and_return cu
      Organism.stub_chain(:first, :update_attribute)
    end


    context 'tout va bien' do

      before(:each) do
        cu.stub_chain(:rooms, :new).and_return(@r = mock_model(Room, 'save!'=>true, :full_name=>'path_du_fichier.sqlite3'))
        @r.stub(:check_db).and_return(true)
        @r.stub(:connect_to_organism).and_return(true)
        @r.stub(:relative_version).and_return(:same_migration)
        @controller.stub(:dump_extension).and_return('.sqlite3')
        @controller.stub(:abc).and_return({:adapter=>'sqlite3'})
      end

      it 'redirige vers la liste des fichiers'  do
        
        post :create, {:file_upload=>@file, database_name:'test2'}, valid_session
        flash[:notice].should == "Le fichier a été chargé et peut servir de base de données"
        response.should redirect_to admin_rooms_url
      end

      it 'met à jour le nom de database_name pour l organisme' do
        Organism.should_receive(:first).and_return(@o=mock_model(Organism))
        @o.should_receive(:update_attribute).with(:database_name, 'test2')
        post :create, {:file_upload=>@file, database_name:'test2'}, valid_session
      end

    end

    describe 'gestion des anomalies et erreurs'  do 

      before(:each) do
        @controller.stub(:abc).and_return({:adapter=>'sqlite3'})
        @controller.stub(:dump_extension).and_return('.sqlite3')
        @ro =  mock_model(Room, :user=>cu2, :full_name=>'path_du_fichier.sqlite3', 'save!'=>true)
      end

      it 'vérifie que l adapter est sqlite3' do
        @controller.stub(:abc).and_return({:adapter=>'passqlite3'})
        post :create, {:file_upload=>@file, database_name:'test'}, valid_session
        flash[:alert].should == "La restauration de bases n'est possible que pour les bases sqlite3"
        response.should render_template 'new'
      end

      it 'vérifie que le nom de base n est pas pris par un autre user' do
        Room.should_receive(:find_by_database_name).with('test').and_return(@ro)
        @ro.should_not be_nil
        @ro.user.should_not == cu
        post :create, {:file_upload=>@file, database_name:'test'}, valid_session
        flash[:alert].should == 'Ce nom de base est déjà pris et ne vous appartient pas'
        response.should render_template 'new'
      end


      it 'vérifie le format de fichier'   do
        cu.stub_chain(:rooms, :new).and_return(@r = mock_model(Room, 'save!'=>true))
        post :create, {:file_upload=>fixture_file_upload('spec/fixtures/files/test.biz', 'application/octet-stream'), database_name:'test'}, valid_session
        flash[:alert].should == "L'extension .biz du fichier ne correspond pas aux bases gérées par l'application : .sqlite3"
      end
      
      it 'vérifie le format de database'  do
        cu.stub_chain(:rooms, :new).and_return @ro
        @ro.should_receive(:valid?).and_return(false)
        post :create, {:file_upload=>@file, database_name:'2test2'}, valid_session
        flash[:alert].should == 'Nom de base non valide : impossible de créer la base'
      end

      it 'vérifie la base' do
        cu.stub_chain(:rooms, :new).and_return @ro
        @ro.stub(:check_db).and_return false
        post :create, {:file_upload=>@file, database_name:'test'}, valid_session
        flash[:alert].should == 'Le contrôle du fichier par SQlite renvoie une erreur'
      end

      context 'vérification de la version'  do

        before(:each) do
          cu.stub_chain(:rooms, :new).and_return @ro
          @ro.stub(:check_db).and_return true
          @ro.stub(:connect_to_organism).and_return true
        end

        after(:each) do
          File.delete('path_du_fichier.sqlite3') if File.exist?('path_du_fichier.sqlite3')
        end

        it 'redirige vers admin_rooms' do 
          @ro.stub(:relative_version).and_return(:same_migration)
          post :create, {:file_upload=>@file, database_name:'test'}, valid_session
          response.should redirect_to admin_rooms_url
        end
      
        it 'si la version est same_migration'  do
          @ro.stub(:relative_version).and_return(:same_migration)
          post :create, {:file_upload=>@file, database_name:'test'}, valid_session
          flash[:notice].should == "Le fichier a été chargé et peut servir de base de données"
        end
      
        it 'si ce n est pas la même version' do
          pending 'voir comment on traite cette question car ce n est plus dans restore'
        end

      end
    end

  end

end

