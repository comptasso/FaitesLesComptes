# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config|
  config.filter = {wip:true}
end

describe Compta::WritingsController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true 
    @b = mock_model(Book)
    Book.stub(:find).and_return(@b)
  end
  # This should return the minimal set of attributes required to create a valid
  # Writing. As you add validations to Writing, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {book_id:1, date:Date.today, narration:'Ecriture'}
  end
  
  
  describe "GET index"  do
    it "assigns all writings as @writings" do
      @b.should_receive(:writings).and_return @a = double(Arel)
      @a.should_receive(:all).and_return [1,2]
      
      get :index, {book_id:@b.id}, valid_session
      assigns(:writings).should eq([1,2])
    end
  end

  describe "GET show" do
    it "assigns the requested writing as @writing" do
      writing = mock_model(Writing)
      Writing.should_receive(:find).with(writing.to_param).and_return writing
      get :show, {book_id:@b.id, :id => writing.to_param}, valid_session
      assigns(:writing).should eq(writing)
    end
  end

  describe "GET new"  do
    it "assigns a new writing as @writing" do
      @b.stub_chain(:writings, :new).and_return(Writing.new)
      get :new, {book_id:@b.to_param}, valid_session
      assigns(:book).should == @b
      assigns(:writing).should be_a_new(Writing)
    end
  end

  describe "GET edit" do
    it "assigns the requested writing as @writing" do
      writing = mock_model(Writing)
      Writing.should_receive(:find).with(writing.to_param).and_return writing
      get :edit, {book_id:@b.id, :id => writing.to_param}, valid_session
      assigns(:writing).should eq(writing)
    end
  end

  describe "POST create" , wip:true do

    before(:each) do
#      @w = Writing.new(valid_attributes)
#      @w.stub_chain(:compta_lines, :count).and_return 2
#      @w.stub(:balanced?).and_return true
    end

    describe "with valid params" do
      it "creates a new Writing" do
        expect {
          post :create, {book_id:@b.id, :writing => valid_attributes}, valid_session
        }.to change(Writing, :count).by(1)
      end

      it "assigns a newly created writing as @writing" do
        post :create, {:writing => valid_attributes}, valid_session
        assigns(:writing).should be_a(Writing)
        assigns(:writing).should be_persisted
      end

      it "redirects to the created writing" do
        post :create, {:writing => valid_attributes}, valid_session
        response.should redirect_to(Writing.last)
      end
    end

    describe "with invalid params"   do
      it "assigns a newly created but unsaved writing as @writing" do
        # Trigger the behavior that occurs when invalid params are submitted
        Writing.any_instance.stub(:save).and_return(false)
        post :create, {book_id:@b.id, :writing => {}}, valid_session
        assigns(:writing).should be_a_new(Writing)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Writing.any_instance.stub(:save).and_return(false)
        post :create, {book_id:@b.id, :writing => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested writing" do
        writing = Writing.create! valid_attributes
        # Assuming there are no other writings in the database, this
        # specifies that the Writing created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Writing.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => writing.to_param, :writing => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested writing as @writing" do
        writing = Writing.create! valid_attributes
        put :update, {:id => writing.to_param, :writing => valid_attributes}, valid_session
        assigns(:writing).should eq(writing)
      end

      it "redirects to the writing" do
        writing = Writing.create! valid_attributes
        put :update, { :id => writing.to_param, :writing => valid_attributes}, valid_session
        response.should redirect_to(writing)
      end
    end

    describe "with invalid params"  do
      it "assigns the writing as @writing" do
        writing = Writing.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Writing.any_instance.stub(:save).and_return(false)
        put :update, {book_id:@b.id, :id => writing.to_param, :writing => {}}, valid_session
        assigns(:writing).should eq(writing)
      end

      it "re-renders the 'edit' template" do
        writing = Writing.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Writing.any_instance.stub(:save).and_return(false)
        put :update, {book_id:@b.id, :id => writing.to_param, :writing => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested writing" do
      writing = Writing.create! valid_attributes
      expect {
        delete :destroy, {:id => writing.to_param}, valid_session
      }.to change(Writing, :count).by(-1)
    end

    it "redirects to the writings list" do
      writing = Writing.create! valid_attributes
      delete :destroy, {:id => writing.to_param}, valid_session
      response.should redirect_to(writings_url)
    end
  end

end
