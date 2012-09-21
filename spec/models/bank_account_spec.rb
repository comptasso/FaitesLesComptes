# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
 # c.filter = {:wip=> true }
end

describe BankAccount do
  include OrganismFixture 

  before(:each) do
    create_minimal_organism
  end

  before(:each) do
    @bb=@o.bank_accounts.new(:name=>'Crédit Universel', :number=>'1254L') 
  end

  context 'controle des validités' do

    it "should be valid" do 
      @bb.should be_valid
    end

    it 'should not be_valid without name' do
      @bb.name = nil
      @bb.should_not be_valid
    end

    it 'should not be_valid without name' do
      @bb.number = nil
      @bb.should_not be_valid
    end

    it "should have a unique number in the scope of bank and organism" do
      @bb.name = @ba.name
      @bb.number= @ba.number
      @bb.should_not be_valid
    end

  end

  describe 'création du compte comptable'  do

    before(:each) do
      @bb=@o.bank_accounts.new(:name=>'Crédit Universel', :number=>'1254L')
    end

    it 'la création d un compte bancaire doit entraîner celle d un compte comptable' do
      @bb.save
      @bb.should have(1).accounts
      
    end

    it 'incrémente les numéros de compte' do
      @ba.accounts.first.number.should == '51201'
      @bb.save
      @bb.accounts.first.number.should == '51202'
    end

    it 'crée le compte pour tous les exercices ouverts' do 
      @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      @bb.save
      @bb.accounts.count.should == 2
    end

    it 'créer un nouvel exercice recopie le compte correspondant au compte bancaire' do
      @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      @ba.accounts.count.should == 2
      @ba.accounts.last.number.should == '51201'
    end

    

    context 'avec deux exercices' do

      before(:each) do
         @p2 = @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      end

      it 'répond à current_account' do
        @ba.current_account(@p2).period.should == @p2
        @ba.current_account(@p).period.should == @p
      end

    end
  end

  describe 'destroy' do

    before(:each) do
      @bb=@o.bank_accounts.create!(:name=>'Crédit Universel', :number=>'1254L')
    end

    it 'on ne peut détruire un compte bancaire' do
      expect {@bb.destroy}.not_to change {BankAccount.count}
    end
  end
 
  context 'annex methods' do


    it 'to_s return name' do
      @ba.to_s.should == 'DX 123Z'
    end

    it 'to_option return cash_id' do
      @ba.to_option.should == "BankAccount_#{@ba.id}"
    end

    describe 'new_bank_extract' do

      context 'without any bank extract' do
       
        it 'new_bank_extract returns a bank_extract'  do
          @ba.new_bank_extract.should be_an_instance_of(BankExtract)
        end
      
        it 'a new bank_extract is prefilled with date and a zero sold' do
          @be = @ba.new_bank_extract
          @be.begin_sold.should == 0
          @be.begin_date.should == Date.today.beginning_of_month
          @be.end_date.should == @be.begin_date.end_of_month
        end

      end
      
      context 'with already some bank_extract' do
        before(:each) do
          @last_bank_extract = mock_model(BankExtract, 
            :end_date => ((Date.today.beginning_of_month) -1.day),
            :end_sold => 123.45)  
        end
        
        it 'a new bank_extract is prefilled with infos coming from last bank_extract'  do
          @ba.stub(:last_bank_extract).and_return @last_bank_extract
          @be = @ba.new_bank_extract
          @be.begin_sold.should == @last_bank_extract.end_sold
          @be.begin_date.should == (@last_bank_extract.end_date + 1.day)
          @be.end_date.should == @be.begin_date.end_of_month
        end
        
        
      end

    end

  end

end

