# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganismsController do

  describe 'GET index' do

    it 'should reset session' do
      session[:period] = 3
      get :index
      session[:period].should == nil
    end
    
    context 'whithout Organism' do
      it 'should redirect to admin new if no organism' do
        Organism.stub(:all).and_return(nil)
        get :index
        response.should redirect_to new_admin_organism_path
      end
    end

    context "with one organism" do
      let(:s) {mock_model(Organism)}

      before(:each) do
        Organism.stub(:count).and_return(1)
        Organism.stub(:all).and_return([s])
        Organism.stub(:first).and_return(s)
      end

      it "assigne @organisms" do
        get :index
        assigns[:organisms].should == Organism.all
      end


      it 'when 1 organism, redirect to show' do
        get :index
        response.should redirect_to organism_path(s.id)
      end

    end

    context "with several organisms" do
      let(:s1) {mock_model(Organism)}
      let(:s2) {mock_model(Organism)}

      before(:each) do
        Organism.stub(:count).and_return(2)
        Organism.stub(:all).and_return([s1, s2])
        Organism.stub(:first).and_return(s1)
      end

      it 'assign @organims ' do
        get :index
        assigns[:organisms].should == [s1, s2]
      end

      it 'does not assign @organim ' do
        get :index
        assigns[:organism].should == nil
      end

      it 'render index' do
        get :index
        response.should render_template('index')
      end

    end

  end

  describe 'GET show' do
    it 'Les spec de Organism get show restent à faire'
  end

end
