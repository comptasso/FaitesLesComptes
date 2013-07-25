require 'spec_helper'

describe Admin::ClonesController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    sign_in(@cu)
    @ca = mock_model(Cash) 

  end


  describe "GET 'new'" do
    it "returns http success" do 
      get 'new', {}, valid_session
      response.should be_success
    end
  end

  describe "GET 'create'" do
    
    before(:each) do
      @o.stub(:room).and_return @r
      @comment = 'un test de création de clone'
    end

    it 'room should_receive clone_db with comment' do
      @r.should_receive(:clone_db).with(@comment)
      get 'create', {:organism=>{:comment=>@comment}}, valid_session
    end

    it "redirect to admin_rooms" do
      @r.stub(:clone_db).with(@comment).and_return true
      get 'create', {:organism=>{:comment=>@comment}}, valid_session
      response.should redirect_to admin_rooms_url
    end

    it 'si le clone marche affiche un flash' do
      @r.stub(:clone_db).with(@comment).and_return true
      get 'create', {:organism=>{:comment=>@comment}}, valid_session
      flash[:notice].should == 'Un clone de votre base a été créé'
    end

    it 'si le clone ne marche pas affiche un flash d\'erreur' do
      @r.stub(:clone_db).with(@comment).and_return false
      get 'create', {:organism=>{:comment=>@comment}}, valid_session
      flash[:alert].should == 'Une erreur s\'est produite lors de la création du clone de votre base'
    end



  end

end
