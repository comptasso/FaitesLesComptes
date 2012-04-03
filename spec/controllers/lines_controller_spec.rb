# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LinesController do
   include OrganismFixture
  
  before(:each) do 
    # méthode définie dans OrganismFixture et 
    # permettant d'avoir les variables d'instances @organism, @period, 
    # income et outcome book ainsi qu'une nature
    create_minimal_organism   
  end

  describe 'GET index' do
    it "should find the right book" do
     # controller.should_receive(:find_book)
      get :index, :outcome_book_id=>@ob.id, :mois=>4
      assigns[:book].should == @ob
    end

    it 'should assign organism' do
       get :index, :outcome_book_id=>@ob.id, :mois=>4
      assigns[:organism].should == @o
    end

    it "should call fill_soldes" do
      @controller.should_receive(:fill_soldes)
      get :index, :outcome_book_id=>@ob.id, :mois=>4
    end

    it "should call the filter" do
      @controller.should_not_receive(:fill_natures)
      @controller.should_receive(:change_period)
      get :index, :outcome_book_id=>@ob.id, :mois=>4
    end

    it "date doit être rempli" do
      get :index, :outcome_book_id=>@ob.id, :mois=>4
      assigns[:date].should == Date.civil(2012,5,1)
    end
  end

  describe 'GET edit' do
    before(:each) do
      @l=@ib.lines.create!(:line_date=>Date.today,narration: 'libellé test', credit: 25,:nature_id=>@n.id, payment_mode: 'Chèque', bank_account_id: @ba.id)
    end

    it "should assign the line" do
      get :edit, :income_book_id=>@ib.id, :id=>@l.id
      assigns[:book]=@ib
      assigns[:line]=@l
    end


  end

  



  describe 'POST delete' do 
    before(:each) do
      @l= @ob.lines.create!(:line_date=>Date.civil(2012,02,25), :debit=>12.54, :narration=>'dépense erronnée à annuler', :nature_id=>@n.id,
        :payment_mode=>'Chèque', :bank_account_id=>@ba.id)
    end

    it 'delete doit retirer la ligne' do
      expect {get :destroy, :outcome_book_id=>@ob.id, :id=>@l.id,  :method=>:delete}.to change {Line.count}.by(-1)
    end

    it 'doit revoyer sur la table des écritures du mois' do
      get :destroy, :outcome_book_id=>@ob.id, :id=>@l.id,  :method=>:delete
      response.should redirect_to(book_lines_path(:book_id=>@ob.id, :mois=>1))
    end
  end

 describe 'POST create' do
   context "post successful" do
     it 'fill a previous_line_id flash whenline is saved' do
       post :create, :income_book_id=>@ib.id,:pick_date_line=>'01/04/2012',
         :line=>{ :nature_id=>@n.id,    :narration=>'ligne valide', :credit=>25.00, :payment_mode=>'Chèque',
       :bank_account_id=>@ba.id}, commit: 'Créer'
       flash[:previous_line_id].should ==  Line.order('id ASC').last.id
     end   
   end  
 end

   describe 'Get new' do
     it "fill the default values" do
       get :new, income_book_id: @ib.id, mois: 4
       assigns[:line].should be_an_instance_of(Line)
       assigns[:line].line_date.should == Date.civil(2012,5,1)
       assigns[:line].bank_account_id.should == @ba.id 
     end

    context 'Avec une ligne créée précédemment' do
      before(:each) do
        post :create, :income_book_id=>@ib.id,:pick_date_line=>'01/05/2012',
         :line=>{ :nature_id=>@n.id,    :narration=>'ligne valide pour tester le flash de previous line', :credit=>25.00, :payment_mode=>'Chèque',
       :bank_account_id=>@ba.id}, commit: 'Créer'
      end

      it 'new line date est préremplie' do
        get :new, income_book_id: @ib.id, mois: 4
        assigns[:line].line_date.should == Date.civil(2012,5,1)
      end

      it 'previous line existe' do
        flash[:previous_line_id].should_not be_nil
        get :new, income_book_id: @ib.id, mois: 4
        assigns[:previous_line].should == Line.find(flash[:previous_line_id])
      end
    end


   end
end

