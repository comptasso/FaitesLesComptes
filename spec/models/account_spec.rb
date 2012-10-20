# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
 # config.filter =  {wip:true}
end


describe Account do   
  include OrganismFixture 

  before(:each) do
    create_minimal_organism
  end
  
   describe 'solde initial'  do

    before(:each) do
      @acc1 = Account.create!({number:'100', title:'Capital', period_id:@p.id})
      @acc2 = Account.create!({number:'5201', title:'Banque', period_id:@p.id})
      Writing.create!(book_id:@od.id, date:Date.today.beginning_of_year, narration:'ecriture d od',
        :compta_lines_attributes=>{'0'=>{account_id:@acc1.id, credit:1000},
          '1'=>{account_id:@acc2.id, debit:1000}})
    end

    it 'sans exercice précédent, et sans report à nouveau, zero' do
      @acc1.init_sold_debit.should == 0
      @acc1.init_sold_credit.should == 0 
    end
    
    context 'avec report à nouveau' do
      
      
      before(:each) do
        Writing.create!(book_id:@o.an_book.id, date:Date.today.beginning_of_year, narration:'ecriture d an',
          :compta_lines_attributes=>{'0'=>{account_id:@acc1.id, credit:66},
            '1'=>{account_id:@acc2.id, debit:66}})
      end

      it 'sans exercice précédent et avec RAN, donne ce montant' do
        @acc1.init_sold_debit.should == 0
        @acc1.init_sold_credit.should == 66
      end


    

    context 'avec exercice précédent clos' , wip:true do

      before(:each) do
        eve = @p.start_date - 1
        @p.stub(:previous_period?).and_return true
        Period.any_instance.stub(:previous_period).and_return @pp = mock_model(Period, close_date:eve)
        Period.any_instance.stub(:previous_period_open?).and_return false
        @pp.stub(:accounts).and_return @arel = double(Arel)

      end

       it 'avec exercice précédent clos, prend le report à nouveau' do
           @acc1.init_sold_debit.should == 0
            @acc1.init_sold_credit.should == 66
          end
    end

    end
    
    context 'avec exercice précédent ouvert'    do

      before(:each) do
        eve = @p.start_date - 1
        @p.stub(:previous_period?).and_return true
        Period.any_instance.stub(:previous_period).and_return @pp = mock_model(Period, close_date:eve)
        Period.any_instance.stub(:previous_period_open?).and_return true
        @pp.stub(:accounts).and_return @arel = double(Arel)
        
      end

      it 'doit être vrai' do
        @p.previous_period.should == @pp
        @acc1.period.previous_period.should == @pp
      end

         

      it 'avec exercice précédent non clos, prend le solde debit du compte' do
        @arel.should_receive(:find_by_number).with(@acc1.number).and_return(@acc3  = mock_model(Account))
        @acc3.should_receive(:cumulated_debit_at).with(@pp.close_date).and_return 0
        @acc1.init_sold_debit.should == 0
      end

      it 'avec exercice précédent non clos, prend le solde credit du compte'  do
        @arel.should_receive(:find_by_number).with(@acc1.number).and_return(@acc3  = mock_model(Account))
        @acc3.stub(:cumulated_credit_at).with(@pp.close_date).and_return 152
        @acc1.init_sold_credit.should == 152
      end
    
      it 'cas où il n y a pas de compte correspondant' do
         @arel.should_receive(:find_by_number).with(@acc1.number).and_return nil
        
        @acc1.init_sold_credit.should == 0
      end

    end

  
  end





  it "un account non valide peut être instancié" do
    Account.new.should_not be_valid
  end

  def valid_attributes
    {number:'601',
      title:'Titre du compte',
      period_id:@p.id
    }
  end

  describe 'validations' do

    before(:each) do
      @account = Account.new(valid_attributes)
      puts @account.errors.messages unless @account.valid?
    end
  
    it "should be valid"  do
      @account.should be_valid
    end

    describe 'should not be valid lorsque' do

      it 'sans number' do
        @account.number = nil
        @account.should_not be_valid
      end

      it 'sans title' do
        @account.title =  nil
        @account.should_not be_valid
      end

      it 'sans exercice' do
        @account.period = nil
        @account.should_not be_valid
      end
    end
  end

  describe 'polymorphic' do
    it 'la création d\'une caisse entraîne celle d\'un compte' do
      @ba.should have(1).accounts
    end

    it 'la création d\'une caisse entraîne celle d\'un compte' do
      @c.accounts.length.should == 1 
    end
  end



  describe 'all_lines_locked?' do

    it 'vrai si pas de lignes' do
      Account.new(valid_attributes).should be_all_lines_locked
    end

    context 'avec des lignes' do 
      
    
      before(:each) do
        @account = Account.create!(valid_attributes)
        @n.account_id = @account.id
        @n.save!
        @l1 = create_outcome_writing(97)
        @l2 = create_outcome_writing(3)

      end

      it 'faux si des lignes dont au moins une n est pas locked' do
        @account.should_not be_all_lines_locked
      end
    
      it 'false si une ligne est unlocked' do
        @l1.lock
        @account.should_not be_all_lines_locked
      end

      it 'true si toutes les lignes sont locked' do
        @l1.lock
        @l2.lock
        @account.should be_all_lines_locked
      end
    end

  end

  describe 'fonctionnalités natures' do
    before(:each) do
      @account = Account.create!(valid_attributes)
      @n.account_id = @account.id
      @n.save!
    end

    it 'un compte peut avoir des natures' do
      @account.should have(1).natures
    end
    
   
  end

 

  
end 

