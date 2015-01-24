# coding: utf-8

# TODO finir ce spec

require 'spec_helper'

describe Admin::BooksController do

  include SpecControllerHelper

  def valid_attributes
    {:book_type=>'IncomeBook'}
  end

  before(:each) do
    minimal_instances
  end

  describe 'GET index' do
    it 'demande tous les livres et les assigne' do
      @o.should_receive(:books).and_return(['VE', 'AC'])
      get :index, {:organism_id=>@o.to_param}, valid_session
      assigns[:books].should == ['VE', 'AC']
    end

    it 'et rend index' do
      @o.stub(:books).and_return ['VE', 'AC']
      get :index, {:organism_id=>@o.to_param}, valid_session
      response.should render_template('index')
    end
  end

#  describe 'GET new' do
#
#    it 'construit un nouveau livre et  l assigne' do
#      @o.should_receive(:books).and_return(@ar = double(Arel))
#      @ar.should_receive(:build).and_return(mock_model(Book).as_new_record)
#      get :new , {:organism_id=>@o.to_param}, valid_session
#      assigns[:book].should be_a_new(Book)
#    end
#  end


  describe "GET edit" do
    it "assigns the requested book as @book" do 
      @o.should_receive(:books).and_return(@ar = double(Arel))
      @ar.should_receive(:find).with('7').and_return(@bo = mock_model(Book))
      get :edit, {organism_id:@o.id, :id => '7'}, valid_session
      assigns(:book).should == @bo
    end
  end

#  describe 'PUT create' do
#
#    it 'avec un income_book crée un income_book' do
#      @o.should_receive(:income_books).and_return(@ar = double(Arel))
#      @ar.stub(:build).and_return(double(Book, :save=>true))
#      post :create, {:organism_id=>@o.to_param, :book => {:book_type=>'IncomeBook'} }, valid_session
#      
#    end
#
#    it 'avec un outcome_book crée un outcome_book' do
#      @o.should_receive(:outcome_books).and_return(@ar = double(Arel))
#      @ar.stub(:build).and_return(double(Book, :save=>true))
#      post :create, {:organism_id=>@o.to_param, :book => {:book_type=>'OutcomeBook'} }, valid_session
#      
#    end
#
#    it 'doit recevoir save et rediriger si true' do
#      @o.stub_chain(:outcome_books, :build).and_return(@bo = double(Book))
#      @bo.should_receive(:save).and_return true
#      post :create, {:organism_id=>@o.to_param, :book => {:book_type=>'OutcomeBook'} }, valid_session
#      response.should redirect_to(admin_organism_books_url(@o))
#    end
#
#    it 'rend le formulaire new dans le cas contraire' do
#      @o.stub_chain(:outcome_books, :build).and_return(double(Book, :save=>false))
#      post :create, {:organism_id=>@o.to_param, :book => {:book_type=>'OutcomeBook'} }, valid_session
#      response.should render_template('new')
#    end
#
#
#  end

  describe "PUT update" do

    before(:each) do
      @bo = mock_model(Book)
      Book.stub(:find).with(@bo.to_param).and_return @bo
    end

    describe "with valid params" do
      it "updates the requested @bo" do
        @bo.should_receive(:update_attributes).with({'description' => 'test'})
        put :update,{:organism_id=>@o.id.to_s,
          :id => @bo.id, :book => {description:'test'}}, valid_session
      end

      it "assigns the requested @bo as @@bo" do
        
        @bo.stub(:update_attributes).and_return true
        put :update,{:organism_id=>@o.id.to_s,
          :id => @bo.id, :book => valid_attributes}, valid_session
        assigns(:book).should eq(@bo)
      end

      it "redirects to index" do
        
        @bo.stub(:update_attributes).and_return true
        put :update, {:organism_id=>@o.id.to_s,
          :id => @bo.id, :book => valid_attributes}, valid_session
        response.should redirect_to(admin_organism_books_url(@o))
      end
    end

    describe "with invalid params" do
      it "assigns the @bo as @@bo" do
        
        @bo.stub(:update_attributes).and_return false
        put :update, {:organism_id=>@o.id.to_s,
          :id => @bo.id.to_s, :book => {description:'test'}}, valid_session
        assigns(:book).should eq(@bo)
      end

      it "re-renders the 'edit' template" do
       
        @bo.stub(:update_attributes).and_return false
        Cash.any_instance.stub(:save).and_return(false)
        put :update,{:organism_id=>@o.id.to_s,
          :id => @bo.id.to_s, :book => {description:'test'}}, valid_session
        response.should render_template("edit")
      end
    end
  end

#  describe "DELETE destroy" do
#    before(:each) do
#       @bo = mock_model(Book)
#    end
#
#    it "destroys the requested book" do
#      Book.should_receive(:find).with(@bo.to_param).and_return @bo
#      @bo.should_receive(:destroy)
#      delete :destroy,{:organism_id=>@o.to_param,  :id => @bo.to_param}, valid_session
#
#    end
#
#    it "redirects to the cashes list" do
#      Book.should_receive(:find).with(@bo.to_param).and_return @bo
#      @bo.stub(:destroy)
#      delete :destroy,{:organism_id=>@o.to_param,  :id => @bo.id}, valid_session
#      response.should redirect_to(admin_organism_books_url(@o))
#    end
#  end


end
