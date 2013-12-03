# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c| 
  # c.filter = {:wip=>true}
end

describe InOutWritingsController do
  include SpecControllerHelper

 before(:each) do
    minimal_instances
    @b = mock_model(Book)
    Book.stub(:find).with(@b.id.to_s).and_return @b
    @b.stub_chain(:organism, :find_period).and_return @p

  end

  describe 'before_filters' , wip:true do 
    # ici on fait les spec du filter change_if_has_changed_period

    before(:each) do
      @p.stub(:list_months).and_return([]) 
    end

    it 'doit redirigé vers la bonne vue ' do
      @o.stub(:guess_period).and_return(@p2 = mock_model(Period, :guess_month=>MonthYear.new(year:'2011', month:'04')))
      get :index , {:book_id=>@b.id, mois:'04', an:'2011'}, session_attributes
      flash[:alert].should == "Attention, vous avez changé d'exercice !"
      response.should redirect_to book_in_out_writings_url(@b, mois:'04', an:'2011')
    end

    it 'cas ou le monthyear demandé n existe pas' do
      request.env['HTTP_REFERER'] = 'localhost:3000/test'
      @o.stub(:guess_period).and_return nil
      get :index , {:book_id=>@b.id, mois:'04', an:'2011'}, session_attributes
      flash[:alert] = "Le mois et l'année demandés ne correspondent à aucun exercice"
      response.should redirect_to :back
    end
  end
  
  describe 'GET index' do

    before(:each) do
      @p.stub_chain(:list_months, :include?).and_return true
    end

    it 'should assign o'  do
      get :index , {:book_id=>@b.id, mois:'04', an:'2012'}, session_attributes
      assigns(:organism).should == @o
      assigns(:period).should == @p
      assigns(:book). should == @b 
    end

    it "should render index view" do
      get :index,{:outcome_book_id=>@b.id, mois:'04', an:'2012'}, session_attributes
      response.should render_template(:index)
    end

    it 'shoul render index view with params tous' do
      get :index,{:outcome_book_id=>@b.id, mois:'tous'}, session_attributes
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      my = MonthYear.from_date(Date.today)
      @p.stub(:guess_month).and_return my
      get :index,{ :outcome_book_id=>@b.id}, session_attributes
      response.should redirect_to(outcome_book_in_out_writings_path(@b, :mois=>my.month, :an=>my.year))
    end
  
  end

  describe 'GET edit'  do
    before(:each) do
      Book.stub(:find).and_return(@b)
      @w = mock_model(InOutWriting)
      request.env["HTTP_REFERER"] = 'http://period/1/in_out_writings'
   end

   

   

    it 'should look_for the line' do
      @b.should_receive(:in_out_writings).and_return a = double(Arel)
      a.should_receive(:find).with(@w.id.to_s).and_return @w
      @w.stub(:in_out_line).and_return mock_model(ComptaLine)
      @w.stub(:counter_line).and_return mock_model(ComptaLine)
      get :edit, {:income_book_id=>@b.id, :id=>@w.id}, session_attributes

    end

    it "should assign the writing" do
      @b.stub_chain(:in_out_writings, :find).and_return(@w)
      @w.stub(:in_out_line).and_return mock_model(ComptaLine)
      @w.stub(:counter_line).and_return mock_model(ComptaLine)
      get :edit, {:income_book_id=>@b.id, :id=>@w.id}, session_attributes
      assigns[:book].should == @b
      assigns[:in_out_writing].should == @w
    end

    it 'should assign line and counter_line' do
      @b.stub_chain(:in_out_writings, :find).and_return(@w)
      @w.should_receive(:in_out_line).and_return @l = mock_model(ComptaLine)
      @w.should_receive(:counter_line).and_return @cl = mock_model(ComptaLine)
      get :edit, {:income_book_id=>@b.id, :id=>@w.id}, session_attributes
      assigns[:line].should == @l
      assigns[:counter_line].should == @cl
    end

    it "should render edit" do
      @b.stub_chain(:in_out_writings, :find).and_return(@w)
      @w.stub(:in_out_line).and_return mock_model(ComptaLine)
      @w.stub(:counter_line).and_return mock_model(ComptaLine)
      get :edit, {:income_book_id=>@b.id, :id=>@w.id}, session_attributes
      response.should render_template(:edit)
    end
  end

  
  describe 'POST update', wip:true do

    def update_parameters
      {"narration"=>'libellé corrigé', 'compta_lines_attributes'=>{'0'=>{'debit'=>'12', 'credit'=>'0', 'payment_mode'=>'Virement'},
        '1'=>{'debit'=>'0', 'credit'=>'12', 'payment_mode'=>'Virement'}}}
    end

    before(:each) do
      @w = mock_model(InOutWriting, date:Date.today) 
      @b.stub_chain(:in_out_writings, :find).with(@w.to_param).and_return(@w)
      @w.stub(:in_out_line).and_return(mock_model(ComptaLine))
      @w.stub(:counter_line).and_return(mock_model(ComptaLine))
    end

    it 'redirige en cas de succès de la sauvegarde' do
      
      @w.should_receive(:update_attributes).with( update_parameters).and_return(true)
      put :update,  {:income_book_id=>@b.id, :id=>@w.id, :in_out_writing=>update_parameters}, session_attributes
      my = MonthYear.from_date(Date.today)
      response.should redirect_to book_in_out_writings_path(@b, my.to_french_h)
    end

    it 'render edit en cas d échec de la sauvegarde' do
      
      @w.should_receive(:update_attributes).with(update_parameters).and_return(false)
      put :update,  {:income_book_id=>@b.id, :id=>@w.id,  :in_out_writing=>update_parameters }, session_attributes
      response.should render_template 'edit'
    end
  end

  
  

  describe 'POST delete' do
    before(:each) do
      @w = mock_model(InOutWriting, date:Date.today)
      @b.stub_chain(:in_out_writings, :find).and_return(@w)
      @my = MonthYear.from_date(Date.today)
    end

    it 'appelle la méthode destroy sur la ligne' do
      @w.should_receive(:destroy).and_return true
      get :destroy,{:outcome_book_id=>@b.id, :id=>@w.id,  :method=>:delete}, session_attributes
    end

    it 'renvoye sur la table des écritures du mois' do
      @w.should_receive(:destroy).and_return true
      get :destroy,{:outcome_book_id=>@b.id, :id=>@w.id,  :method=>:delete}, session_attributes
      response.should redirect_to(book_in_out_writings_path(:book_id=>@b.id, :mois=>@my.month, :an=>@my.year) )
      flash[:notice].should == 'L\'écriture a été détruite'
    end

    it 'cas où la suppression échoue' do
      @w.should_receive(:destroy).and_return false
      get :destroy,{:outcome_book_id=>@b.id, :id=>@w.id,  :method=>:delete}, session_attributes
      response.should redirect_to(book_in_out_writings_path(:book_id=>@b.id, :mois=>@my.month, :an=>@my.year) )
      flash[:notice].should == nil
      flash[:alert].should == 'Une anomalie est survenue, l\'écriture n\'a pu être détruite'
    end
  end
 
  describe 'POST create'  do

    def create_parameters
      {"narration"=>'linellé corrigé', 'compta_lines_attributes'=>{'0'=>{'debit'=>'12', 'credit'=>'0', 'payment_mode'=>'Virement'},
        '1'=>{'debit'=>'0', 'credit'=>'12', 'payment_mode'=>'Virement'}}}
    end

    before (:each) do
      @nw = mock_model(InOutWriting, date:Date.civil(2012,4,18)).as_new_record # pour new line
      @my = MonthYear.from_date(Date.civil(2012,4,18))
      @iol = mock_model(ComptaLine)
      @cl = mock_model(ComptaLine)
    end

    context "post successful" do
      it "creates a writing" do
        @b.stub(:in_out_writings).and_return a =double(Arel)
        a.should_receive(:build).with(create_parameters).and_return(@nw)
        @nw.should_receive(:in_out_line).and_return @iol
        @nw.should_receive(:counter_line).and_return @cl
        @nw.stub(:save).and_return true
        post :create, { :income_book_id=>@b.id,
          :in_out_writing=>create_parameters, commit: 'Créer' }, session_attributes
        assigns(:in_out_writing).should == @nw
        assigns(:line).should == @iol
        assigns(:counter_line).should == @cl
      end

      it "reçoit save" do
        @b.stub_chain(:in_out_writings, :build).and_return @nw
        @nw.stub(:in_out_line).and_return @iol
        @nw.stub(:counter_line).and_return @cl
        @nw.should_receive(:save).and_return true
        post :create, { :income_book_id=>@b.id,
          :in_out_writing=>create_parameters, commit: 'Créer' }, session_attributes
      end

      context 'after_save' do
        before(:each) do
          @b.stub_chain(:in_out_writings, :build).and_return @nw
          @nw.stub(:in_out_line).and_return @iol
          @nw.stub(:counter_line).and_return @cl
        end

        it 'succès -> remplit les flashs' do
          @nw.stub(:save).and_return(true)
          post :create, { :income_book_id=>@b.id,
            :in_out_writing=>create_parameters, commit: 'Créer' }, session_attributes
          assigns(:in_out_writing).should == @nw
          flash[:previous_line_id].should ==  @iol.id
          flash[:date].should == @nw.date
        end

        it 'succès -> redirige pour une nouvelle saise' do
          @nw.stub(:save).and_return(true)
          post :create, { :income_book_id=>@b.id,
            :in_out_writing=>create_parameters, commit: 'Créer' }, session_attributes
          response.should redirect_to (new_book_in_out_writing_path(:book_id=>@b.id, :mois=>@my.month, :an=>@my.year) )
        end

        it 'echec -> rend new' do
          @nw.stub(:save).and_return(false)
          post :create, { :income_book_id=>@b.id,
            :in_out_writing=>create_parameters, commit: 'Créer' }, session_attributes
          response.should render_template 'new'
        end

      end

     
    end
  end

  describe 'Get new'      do

    before(:each) do
      @o.stub(:main_cash_id).and_return(11)
      @o.stub(:main_bank_id).and_return(12)
      @b.stub(:in_out_writings).and_return @a = double(Arel)
      @nw = mock_model(InOutWriting, date:Date.civil(2012,4,1)).as_new_record
      @d = Date.today
    end
    
    it "fill the default values"  do
      @a.should_receive(:new).with(date:@d).and_return(@nw)
      @nw.stub_chain(:compta_lines, :build) 
      get :new, {income_book_id: @b.id, :mois=>@d.month.to_s, :an=>@d.year.to_s}, session_attributes
    end

    it "should build 2 compta_lines" do
      @a.stub(:new).and_return(@nw)
      @nw.should_receive(:compta_lines).exactly(2).times.and_return @ar = double(Arel)
      @ar.should_receive(:build).exactly(2).times
      get :new, {income_book_id:@b.id, :mois=>'04', :an=>'2012'}, session_attributes, :previous_line_id=>nil
    end

    it 'assigns writing and compta_lines' do
      @b.stub_chain(:in_out_writings, :new).and_return(@nw)
      @nw.stub_chain(:compta_lines, :build).and_return @cl1 = mock_model(ComptaLine)
      get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes
      assigns(:in_out_writing).should == @nw
      assigns(:line).should == @cl1
      assigns(:counter_line).should == @cl1
    end

    context 'Avec une ligne créée précédemment' do

      it 'assigns previous line if one' do 
        @b.stub_chain(:in_out_writings, :new).and_return(@nw)
        @nw.stub_chain(:compta_lines, :build).and_return(@cl1 = mock_model(ComptaLine))


        ComptaLine.should_receive(:find_by_id).with(20).and_return(@l = mock_model(ComptaLine, payment_mode:'Virement'))
        @cl1.should_receive(:payment_mode=).with('Virement')
        
        
        get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes, :previous_line_id=>20
        assigns(:in_out_writing).should == @nw
        assigns(:previous_line).should == @l
      end
    

      it 'new date est préremplie' do
        @a.should_receive(:new).with(:date=>Date.today).and_return @nw
        @nw.stub_chain(:compta_lines, :build)
        get :new, {income_book_id: @b.id, :mois=>'04', :an=>'2012'}, session_attributes, :date=>Date.today
      end

     
    end
    
    context 'quand on vient d un affichage avec tous les mois' do
      it 'rend le template new' do
        @a.should_receive(:new).with(:date=>Date.today).and_return @nw
        @nw.stub_chain(:compta_lines, :build)
        get :new, {income_book_id: @b.id, :mois=>'tous'}, session_attributes
        response.should render_template('new')
      end
    end


  end
end

