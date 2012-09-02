# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
  config.filter = {wip:true}
end


describe Line do
  include OrganismFixture 
  
  before(:each) do 
    create_minimal_organism 
  end

  describe "creation de ligne" do

    before(:each) do
      @l=Line.new(:book_id=>@ib.id, :credit=>200 ,:narration=>'ligne de test',
        :line_date=>Date.civil(2012,01,02), :nature_id=>@n.id, :payment_mode=> 'Espèces')
    end

    it "should be valid" do
      @l.should be_valid
    end

    it "should not be valid without payement_mode" do
      @l.payment_mode=nil
      @l.should_not be_valid
    end

    it "payment mode should be a valid word" do
      @l.payment_mode = 'bonjour'
      @l.should_not be_valid
    end

    it "should not be valid whitout narration" do
      @l.narration = nil
      @l.should_not be_valid
    end 

   
    it 'should have a line_date' do
      @l.line_date=nil
      @l.should_not be_valid
    end

    it 'debit credit doivent être des nombres avec deux décimales maximum' do
      @l.should_not be_valid if @l.credit = 2.321
      @l.should be_valid if @l.credit=2.32
      @l.should be_valid if @l.credit=-502.32 
    end

    it 'si les données rentrées ne sont pas des chiffres tronque les infos' do
      @l.credit= '54a2.01'
      @l.valid? 
      @l.credit.should == 54
    end

    it 'debit ou credit ne peuvent être tous les deux à zero' do
      @l.credit=@l.debit=0
      @l.should_not be_valid
    end

    it 'doit avoir une nature_id' do
      @l.nature_id=nil
      @l.should_not be_valid
    end

    it 'débit et crédit ne doivent pas être simultanément remplis' do
      @l.debit=20; @l.credit = 180
      @l.should_not be_valid 
    end

    it 'line_date doit correspondre à un exercice' do 
      @l.line_date=Date.civil(1999,01,01)
      @l.should_not be_valid
    end
    it 'une ligne ne peut être écrite dans un exercice fermé' do
      p=stub_model(Period, start_date: Date.civil(2011,01,01),close_date: Date.civil(2011,12,31), locked: true)
      @l.line_date= Date.civil(2011,03,15)
      @l.should_not be_valid
    end

    it "should belongs to a book" do
      @l.book_id=nil; @l.should_not be_valid
    end

    describe 'attribut virtuel line_date_picker' do
      it 'should answer to line_date_picker' do
        @l.line_date_picker.should == '02/01/2012'
      end

      it "should answer to line_date_picker=" do
        @l.line_date_picker = '03/04/2012'
        @l.line_date.should == Date.civil(2012,4,3)
      end

      context "when date is invalid" do
        it "doesn't raise error but add error to model" do
          @l.line_date_picker = '31/04/2012'
          @l.valid?
          @l.should have(1).errors_on(:line_date)
          @l.should have(1).errors_on(:line_date_picker)
        end
      end
    end

    it 'line and book should be coherent' # un livre de recettes avec des crédits et un livre de dépenses avec des débits
  end

  describe "création d'une ligne de type transfer" do

    before(:each) do
      @m = Line.new(line_date: "2012-02-22", narration: "retrait", nature_id: nil,
        destination_id: nil, debit: 50,  credit: 0,
        book_id: @od.id, locked: false, bank_extract_id: nil, payment_mode: nil,
        check_deposit_id: nil, cash_id: nil, bank_account_id: 5,
        owner_id: 12, owner_type: "Transfer")
    end

    it 'should be valid even without a nature' do
      @m.valid?
      @m.should be_valid
    end
  end


  context "vérification des lignes et des soldes sur quelques mois" do

    before(:each) do
      # la somme de 0 à 9 est égale à 45
      #    @l= Line.create(:book_id=>@ib.id, :line_date=>Date.civil(2012,01,2), :credit=>234, :nature_id=>@n.id)
      #    @l.valid?
      #    @l.errors.messages.should == {}
      #
      10.times {|t| Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit', :payment_mode=> 'Espèces',  :line_date=>Date.civil(2012,01,t+2), :credit=>2*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ob.id, :narration=>'premier mois debit',:payment_mode=> 'Espèces', :line_date=>Date.civil(2012,01,t+2), :debit=>t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ib.id, :narration=>'deuxième mois debit',:payment_mode=> 'Espèces', :line_date=>Date.civil(2012,02,t+2), :credit=>3*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ob.id, :narration=>'deuxième mois credit',:payment_mode=> 'Espèces', :line_date=>Date.civil(2012,02,t+2), :debit=>2*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ib.id, :narration=>'troisième mois debit',:payment_mode=> 'Espèces', :line_date=>Date.civil(2012,03,t+2), :credit=>4*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ob.id, :narration=>'troisième mois credit',:payment_mode=> 'Espèces', :line_date=>Date.civil(2012,04,t+2), :debit=>5*t+1 , :nature_id=>@n.id) }

    end
    context 'verification que les lignes sont bien là' do

      it "vérif qu on a bien les lignes" do
        Line.count.should == 60
      end

      it 'income and outcomme should each have 30 lines' do
        @ib.lines.should have(30).elements
        @ob.lines.should have(30).elements
      end

      it "scope month return the right number of lines" do
        Line.month('01-2012').should have(20).elements
      end
    end

 
  end
  
  describe 'before_save', wip:true do
    
    before(:each) do
      @a = Account.create(:period_id=>@p.id, number:'60', title:'compte test')
      @n.update_attribute(:account_id, @a.id )
    end
    
    
    it 'si nature est rattachée à un compte alors le compte est associé' do
      @l = Line.new(:book_id=>@ib.id, :narration=>'premier mois credit',
        :payment_mode=> 'Espèces',  :line_date=>Date.today,
        :credit=>2.50 , :nature_id=>@n.id)
      @l.save
      @l.account.should == @a
      
    end
    
    
    
  end



  describe 'une ligne verrouillée ne peut être détruite' do

    before(:each) do
      @l = Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit',
        :payment_mode=> 'Espèces',  :line_date=>Date.today,
        :credit=>2.50 , :nature_id=>@n.id)
    end


    it 'a line locked cant be destroyed' do
      @l.update_attribute(:locked, true)
      expect {@l.destroy }.not_to change {Line.count}
      
    end

  end

 
end

