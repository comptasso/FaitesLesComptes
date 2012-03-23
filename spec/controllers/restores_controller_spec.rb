# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::RestoresController do

  describe 'GET new' do

    it 'render new' do
      get :new
      response.should render_template('new')
    end 
    
  end

  describe 'POST create' do
    before(:each) do
      @file_name = './eliminer/test.yml'
      @file_name.stub(:original_filename).and_return(@file_name)
    end
#
#    after(:each) do
#      File.close('test.yml')
#    end

    it 'should assign @just_filename with the basename' do
      post :create, :file_upload=>@file_name
      assigns[:just_filename].should == 'test.yml'
    end
    
    context "the extension is not correct" do
      
    before(:each) do 
      @file_name = './eliminer/test.xml'
      @file_name.stub(:original_filename).and_return(@file_name)
    end

    it 'should flash an alert' do
      post :create, :file_upload=>@file_name
      flash[:alert].should == "Erreur : l'extension du fichier ne correspond pas.\n"
    end

      it 'should rerender new' do
        post :create, :file_upload=>@file_name
        response.should render_template(:new)
      end

    end
  end
end

