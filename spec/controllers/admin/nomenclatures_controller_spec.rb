# -*- encoding : utf-8 -*-

require 'spec_helper'

describe Admin::NomenclaturesController do 
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    @o.stub(:nomenclature).and_return(@nomenclature = mock_model(Nomenclature))
  end

  describe "GET edit" do 

    it "doit créer la variable d instance @nomenclature" do
      @o.stub(:nomenclature).and_return(double(Nomenclature))
      get :edit, {:organism_id=>@o.id.to_s}, valid_session
      assigns(:nomenclature).should == @o.nomenclature
    end

    it 'doit rendre la vue edit' do 
      get :edit, {:organism_id=>@o.id.to_s}, valid_session 
      response.should render_template('edit') 
    end

  end

  describe "PUT update" do

    before(:each) do
      path = 'spec/fixtures/association/good.yml'
      @file = fixture_file_upload(path, 'application/octet-stream')
      @yml = YAML::load_file(path)
    end

    it 'assigns nomenclature' do
        @nomenclature.stub(:load_io)
        @nomenclature.stub(:save).and_return true
        put :update,{:organism_id=>@o.id.to_s,  "file_upload" =>@file}, valid_session
        
        assigns(:nomenclature).should == @nomenclature
      end

        describe "with valid params" do
      it "lit le fichier" do
        @nomenclature.should_receive(:load_io)
        @nomenclature.stub(:save).and_return true
        put :update,{:organism_id=>@o.id.to_s,  "file_upload" =>@file}, valid_session
      end

   it "et sauve la nomenclature" do
        @nomenclature.stub(:load_io)
        @nomenclature.should_receive(:save).and_return true
        put :update,{:organism_id=>@o.id.to_s,  "file_upload" =>@file}, valid_session
        flash[:notice].should == "La nomenclature chargée est maintenant celle qui sera appliquée pour les prochaines éditions de documents"
        response.should redirect_to admin_organism_path(@o)
      end


    end

    describe 'with invalid parameters' do



      it 'insert a flash alert if not yml extension' do
        @bad_file = fixture_file_upload('spec/fixtures/files/test.biz', 'application/octet-stream')
#        @nomenclature.stub(:file_load)
#        @nomenclature.stub(:save).and_return false
        put :update,{:organism_id=>@o.id.to_s,  "file_upload" =>@bad_file}, valid_session
        flash[:alert].should == "Le format des nomenclatures doit être un fichier YAML (extension yml et non .biz"
        response.should render_template('edit')
      end

       it 'render edit if impossible to save' do
        @bad_file = fixture_file_upload('spec/fixtures/association/doublons.yml', 'application/octet-stream')
        @nomenclature.stub(:load_io)
        @nomenclature.stub(:save).and_return false
        put :update,{:organism_id=>@o.id.to_s,  "file_upload" =>@bad_file}, valid_session
        response.should render_template('edit')
      end

      it 'render edit if impossible to save' do
        @bad_file = fixture_file_upload('spec/fixtures/association/doublons.yml', 'application/octet-stream')
        @nomenclature.stub(:load_io)
        @nomenclature.stub(:save).and_return false
        @nomenclature.stub(:valid?).and_return false
        @nomenclature.stub_chain(:errors, :full_messages).and_return ['voici la liste des erreurs']
        
        put :update,{:organism_id=>@o.id.to_s,  "file_upload" =>@bad_file}, valid_session
        flash[:alert].should have_content('voici la liste des erreurs')
      end


    end


  end

end
