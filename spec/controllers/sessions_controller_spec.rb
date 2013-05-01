# coding: utf-8

require 'spec_helper'

describe SessionsController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
  end

  describe 'GET new' do
    it 'crée un user et l assigne' do
      User.should_receive(:new).with().and_return(@u =mock_model(User).as_new_record)
      get :new
      assigns[:user].should == @u
    end
  end

  describe 'check browser' do

    it 'rend une page fixe si IE 6 à 8' do
      @controller.stub_chain(:browser, 'ie6?').and_return true
      @controller.stub_chain(:browser, :name).and_return 'Internet Explorer 6'
      get :new
      flash[:alert].should == 'Navigateur : Internet Explorer 6'
      response.should render_template(:file=>"#{Rails.root}/public/update_ie", :format=>:html)
    end

  end

  describe 'POST create' do
    it 'à faire'
  end


  describe 'DESTROY' do

    it 'delete efface les infos de session' do
      delete :destroy, {id:1}, valid_session
      session[:user].should == nil
      session[:org_db].should == nil
      session[:period].should == nil
    end
  end
end
