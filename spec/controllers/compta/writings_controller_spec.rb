# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config|
 # config.filter = {wip:true}
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
    {book_id:@b.id, date:Date.today, narration:'Ecriture', :compta_lines_attributes=>{'0'=>{account_id:1, debit:100, credit:0},
        '1'=>{account_id:2, debit:0, credit:100}}}
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

  describe "POST create"  do

    before(:each) do
      #      @w = Writing.new(valid_attributes)
      #      @w.stub_chain(:compta_lines, :count).and_return 2
      #      @w.stub(:balanced?).and_return true
    end

    describe "with valid params"  do

      before(:each) do
        @r = mock_model(Writing)
        @b.stub(:writings).and_return @a = double(Arel)
        @a.stub(:new).with(@r.to_param).and_return @r
        
      end

      it "assigns a newly created writing as @writing" do
        @r.stub(:save).and_return(true)
        post :create, {book_id:@b.to_param, :writing => @r.to_param}, valid_session
        assigns(:writing).should be_a(Writing)
      end

      it "redirects to the created writing" do
        @r.stub(:save).and_return(@r)
        post :create, {book_id:@b.to_param, :writing => @r.to_param }, valid_session
        response.should redirect_to new_compta_book_writing_url(@b)
      end
    end

    describe "with invalid params"   do
      before(:each) do
        @r = mock_model(Writing)
        @b.stub(:writings).and_return @a = double(Arel)
        @a.stub(:new).and_return @r
      end

      it "assigns a newly created but unsaved writing as @writing" do
        # Trigger the behavior that occurs when invalid params are submitted
        @r.stub(:save).and_return(false)
        post :create, {book_id:@b.id, :writing => {}}, valid_session
        assigns(:writing).should == @r
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
       @r.stub(:save).and_return(false)
        post :create, {book_id:@b.id, :writing => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before(:each) do
      @w = mock_model(Writing).as_null_object
      @va = {id:@w.id, book_id:@b.id, date:Date.today, narration:'Ecriture', :compta_lines_attributes=>{'0'=>{account_id:1, debit:100, credit:0},
          '1'=>{account_id:2, debit:0, credit:100}} }
      Writing.stub(:find).with(@w.to_param).and_return @w
    end

    describe "with valid params" do
      it "updates the requested writing" do
     
        # Assuming there are no other writings in the database, this
        # specifies that the Writing created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        @w.should_receive(:update_attributes).with({'these' => 'params'}).and_return @w
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested writing as @writing" do
        
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {'these' => 'params'}}, valid_session
        assigns(:writing).should eq(@w)
      end

      it "redirects to the writing" do
        @w.stub(:update_attributes).and_return true
        put :update, {book_id:@b.id,  :id => @w.to_param, :writing => @va}, valid_session
        response.should redirect_to compta_book_writing_url(@b, @w)
      end
    end

    describe "with invalid params"  do
      it "assigns the writing as @writing" do
        
        # Trigger the behavior that occurs when invalid params are submitted
        Writing.any_instance.stub(:save).and_return(false)
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {}}, valid_session
        assigns(:writing).should eq(@w)
      end

      it "re-renders the 'edit' template" do
        
        # Trigger the behavior that occurs when invalid params are submitted
        Writing.any_instance.stub(:save).and_return(false)
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    
    before(:each) do
      @w = mock_model(Writing)
      Writing.stub(:find).and_return(@w)
    end


    it "destroys the requested writing" do
      @w.should_receive(:destroy).and_return true
      delete :destroy, {book_id:@b.to_param, :id => @w.to_param}, valid_session
    end

    it "redirects to the writings list" do
      @w.stub(:destroy).and_return true
      delete :destroy, {book_id:@b.to_param, :id => @w.to_param}, valid_session
      response.should redirect_to(compta_book_writings_url(@b))
    end
  end

end
