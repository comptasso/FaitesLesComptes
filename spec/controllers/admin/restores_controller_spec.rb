# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::RestoresController do

  describe 'GET new' do

    it 'render new' do
      get :new
      response.should render_template('new')
    end 
    
  end

  
  describe 'POST rebuild' do
    before(:each) do
      @file_name = 'spec/fixtures/files/test_compta2.yml'
      File.open(@file_name,'r')  { |f| @datas = YAML.load(f) }
    end

    it 'affiche un flash en cas de succès' do
      Admin::RestoresController.any_instance.stub(:read_datas_from_tmp_file).and_return nil
      File.stub(:delete).and_return nil
      Restore::ComptaRestorer.any_instance.should_receive(:compta_restore).and_return(true)
      Restore::ComptaRestorer.any_instance.stub(:datas).and_return({:organism=> mock_model(Organism, title: 'SUCCES') })
      assigns[:datas] = @datas
      post :rebuild, :file_name=>@file_name
      flash[:notice].should == 'Importation de l\'organisme SUCCES effectuée'
    end

    it 'when rebuild echoue'

  end

  describe 'POST create' do
    context 'with a correct file' do
      

        before :each do
          @file = fixture_file_upload("#{File.dirname(__FILE__)}/../../fixtures/files/test_compta2.yml", 'text/yml')
          
        end 
      
      #
#      after(:each) do
#        @file.close
#      end

      it 'should assign @just_filename with the basename' do
        post :create, :file_upload => @file
        assigns[:just_filename].should == 'test_compta2.yml'
      end

      it "should not raise error" do
        post :create, :file_upload => @file, :multipart=>true
        response.should render_template(:confirm)
      end

   
      it 'assigns @datas with the content of the file' do
        post :create, :file_upload => @file
        assigns[:datas].should have(19).elements
      end

       it 'reads datas' do
         post :create, :file_upload => @file
          File.open("#{File.dirname(__FILE__)}/../../fixtures/files/test_compta2.yml",'r')  { |f| @datas = YAML.load(f) }
         assigns[:datas][:periods].should == @datas[:periods]
       end

    
    end
   
    context "the file is malformatted" do

      before(:each) do
        @file = fixture_file_upload("#{File.dirname(__FILE__)}/../../fixtures/files/invalid_test_compta.yml", 'text/yml')
        
      end

      after(:each) do
        @file.close
      end

      it 'archive should have errors' do
        
        post :create, :file_upload=>@file
        flash[:alert].should == "Lecture des données impossible. Erreur à la ligne 15, colonne 2"
      end

      it 'should rerender new' do
        
        post :create, :file_upload=>@file
        response.should render_template(:new)
      end
    end
    
    context "the extension is not correct" do

      before(:each) do
        @file = fixture_file_upload("#{File.dirname(__FILE__)}/../../fixtures/files/BlurMetalLb6.gif", 'img/gif')
      end

      it 'should flash an alert' do
        
        post :create, :file_upload=>@file
        flash[:alert].should == "Erreur : l'extension du fichier ne correspond pas.\n"
      end

      it 'should rerender new' do
        
        post :create, :file_upload=>@file
        response.should render_template(:new)
      end

    end
  end
end

