require 'spec_helper'
require 'support/spec_controller_helper'

describe Admin::ClonesController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    # minimal instance donne @cu pour current_user
  end

  context 'le current_user est le owner' do

    before(:each) {@controller.stub(:owner_only).and_return true}

    describe "GET 'new'" do
      it "returns http success" do
        get 'new', {}, valid_session
        response.should be_success
      end
    end

    describe "GET 'create'" do

      before(:each) do
        @comment = 'un test de création de clone'
        @ucl = double(Utilities::Cloner, form_org:@o, clone_organism:9999)
      end

      it 'crée un Utilities::Cloner' do
        Utilities::Cloner.should_receive(:create).with(old_org_id:@o.id).
          and_return @ucl
        get 'create', {:organism=>{:comment=>@comment}}, valid_session
      end

      it "le cloner appelle clone_organism avec comment" do
        Utilities::Cloner.stub(:create).and_return @ucl
        @ucl.should_receive(:clone_organism).with(@comment)
        get 'create', {:organism=>{:comment=>@comment}}, valid_session
        response.should redirect_to admin_organisms_url
      end

      it "le cloner appelle clone_organism avec comment" do
        Utilities::Cloner.stub(:create).and_return(@ucl)
        get 'create', {:organism=>{:comment=>@comment}}, valid_session
        response.should redirect_to admin_organisms_url
      end

      context 'lorsque le clone a fonctionné' do


      it 'si le clone marche affiche un flash' do
        Utilities::Cloner.stub(:create).and_return(@ucl)
        get 'create', {:organism=>{:comment=>@comment}}, valid_session
        flash[:notice].should == 'Un clone de votre base a été créé'
      end
      end


      context 'lorsque le clone a fonctionné' do

        before(:each) do
          @ucl.stub(:clone_organism).and_return nil
          Utilities::Cloner.stub(:create).and_return(@ucl)
        end

      it 'si le clone ne marche pas affiche un flash d\'erreur' do
        get 'create', {:organism=>{:comment=>@comment}}, valid_session
        flash[:alert].should == 'Une erreur s\'est produite lors de la création du clone de votre base'
      end
      end


    end

  end

  context 'quand le user n est pas le owner' do

    before(:each) do
      @o.stub(:owner).and_return(User.new) # donc évidemment pas le même que @cu
    end

    after(:each) do
      @o.stub(:owner).and_return(@cu)
    end

    it 'redirige vers admin_rooms_url' do
      get 'new', {}, valid_session
      response.should redirect_to admin_organisms_url
    end

  end

end
