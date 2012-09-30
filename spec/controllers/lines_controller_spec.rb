# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe LinesController do
  include SpecControllerHelper 

 before(:each) do
    minimal_instances
    @b = mock_model(Book)
    Book.stub(:find).with(@b.id.to_s).and_return @b

  end

  describe 'before_filters' do 

    it 'A faire '
  end
  
  describe 'GET index' do

    before(:each) do
      @p.stub_chain(:list_months, :include?).and_return true
    end

    it 'should assign o' do
      get :index , {:outcome_book_id=>@b.id, mois:'04', an:'2012'}, {user:@cu.id, period:@p.id, org_db:'test'}
      assigns(:organism).should == @o
      assigns(:period).should == @p
      assigns(:book). should == @b
    end

    it "should render index view" do
      get :index,{:outcome_book_id=>@b.id, mois:'04', an:'2012'}, {user:@cu.id, period:@p.id, org_db:'test'}
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      my = MonthYear.from_date(Date.today)
      @p.stub(:guess_month).and_return my
      get :index,{ :outcome_book_id=>@b.id}, {user:@cu.id, period:@p.id, org_db:'test'}
      response.should redirect_to(book_lines_path(@b, :mois=>my.month, :an=>my.year))
    end

    it 'traiter le cas ou on change de period suite à un clic sur une ligne du graphe'
  
  end

  describe 'GET edit'  do
    before(:each) do
      @l = mock_model(Line)
      
    end

    it 'should look_for the line' do
      @b.should_receive(:lines).and_return a = double(Arel)
      a.should_receive(:find).with(@l.id.to_s).and_return @l
      get :edit, {:income_book_id=>@b.id, :id=>@l.id}, {user:@cu.id, period:@p.id, org_db:'test'}

    end

    it "should assign the line" do
      @b.stub_chain(:lines, :find).and_return(@l)
      get :edit, {:income_book_id=>@b.id, :id=>@l.id}, {user:@cu.id, period:@p.id, org_db:'test'}
      assigns[:book].should == @b
      assigns[:line].should == @l
    end

    it "should render edit" do
      @b.stub_chain(:lines, :find).and_return(@l)
      get :edit, {:income_book_id=>@b.id, :id=>@l.id}, {user:@cu.id, period:@p.id, org_db:'test'}
      response.should render_template(:edit)
    end
  end

  
  describe 'POST update'do
    before(:each) do
      @l = mock_model(Line, line_date:Date.today)
      @b.stub_chain(:lines, :find).and_return(@l)
    end

    it 'redirige en cas de succès de la sauvegarde' do
      
      @l.should_receive(:update_attributes).with( {"narration"=>'libellé corrigé'}).and_return(true)
      put :update,  {:income_book_id=>@b.id, :id=>@l.id, line: {narration: 'libellé corrigé'} }, {user:@cu.id, period:@p.id, org_db:'test'}
      my = MonthYear.from_date(Date.today)
      response.should redirect_to book_lines_path(@b, my.to_french_h)
    end

    it 'render edit en cas d échec de la sauvegarde' do
      
      @l.should_receive(:update_attributes).with( {"narration"=>'libellé corrigé'}).and_return(false)
      put :update,  {:income_book_id=>@b.id, :id=>@l.id, line: {narration: 'libellé corrigé'} }, {user:@cu.id, period:@p.id, org_db:'test'}
      response.should render_template 'edit'
    end
  end

  
  

  describe 'POST delete'  do
    before(:each) do
      @l = mock_model(Line, line_date:Date.today)
      @b.stub_chain(:lines, :find).and_return(@l)
      @my = MonthYear.from_date(Date.today)
    end

    it 'appelle la méthode destroy sur la ligne' do
      @l.should_receive(:destroy).and_return true
      get :destroy,{:outcome_book_id=>@b.id, :id=>@l.id,  :method=>:delete}, {user:@cu.id, period:@p.id, org_db:'test'}
    end

    it 'renvoye sur la table des écritures du mois' do
      @l.should_receive(:destroy).and_return true
      get :destroy,{:outcome_book_id=>@b.id, :id=>@l.id,  :method=>:delete}, {user:@cu.id, period:@p.id, org_db:'test'}
      response.should redirect_to(book_lines_path(:book_id=>@b.id, :mois=>@my.month, :an=>@my.year) )
    end

    it 'cas où la suppression échoue'
  end
 
  describe 'POST create'  do

    def parameters
      { "nature_id"=>'1',  "line_date_picker"=>'18/04/2012',  "narration"=>'ligne valide', "credit"=>'25.00', "payment_mode"=>'Chèque',
        "counter_account_id"=>'1'} 
    end

    before (:each) do
      @nl = mock_model(Line, line_date:Date.civil(2012,4,18)).as_new_record # pour new line
      @my = MonthYear.from_date(Date.civil(2012,4,18))
    end

    context "post successful" do
      it "creates a line" do
        @b.stub(:lines).and_return a =double(Arel)
        a.should_receive(:new).with(parameters).and_return(@nl)
        @nl.should_receive(:save).and_return true
        post :create, { :income_book_id=>@b.id,
          :line=>parameters, commit: 'Créer' }, session_attributes
        assigns(:line).should == @nl
      end

      it "reçoit save" do
        @b.stub_chain(:lines, :new).and_return @nl
        @nl.should_receive(:save).and_return true
        post :create, { :income_book_id=>@b.id,
          :line=>parameters, commit: 'Créer' }, session_attributes
      end

      context 'after_save' do
        before(:each) do
          @b.stub_chain(:lines, :new).and_return @nl
        end

        it 'succès -> remplit les flashs' do
          @nl.stub(:save).and_return(true)
          post :create, { :income_book_id=>@b.id,
            :line=>parameters, commit: 'Créer' }, session_attributes
          assigns(:line).should == @nl
          flash[:previous_line_id].should ==  @nl.id
          flash[:date].should == @nl.line_date
        end

        it 'succès -> redirige pour une nouvelle saise' do
          @nl.stub(:save).and_return(true)
          post :create, { :income_book_id=>@b.id,
            :line=>parameters, commit: 'Créer' }, session_attributes
          response.should redirect_to (new_book_line_path(:book_id=>@b.id, :mois=>@my.month, :an=>@my.year) )
        end

        it 'echec -> rend new' do
          @nl.stub(:save).and_return(false)
          post :create, { :income_book_id=>@b.id,
            :line=>parameters, commit: 'Créer' }, session_attributes
          response.should render_template 'new'
        end

      end

     
    end
  end

  describe 'Get new'   , :wip=>true do

    before(:each) do
      @o.stub(:main_cash_id).and_return(11)
      @o.stub(:main_bank_id).and_return(12)
      @b.stub(:lines).and_return @a = double(Arel)
      @nl = mock_model(Line).as_new_record
    end
    
    it "fill the default values"  do
      @a.should_receive(:new).with(line_date:Date.civil(2012,4,1))
      get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes
    end

    it 'assigns line' do
      @b.stub_chain(:lines, :new).and_return(@nl)
      get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes
      assigns(:line).should == @nl
    end

    context 'Avec une ligne créée précédemment' do

      it 'assigns previous line if one' do 
        @b.stub_chain(:lines, :new).and_return(@nl)
        
        Line.should_receive(:find_by_id).with(20).and_return(@l = mock_model(Line, counter_account_id:1, payment_mode:'Virement'))
        @nl.stub(:payment_mode=)
        @nl.stub(:counter_account_id=)
        get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes, :previous_line_id=>20
        assigns(:line).should == @nl
        assigns(:previous_line).should == @l
      end
    

      it 'new line date est préremplie' do
        @a.should_receive(:new).with(:line_date=>Date.today)
        get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes, :date=>Date.today
      end

     
    end


  end
end

