# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c| 
  #  c.filter = {:js=> true }
  #  c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true } 
end

describe Organism do
  include OrganismFixture


  def valid_attributes
    {:title =>'Test ASSO',
      database_name:'testasso1',
      :status=>'Association'
    }
  end


  describe 'validations' do
    before(:each) do
      @organism= Organism.new valid_attributes
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
      @organism.nomenclature[:actif].should be_a_instance_of(Hash)
    end

    it 'before_validation remplit la version avec la constante VERSION' do
      @organism.valid?
      @organism.version.should == VERSION
    end

    

  end


  describe 'can_write_line' , wip:true do

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
    before(:each) do
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

    it 'peut créer un document' , wip:true do
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

    it 

    
  end


 context 'when there is one period'  do 

    before(:each) do
      clean_test_base 
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



    
    describe 'main_bank_id' do
      
      context 'with default bank account' do
       
        before(:each) do
          @ba = BankAccount.first
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

