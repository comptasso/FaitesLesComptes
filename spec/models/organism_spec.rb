# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|  
  #  c.filter = {:js=> true }
  #  c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true } 
end

describe Organism do
  include OrganismFixtureBis 


  def valid_attributes   
    {:title =>'Test ASSO',
      database_name:'assotest',
      :status=>'Association'
    }
  end


  describe 'validations' do
    before(:each) do
      clean_organism
      Apartment::Database.switch(SCHEMA_TEST)
      @o= Organism.new valid_attributes
      puts @o.errors.messages unless @o.valid?
    end

    it 'should be valid with a title and a database_name' do
      @o.should be_valid
    end

    it 'should not be valid without title' do
      @o.title = nil
      @o.should_not be_valid
    end

    it 'should not be valid without status' do
      @o.status= nil
      @o.should_not be_valid
    end

    it 'before_validation remplit la version avec la constante VERSION' do
      @o.valid?
      @o.version.should == FLCVERSION
    end

    

  end


  describe 'can_write_line'  do

    before(:each) do
      
      @o= Organism.new(valid_attributes)
    end

    it 'pour pouvoir écrire une compta, il faut un compte bancaire ou une caisse et un income ou outcome book' do
      @o.stub(:income_books).and_return([1])
      @o.can_write_line?.should be_false
      @o.stub(:bank_accounts).and_return([1])
      @o.can_write_line?.should be_true
     
    end

    it 'avec un outcome' do
      @o.stub(:outcome_books).and_return([1])
      @o.can_write_line?.should be_false
      @o.stub(:cashes).and_return([1])
      @o.can_write_line?.should be_true
    end

    it 'pour pouvoir écrire une compta, il faut un compte bancaire ou une caisse et un income ou outcome book' do
      @o.stub(:outcome_books).and_return([1])
      @o.can_write_line?.should be_false
      @o.stub(:bank_accounts).and_return([1])
      @o.can_write_line?.should be_true

    end

    it 'avec un outcome' do
      @o.stub(:income_books).and_return([1])
      @o.can_write_line?.should be_false
      @o.stub(:cashes).and_return([1])
      @o.can_write_line?.should be_true
    end


  end
  
  describe 'main_bank_id' do
    
    subject {Organism.new(valid_attributes)}
    
    it 'main_bank_id should returns the first one' do
      subject.should_receive(:bank_accounts).exactly(2).times.and_return(@ar = double(Arel, 'any?'=>true))
      @ar.should_receive(:order).with('id').and_return @ar
      @ar.should_receive(:first).and_return(double(BankAccount, id:999))
      subject.main_bank_id.should == 999
    end
          
    it 'ou nil si pas de compte bancaire' do
      subject.should_receive(:bank_accounts).and_return(@ar = double(Arel, 'any?'=>false))
      subject.main_bank_id.should == nil
    end
  end
  
  describe 'main_cash_id' do
    
    subject {Organism.new(valid_attributes)}
    
    it 'main_bank_id should returns the first one' do
      subject.should_receive(:cashes).exactly(2).times.and_return(@ar = double(Arel, 'any?'=>true))
      @ar.should_receive(:order).with('id').and_return @ar
      @ar.should_receive(:first).and_return(double(Cash, id:999))
      subject.main_cash_id.should == 999
    end
          
    it 'ou nil si pas de compte bancaire' do
      subject.should_receive(:cashes).and_return(@ar = double(Arel, 'any?'=>false))
      subject.main_cash_id.should == nil
    end
  end


  describe 'after create' do
    
    after(:each) do
        clean_organism
      end
    
    context 'une association'  do 
      before(:each) do
        clean_organism
        use_test_organism 
      end
      
      
      
      
      it 'on a tous les éléments' do
        @o.should have(4).books # 4 livres
        @o.should have(1).income_book
        @o.should have(1).outcome_book
        @o.should have(1).od_book
        @o.an_book.should be_an_instance_of(AnBook)
        @o.should have(1).cashes
        @o.should have(1).bank_accounts
      end

     
      it 'income_outcome_books renvoie les livres recettes et dépenses' do
        @o.in_out_books.should have(2).books
        @o.in_out_books.first.title.should == 'Recettes'
        @o.in_out_books.last.title.should == 'Dépenses'
      end

      it 'peut créer un document'  do
        Period.stub(:last).and_return(double(Period))
        Compta::Nomenclature.should_receive(:new).with(Period.last).and_return(@cn = double(Compta::Nomenclature))
        @cn.should_receive(:sheet).with(:actif)
        @o.document(:actif)
      end

      it 'n est pas accountable'  do
        @o.stub_chain(:periods, :select).and_return []
        @o.should_not be_accountable
      end

      it 'mais peut écrire des lignes' do
        @o.should be_can_write_line
      end

      
      
      describe 'bridge vers adherent' do
        
        before(:each) do
          Adherent::Bridge.any_instance.stub(:nature_coherent_with_book).and_return true
          @o.fill_bridge
          
        end
        
        it 'crée un bridge vers le module adhérent' do
          @o.bridge.should be_an_instance_of Adherent::Bridge
        end
        
        it 'avec les bonnes valeurs' do 
          b = @o.bridge
          b.bank_account = @o.bank_accounts.first
          b.cash = @o.cashes.first
          b.income_book = @o.income_books.first
          b.destination = @o.destinations.find_by_name('Adhérents')
          b.nature_name = 'Cotisations des adhérents'
          
        end 
      
      end
    end
    
    
    # TODO partie à transférer dans les tests des filler puisque cette interface
    # a été transformée en classe.
    context 'une non association' do 
      before(:each) do
        clean_organism
        Apartment::Database.switch(SCHEMA_TEST)
        @o = Organism.create!({:title =>'Mon Entreprise',
            database_name:SCHEMA_TEST,
            :status=>'Entreprise' })
         
      end
      
      
      
      it 'ne crée pas de bridge vers adhérent' do
        @o.bridge.should == nil
      end
      
      it 'créé 3 destinations' do
        @o.destinations.count.should == 3
      end
      
      it 'dont Non affecté' do
        @o.destinations.find_by_name('Non affecté').should be_an_instance_of(Destination)
      end

    end
    

    
  end


  context 'avec des exercices', wip:true  do 

    before(:each) do
      use_test_organism
      @p2 = find_second_period
    end
    
    it 'est accountable'  do
      @o.should be_accountable
    end

    describe 'find_period' do

      it "doit trouver l'exercice avec une date" do
        @o.find_period(Date.today).should == @p
        @o.find_period(Date.today >> 12).should == @p2
        @o.find_period(Date.civil(1990,5,15)).should == nil
      end

    end


    describe 'guess period'  do

      it 'renvoie nil si pas de periods' do
        @o.stub(:periods).and_return []
        @o.guess_period(Date.today).should be_nil
      end

      it 'si la date est future renvoie le plus récent'  do
        @o.guess_period(Date.today >> 36).should == @p2
      end 

      it 'si la date est trop ancienne, renvoie le plus vieux' do
        @o.guess_period(Date.today.years_ago 10).should == @p
      end
      
   end
    
    
 
    describe 'max_open_periods?' do
      it 'nb_open_periods.should == 2' do
        @o.nb_open_periods.should == 2
      end

      it 'should be true ' do
        @o.max_open_periods?.should be_true
      end

      it 'should be false when the first period is closes' do
        @o.stub(:nb_open_periods).and_return(1)
        @o.max_open_periods?.should be_false
      end
    end

  end
end

