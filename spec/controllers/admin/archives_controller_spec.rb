# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ArchivesController do
  include SpecControllerHelper

  let(:arch) {mock_model(Archive, :archive_filename=>'assotest1 6 juin 2013.dump')}

  before(:each) do
    minimal_instances
    @o.stub_chain(:archives, :new).and_return(arch)
    @o.stub(:full_name).and_return('spec/support/assotest1.sqlite3')
  end

  describe 'GET index' do
  
    let(:arch2) {mock_model(Archive)}
    
    before(:each) do
      @o.stub_chain(:archives, :all).and_return([arch, arch2])
    end

    it 'render index' do

      get :index, {organism_id: @o.id}, valid_session
      response.should render_template('index')
    end

    it 'assigns @archives' do

      get :index, {organism_id: @o.id}, valid_session
      assigns[:archives].should == [arch, arch2]
    end
  end


  describe 'GET edit' do

    it 'cherche l archive' do
      Archive.should_receive(:find).with(arch.to_param).and_return arch
      get :edit, {organism_id: @o.id, :id=>arch.id}, valid_session
    end


    it 'et l assigne' do
      Archive.should_receive(:find).with(arch.to_param).and_return arch
      get :edit, {organism_id: @o.id, :id=>arch.id}, valid_session
      assigns[:archive].should == arch
    end
  end

  describe 'GET new' do

    it 'render new' do
      get :new,{ :organism_id=>@o.id}, valid_session
      response.should render_template('new')
    end

  end

  describe 'POST create' do

    it 'doit créer une archive' do
      @o.should_receive(:archives).and_return @a = double(Arel)
      @a.should_receive(:new).with( {"comment"=>'spec'}).and_return(arch)
      arch.stub(:save)
      post :create, {:organism_id=>@o.id, archive: {comment: 'spec'}}, valid_session
    end

    it 'le controller doit recevoir send_file' do
      @o.stub_chain(:archives, :new).and_return(arch)
      arch.stub(:save).and_return(true)
      controller.should_receive(:send_file)
      controller.stub(:render) # sinon le spec tente quand même d'appeler un render par défaut
      post :create, {:organism_id=>@o.id, archive: {comment: 'spec'}}, valid_session
    end

    it 'si echec rend new' do
      @o.stub_chain(:archives, :new).and_return(arch)
      arch.stub(:save).and_return(false)
      post :create,{ :organism_id=>@o.id, archive: {comment: 'spec'}}, valid_session
      response.should render_template('new')
    end

    

  end

  describe "PUT update" do
    before(:each) do
      @o.stub(:archives).and_return(@ar = double(Arel))
      @ar.stub(:find).with(arch.to_param).and_return(arch)
    end

    describe "with valid params" do
      it "updates the requested arch" do
        @ar.should_receive(:find).with(arch.to_param).and_return arch
        arch.should_receive(:update_attributes).with({'these' => 'params'})
        put :update,{:organism_id=>@o.id.to_s,  :id => arch.id, :archive => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested arch as @arch" do

        arch.stub(:update_attributes).and_return true
        put :update,{:organism_id=>@o.id.to_s,  :id => arch.id, :archive => {'these' => 'params'}}, valid_session
        assigns(:archive).should eq(arch)
      end

      it "redirects to index" do
        arch.stub(:update_attributes).and_return true
        put :update, {:organism_id=>@o.id.to_s, :id => arch.id, :archive => {'these' => 'params'}}, valid_session
        response.should redirect_to(admin_organism_archives_url(@o))
      end
    end

    describe "with invalid params" do
      it "assigns the arch as @arch" do
        arch.stub(:update_attributes).and_return false
        put :update, {:organism_id=>@o.id.to_s, :id => arch.id.to_s, :archive => {}}, valid_session
        assigns(:archive).should eq(arch)
      end

      it "re-renders the 'edit' template" do
        arch.stub(:update_attributes).and_return false
        Cash.any_instance.stub(:save).and_return(false)
        put :update,{:organism_id=>@o.id.to_s,  :id => arch.id.to_s, :archive => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe 'DELETE destroy' do



    it 'identifie l archive' do
      Archive.should_receive(:find).with(arch.to_param).and_return arch
      delete :destroy, {organism_id: @o.id, :id=>arch.to_param}, valid_session
    end

    it 'avec un flash de succès' do
      Archive.stub(:find).with(arch.to_param).and_return arch
      arch.should_receive(:destroy).and_return true
      delete :destroy, {organism_id: @o.id, :id=>arch.to_param}, valid_session
      flash[:notice].should == 'Enregistrement effacé'
    end

    it 'ou un flash d alerte' do
      Archive.stub(:find).with(arch.to_param).and_return arch
      arch.should_receive(:destroy).and_return false
      delete :destroy, {organism_id: @o.id, :id=>arch.to_param}, valid_session
      flash[:alert].should == "Une erreur s'est produite empêchant la destruction de l'enregistrement"
    end



  end


end

