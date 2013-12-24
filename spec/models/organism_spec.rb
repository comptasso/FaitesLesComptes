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
      database_name:'assotest1',
      :status=>'Association'
    }
  end


  describe 'validations' do
    before(:each) do
      clean_assotest1
      Apartment::Database.switch('assotest1')
      @organism= Organism.new valid_attributes
      puts @organism.errors.messages unless @organism.valid?
    end

    it 'should be valid with a title and a database_name' do
      @organism.should be_valid
    end

    it 'should not be valid without title' do
      @organism.title = nil
      @organism.should_not be_valid
    end

    it 'should not be valid without status' do
      @organism.status= nil
      @organism.should_not be_valid
    end

    it 'should create 4 books (un recettes, un dépenses, un OD, un AN)' do
      expect {@organism.save}.to change {Book.count}.by(4)
    end

    it 'should have nomenclature' do
      @organism.save
      @organism.nomenclature.actif.should be_a_instance_of(Folio)
    end

    it 'before_validation remplit la version avec la constante VERSION' do
      @organism.valid?
      @organism.version.should == FLCVERSION
    end

    

  end


  describe 'can_write_line'  do

    before(:each) do
      
      @organism= Organism.new valid_attributes
    end

    it 'pour pouvoir écrire une compta, il faut un compte bancaire ou une caisse et un income ou outcome book' do
      @organism.stub(:income_books).and_return([1])
      @organism.can_write_line?.should be_false
      @organism.stub(:bank_accounts).and_return([1])
      @organism.can_write_line?.should be_true
     
    end

    it 'avec un outcome' do
      @organism.stub(:outcome_books).and_return([1])
      @organism.can_write_line?.should be_false
      @organism.stub(:cashes).and_return([1])
      @organism.can_write_line?.should be_true
    end

    it 'pour pouvoir écrire une compta, il faut un compte bancaire ou une caisse et un income ou outcome book' do
      @organism.stub(:outcome_books).and_return([1])
      @organism.can_write_line?.should be_false
      @organism.stub(:bank_accounts).and_return([1])
      @organism.can_write_line?.should be_true

    end

    it 'avec un outcome' do
      @organism.stub(:income_books).and_return([1])
      @organism.can_write_line?.should be_false
      @organism.stub(:cashes).and_return([1])
      @organism.can_write_line?.should be_true
    end


  end

  describe 'after create' do
    
    context 'une association' do
      before(:each) do
        clean_assotest1
        @organism = Organism.create! valid_attributes
      end

      it 'on a quatre livres' do
        @organism.should have(4).books
      end

      it 'on a un livre de recette' do
        @organism.should have(1).income_book 
      end

      it 'on a un livre de dépenses' do
        @organism.should have(1).outcome_book
      end

      it 'on a un livre d OD' do
        @organism.should have(1).od_book
      end

      it 'on a un livre d AN' do
        @organism.an_book.should be_an_instance_of(AnBook)
      end


      it 'on a une caisse et une banque' do 
        @organism.should have(1).cashes
        @organism.should have(1).bank_accounts
      end

      it 'income_otucome_books renvoie les livres recettes et dépenses' do
        @organism.in_out_books.should have(2).books
        @organism.in_out_books.first.title.should == 'Recettes'
        @organism.in_out_books.last.title.should == 'Dépenses'
      end

      it 'peut créer un document'  do
        Period.stub(:last).and_return(double(Period))
        Compta::Nomenclature.should_receive(:new).with(Period.last).and_return(@cn = double(Compta::Nomenclature))
        @cn.should_receive(:sheet).with(:actif)
        @organism.document(:actif)
      end

      it 'n est pas accountable'  do
        @organism.should_not be_accountable
      end

      it 'mais peut écrire des lignes' do
        @organism.should be_can_write_line
      end

      it 'crée la destination non affecté et adhérent car org est une asso' do
        @organism.status.should == 'Association'
        @organism.destinations.find_by_name('Non affecté').should be_an_instance_of(Destination)
        @organism.destinations.find_by_name('Adhérents').should be_an_instance_of(Destination) 
      end
      
      describe 'bridge vers adherent' do
        it 'crée un bridge vers le module adhérent' do
          @organism.bridge.should be_an_instance_of Adherent::Bridge
        end
        
        it 'avec les bonnes valeures' do 
          b = @organism.bridge
          b.bank_account = @organism.bank_accounts.first
          b.cash = @organism.cashes.first
          b.income_book = @organism.income_books.first
          b.destination = @organism.destinations.find_by_name('Adhérents')
          b.nature_name = 'Cotisations des adhérents'
          
        end 
      
      end
    end
    
    context 'une non association' do
      before(:each) do
        clean_assotest1
        @organism = Organism.create!({:title =>'Mon Entreprise',
          database_name:'assotest1',
      :status=>'Entreprise' })
         
      end
      
      it 'ne crée pas de bridge vers adhérent' do
        @organism.bridge.should == nil
      end
      
      it 'il n y a qu une destination' do
        @organism.destinations.count.should == 1
      end
      
      it 'crée une seule destination si pas association' do
        @organism.destinations.find_by_name('Non affecté').should be_an_instance_of(Destination)
      end

    end
    

    
  end


  context 'when there is one period'  do 

    before(:each) do
      clean_assotest1
      Apartment::Database.switch('assotest1')
      @organism= Organism.create! valid_attributes
      @p_2010 = @organism.periods.create!(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
      @p_2011= @organism.periods.create!(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
      @organism.periods.count.should == 2
    end

    #    after(:all) do
    #      ActiveRecord::Base.establish_connection 'test'
    #    end

    it 'est accountable'  do
      @organism.should be_accountable
    end

    describe 'find_period' do

      it "doit trouver l'exercice avec une date" do
        @organism.find_period(Date.civil(2010,5,15)).should == @p_2010
        @organism.find_period(Date.civil(2011,6,15)).should == @p_2011
        @organism.find_period(Date.civil(1990,5,15)).should == nil
      end

    end


    describe 'guess period'  do

      it 'renvoie nil si pas de periods' do
        @organism.stub(:periods).and_return []
        @organism.guess_period(Date.today).should be_nil
      end

      it 'si la date est future renvoie le plus récent'  do
        @organism.guess_period(Date.today).should == @p_2011
      end 

      it 'si la date est trop ancienne, renvoie le plus vieux' do
        @organism.guess_period(Date.today.years_ago 10).should == @p_2010
      end
      
      it 'sinon prend l exercice' do
        @organism.guess_period(Date.parse('12/08/2010')).should == @p_2010
        @organism.guess_period(Date.parse('11/11/2011')).should == @p_2011
      end



    end
    
    
    describe 'create_account_for', wip:true  do
      
      before(:each) do
        @bac = mock_model(BankAccount, :nickname=>'Cpte sur livret')
        
      end
      
      it 'appelle Account.available avec 512' do
        @organism.stub_chain(:periods, :opened).and_return [] # pour couper court à la suite de la méthode
        Account.should_receive(:available).with('512').and_return('51204')
        @organism.create_accounts_for(@bac)
      end
      
      it 'pour une caisse appelle 53' do
        @cac = Cash.new(:name=>'local')
        @organism.stub_chain(:periods, :opened).and_return []        
        Account.should_receive(:available).with('53').and_return('5301')
        @organism.create_accounts_for(@cac)
      end
      
      it 'puis appelle create_accounts pour chaque exercice ouvert' do
        Account.stub(:available).and_return('51204')
        @organism.stub_chain(:periods, :opened).and_return([@p1 = mock_model(Period), @p2 = mock_model(Period)])
        @bac.should_receive(:accounts).exactly(1).times.and_return(@ar = double(Arel))
        @bac.should_receive(:accounts).exactly(1).times.and_return(@as = double(Arel))
        @ar.should_receive(:create!).with(number:'51204', period_id:@p1.id, title:@bac.nickname).and_return
        @as.should_receive(:create!).with(number:'51204', period_id:@p2.id, title:@bac.nickname).and_return
        @organism.create_accounts_for(@bac)
      end
      
      
    end

    # TODO ce serait mieux que ce soit le modèle Period qui sache s'il peut
    # ouvrir un nouvel exercice
    describe 'max_open_periods?' do
      it 'nb_open_periods.should == 2' do
        @organism.nb_open_periods.should == 2
      end

      it 'should be true ' do
        @organism.max_open_periods?.should be_true
      end

      it 'should be false when the first period is closes' do
        @organism.stub(:nb_open_periods).and_return(1)
        @organism.max_open_periods?.should be_false
      end
    end



    
    describe 'main_bank_id'  do
      
      context 'with default bank account' do
       
        before(:each) do
          @ba = BankAccount.order(:id).first
        end

        
        it "should give the main bank id" do
          @organism.main_bank_id.should == @ba.id
        end

        context 'with another bank account' do
          it 'main_bank_id should returns the first one' do
            @organism.bank_accounts.create!(bank_name: 'CrédiX', number: '124577ZA', nickname:'Compte courant')
            @organism.main_bank_id.should == @ba.id
          end
        end
      end
    end

    describe 'main_cash_id' do
     
      context 'with default cash' do 

        before(:each) do
          @ca = @organism.cashes.first
        end

        it "should give the main cash id" do
          @organism.main_cash_id.should == @ca.id
        end

        context 'with another cash' do
          it 'main_cash_id should returns the first one' do
            @organism.cashes.create!(name: 'porte monnaie')
            @organism.main_cash_id.should == @ca.id
          end
        end
      end
    end

   

  end
end

