# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c| 
   # c.filter = {:wip=> true }
end

describe BankAccount do  
  include OrganismFixtureBis

  def create_bank_account
    ba = BankAccount.new(:bank_name=>'Crédit Universel', :number=>'1254L', :nickname=>'Compte courant')
    ba.organism_id = 1
    ba
  end
  
  def find_bac
    @bb = BankAccount.where('number =  ?', '1254L').first
    @bb ||= create_bank_account
  end

  

  describe 'controle des validités' do

    before(:each) do
      find_bac
    end

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

    it "should have a unique number in the scope of bank and organism", wip:true do
      @bb.stub(:create_accounts).and_return true
      @bb.save
      ba = create_bank_account
      ba.number = '1245X'
     
      ba.should be_valid
      ba.number = @bb.number
      ba.should_not be_valid
    end

  end

  describe 'création du compte comptable'  do

    before(:each) do
      create_minimal_organism
      @bb=@o.bank_accounts.new(:bank_name=>'Crédit Universel', :number=>'1254L', :nickname=>'Compte courant')
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

    it 'changer le nick_name du compte bancaire change le compte du compte comptable' do
      @ba.nickname = 'Un autre nom'
      @ba.save
      @ba.accounts.last.title.should == 'Un autre nom'
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



  
  describe 'Les méthodes liées aux lignes non pointées' do

     before(:each) do
      @ba = create_bank_account
    end

    it 'np_lines demande à compta_lines ses lignes non pointées' do
      @ba.should_receive(:compta_lines).and_return(@ar = double(Arel))
      @ar.should_receive(:not_pointed)
      @ba.np_lines
    end

  end

    describe 'new_bank_extract'  do

      before(:each) do
        create_minimal_organism
      end

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

      it 'new_bank_extract return nil si on est déja à la fin de l exercice' do
        @last_bank_extract = mock_model(BankExtract, :end_date=>Date.today.end_of_year, :end_sold=>3.14)
        @ba.stub(:last_bank_extract).and_return @last_bank_extract
        @ba.new_bank_extract(@p).should be_nil
      end

    end

  
end

