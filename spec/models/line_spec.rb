# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
  # config.filter = {wip:true}
end


describe Line do
  include OrganismFixture 
  
  before(:each) do 
    create_minimal_organism 
  end

  describe "creation de ligne" do

    before(:each) do
      @l=Line.new(:book_id=>@ib.id, :credit=>200 ,:narration=>'ligne de test',
        :line_date=>Date.civil(2012,01,02), :nature_id=>@n.id, :payment_mode=> 'Espèces', :counter_account_id=>987)
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

    # TODO, ceci n'est plus vrai pour tous les types de lignes
    it 'doit avoir une nature_id sauf si account_id est rempli' do
      # une ligne de recettes mais sans nature
      @l.nature_id = nil
      @l.should_not be_valid
      # une ligne d'OD
      
      @l=Line.new(:account_id=>1, :book_id=>@od.id, :credit=>200 ,:narration=>'ligne de test',
        :line_date=>Date.civil(2012,01,02), :payment_mode=> 'Espèces', counter_account_id:7)
      @l.should be_valid
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
        check_deposit_id: nil, owner_id: 12, owner_type: "Transfer", account_id:7)
    end

    it 'should be valid even without a nature' do
      @m.valid?
      @m.should be_valid
    end
  end

 


  context "vérification des lignes et des soldes sur quelques mois" do

    before(:each) do
      
      10.times {|t| Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit',counter_account_id:@c.id, :payment_mode=> 'Espèces',  :line_date=>Date.civil(2012,01,t+2), :credit=>2*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ob.id, :narration=>'premier mois debit', counter_account_id:@c.id, :payment_mode=> 'Espèces', :line_date=>Date.civil(2012,01,t+2), :debit=>t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ib.id, :narration=>'deuxième mois debit', counter_account_id:@c.id, :payment_mode=> 'Espèces', :line_date=>Date.civil(2012,02,t+2), :credit=>3*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ob.id, :narration=>'deuxième mois credit', counter_account_id:@c.id, :payment_mode=> 'Espèces', :line_date=>Date.civil(2012,02,t+2), :debit=>2*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ib.id, :narration=>'troisième mois debit', counter_account_id:@c.id, :payment_mode=> 'Espèces', :line_date=>Date.civil(2012,03,t+2), :credit=>4*t+1 , :nature_id=>@n.id) }
      10.times {|t| Line.create(:book_id=>@ob.id, :narration=>'troisième mois credit', counter_account_id:@c.id, :payment_mode=> 'Espèces', :line_date=>Date.civil(2012,04,t+2), :debit=>5*t+1 , :nature_id=>@n.id) }

    end
    context 'verification que les lignes sont bien là' do

     
      it "vérif qu on a bien 2 lignes par écritures donc 120 pour les 60 instructions" do
        Line.count.should == 120
      end

      it 'income and outcomme should each have 60 lines' do
        @ib.lines.should have(60).elements
        @ob.lines.should have(60).elements
      end



      it "scope month return the right number of lines" do
        Line.month('01-2012').should have(40).elements
      end
    end
  end

  describe 'ligne de contrepartie' , wip:true do
    
    def valid_attributes
      {:book_id=>@ib.id, :narration=>'premier mois credit', 
          :payment_mode=> 'Espèces',  :line_date=>Date.today,
          :credit=>2.50 , :nature_id=>@n.id, :counter_account_id=>@c.id}
    end

    it 'la création d une ligne crée une writing' do
      expect { Line.create!(valid_attributes)}.to change {Writing.count}.by(1)
    end

    it 'writing porte la date, la réf et la narration' do
      l = Line.create!(valid_attributes)
      w = l.writing
      w.ref.should == l.ref
      w.narration.should == l.narration
      w.date.should == l.line_date
    end

    it 'la création d une ligne en crée une deuxième de contrpartie' do
      expect { Line.create!(valid_attributes)}.to change {Line.count}.by(2)
    end

    context 'avec une lignes créée' do

      before(:each) do
        @l = Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit',
          :payment_mode=> 'Virement',  :line_date=>Date.today,
          :credit=>2.50 , :nature_id=>@n.id, :counter_account_id=>@ba.current_account(@p).id)
      end

      it 'La ligne créée connait sa contrepartie' do
   
        @l.children.count.should == 1
        @l.children.first.should be_an_instance_of(Line)
        @l.supportline.should == @l.children.first
      end

      it 'supportline renvoie self si c est déja une supportline' do
        sl = @l.supportline
        sl.supportline.should == sl
      end

      it 'la ligne enfant connaît son parent' do
    
        c = @l.supportline
        c.owner.should == @l
      end

      it 'is able to retrieve support' do
         @l.support.should == 'DX 123Z'
      end

      it 'la contreligne est dans le même livre'  do
        @l.supportline.book.should be_an_instance_of(@ib.class)
      end

      describe 'editable' do

        it 'ligne editable si pas pointée et pas locked' do
          @l.should be_editable
        end

        it 'la ligne n est pas editable si pointed' do
          be = @ba.bank_extracts.create!(begin_sold:0, total_debit:10, total_credit:20,
          begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month)
        bel = be.bank_extract_lines.new
        bel.lines <<  @l.supportline
        bel.save!
        @l.should_not be_editable
        end

        it 'la ligne n est pas editable si locked' do
          @l.stub(:pointed?).and_return(true)
          @l.should_not be_editable
        end


      end
   

    describe 'pointed?'  do
      it ' vrai lorsque la supportline est reliée à une bank_extract_line' do
        be = @ba.bank_extracts.create!(begin_sold:0, total_debit:10, total_credit:20,
          begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month)
        bel = be.bank_extract_lines.new
        bel.lines <<  @l.supportline
        bel.save!
        @l.should be_pointed
      end

      it 'faux lorsque la supportline n est pas reliée à une bel' do
        @l.stub_chain(:support_line, :bank_extract_lines, :empty?).and_return(false)
        @l.should_not be_pointed
      end

      describe 'cas particulier ou la ligne est une recette par chèque'  do

          before(:each) do
            @l2 = Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit',
          :payment_mode=> 'Chèque',  :line_date=>Date.today,
          :credit=>2.50 , :nature_id=>@n.id, :counter_account_id=>@ba.current_account(@p).id)
          end

        it ' vrai lorsque le chèque est dans une remise de chèque' do
        cd  =  @ba.check_deposits.new(deposit_date:Date.today, checks:[@l2.supportline])
        cd.save
        @l2.should be_pointed
      end

      it 'faux si le chèque na pas été remis' do


        @l2.should_not be_pointed
      end

      end

    end
     end
  end

  
  
  describe 'before_save' do
    
    before(:each) do
      @a = @p.accounts.find_by_number('60')
    end
    
    it 'si nature est rattachée à un compte alors le compte est associé' do 
      @n.update_attribute(:account_id, @a.id )
      @l = Line.new(:book_id=>@ib.id, :narration=>'premier mois credit',
        :payment_mode=> 'Espèces',  :line_date=>Date.today,
        :credit=>2.50 , :nature_id=>@n.id, counter_account_id:@c.current_account(@p).id)
      @l.save
      @l.account.should == @a 
    end

    it 'si nature est rattaché après'  do 
      @l = Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit', 
        :payment_mode=> 'Espèces',  :line_date=>Date.today,
        :credit=>2.50 , :nature_id=>@n.id, :counter_account_id=>@c.current_account(@p).id)
      @n.account_id = @a.id
      @n.save! 
      # il faut recharger l'instance pour tester le changement de nature
      l = Line.find_by_credit(2.50)
      l.account.should == @a
    end
    
    describe 'Remise de chèques'  do
      
      before(:each) do
        @n = @p.natures.create!(name:'Vente', income_outcome:true)
        @l = Line.new(:book_id=>@ib.id, :narration=>'premier mois credit',
          :payment_mode=> 'Chèque',  :line_date=>Date.today,
          :credit=>2.50 , :nature_id=>@n.id, :counter_account_id=>@c.current_account(@p).id)
      end

      it 'ecrit la contreligne' do
        expect {@l.save}.to change {Line.count}.by(2)
      end

      it 'la contreligne a pour numéro de compte rem_check_account' do
        @l.save
        @l.supportline.account.should == @p.rem_check_account
      end

    end
  end



  describe 'une ligne verrouillée ne peut être détruite' do

    before(:each) do
      @l = Line.create!(:book_id=>@ib.id, :narration=>'premier mois credit',
        :payment_mode=> 'Espèces',  :line_date=>Date.today,
        :credit=>2.50 , :nature_id=>@n.id,  :counter_account_id=>@c.accounts.first.id)
    end


    it 'a line locked cant be destroyed' do
      @l.update_attribute(:locked, true)
      expect {@l.destroy }.not_to change {Line.count}
    end

  end

 
end

