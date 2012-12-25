# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
  # c.filter = {:wip=> true }
end

describe BankAccount do 
  include OrganismFixture

  def create_bank_account
    @o.bank_accounts.new(:bank_name=>'Crédit Universel', :number=>'1254L', :nickname=>'Compte courant')
  end

  before(:each) do
    create_minimal_organism
  end

  before(:each) do
    @bb=create_bank_account
  end

  context 'controle des validités' do

    it "should be valid" do 
      @bb.should be_valid
    end

    it 'should not be_valid without name' do
      @bb.bank_name = nil
      @bb.should_not be_valid
    end

    it 'should not be_valid without name' do
      @bb.number = nil
      @bb.should_not be_valid
    end

    it 'should not be_valid without name' do
      @bb.nickname = nil
      @bb.should_not be_valid
    end

    it "should have a unique number in the scope of bank and organism" do
      @bb.bank_name = @ba.bank_name
      @bb.number= @ba.number
      @bb.should_not be_valid
    end

  end

  describe 'création du compte comptable'  do

    before(:each) do
      @bb=create_bank_account
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



  
  context 'annex methods' do

    it 'to_s return name' do
      @ba.to_s.should == 'DX 123Z'
    end

    it 'np_lines' do
      pending 'pas implémenté'
    end

    describe 'new_bank_extract' do

      context 'without any bank extract' do
       
        it 'new_bank_extract returns a bank_extract'  do
          @ba.new_bank_extract(@p).should be_an_instance_of(BankExtract)
        end
      
        it 'a new bank_extract is prefilled with date and a zero sold' do
          @be = @ba.new_bank_extract(@p)
          @be.begin_sold.should == 0
          @be.begin_date.should == @p.start_date
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
          @be = @ba.new_bank_extract(@p)
          @be.begin_sold.should == @last_bank_extract.end_sold
          @be.begin_date.should == (@last_bank_extract.end_date + 1.day)
          @be.end_date.should == @be.begin_date.end_of_month
        end
        
        
      end

    end

  end

end

