# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe Organism do
  def valid_attributes
    {:title =>'Test ASSO',
      database_name:'testasso1'
    }
  end


  describe 'creation' do
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

    it 'should create 3 books' do
      expect {@organism.save}.to change {Book.count}.by(3)
    end

  end

  describe 'after create', wip:true do
    before(:each) do
      @organism= Organism.create! valid_attributes
    end

    it 'on a trois livres' do
      @organism.should have(3).books
    end


    it 'on a une caisse et une banque' do
      @organism.should have(1).cashes
      @organism.should have(1).bank_accounts
    end
  end


 context 'when there is one period'  do 

    before(:each) do
      
      @organism= Organism.create!(title: 'test asso', database_name:'assotest1')
      @p_2010 = @organism.periods.create!(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
      @p_2011= @organism.periods.create!(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
      @organism.periods.count.should == 2
    end

#    after(:all) do
#      ActiveRecord::Base.establish_connection 'test'
#    end

    describe 'find_period' do

      it "doit trouver l'exercice avec une date" do
        @organism.find_period(Date.civil(2010,5,15)).should == @p_2010
        @organism.find_period(Date.civil(2011,6,15)).should == @p_2011
        @organism.find_period(Date.civil(1990,5,15)).should == nil
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
            @organism.bank_accounts.create!(name: 'CrédiX', number: '124577ZA')
            
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

