# coding: utf-8

require 'spec_helper'


RSpec.configure do |c| 
   # c.filter = {:wip=>true}
end

describe Compta::Balance do 
  include OrganismFixture


  before(:each) do
    create_organism
    @p = Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @a1 = @p.accounts.find_by_number('60')
    @a2 = @p.accounts.find_by_number('603')
  end

  it 'has a virtual attributes from_date_picker et to_date_picker' do
    b = Compta::Balance.new
    b.from_date_picker =  '01/01/2012'
    b.from_date.should be_a(Date)
    b.from_date.should == Date.civil(2012,1,1)
    b.to_date_picker =  '01/01/2012'
    b.to_date.should be_a(Date)
    b.to_date.should == Date.civil(2012,1,1)
  end

 

  context 'testing methods and validations' do
 
    def valid_arguments
      { period_id:@p.id,
        from_date:Date.today.beginning_of_month,
        to_date:Date.today.end_of_month,
        from_account_id:@a1.id,
        to_account_id:@a2.id
      }
    end

    before(:each) do
      @b=Compta::Balance.new(valid_arguments)
    end

    describe 'methods' do

      it 'should retrieve period' do
        @b.period_id.should == @p.id
        @b.period.should == @p
      end

      it 'has accounts through periods' do
        @b.accounts.should == [@a1, @a2]
      end

      it 'testing with_default_values' do
        b = Compta::Balance.new(period_id:@p.id).with_default_values
        b.from_date.should == @p.start_date
        b.to_date.should == @p.close_date
        b.from_account.should == @p.accounts.find_by_number('101')
        b.to_account.should == @p.accounts.find_by_number('870')
      end

      it 'range_accounts returns an extract of accounts' do
        @b.from_account = @a2
        @b.range_accounts.should == [@a2]
      end

    end

    describe 'validations' do
    
      it 'should be valid' do
        @b.valid?
        @b.should be_valid
      end

      context 'not valid' do

        it 'without period_id' do
          @b.should_not be_valid if @b.period_id = nil
        end

        it 'without from_date' do
          @b.should_not be_valid if @b.from_date = nil
        end
        it 'without to_date' do
          @b.should_not be_valid if @b.to_date = nil
        end
        it 'without from_account' do
          @b.should_not be_valid if @b.from_account = nil
        end
        it 'without to_account' do
          @b.should_not be_valid if @b.to_account = nil
        end

        it 'without from_date_picker' do
          @b.from_date_picker = nil
          @b.from_date.should == nil 
          @b.should_not be_valid
          @b.should have(2).errors_on(:from_date_picker) # obligatoire et Date invalide
          @b.should have(2).errors_on(:from_date)

        end




      end

    end

    describe 'provisoire?' do

      before(:each) do
        @b=Compta::Balance.new(valid_arguments)
        @b.stub(:accounts).and_return(@ar = double(Arel))

      end
      it 'should call all_lines_locked? on each account' do
        @ar.should_receive(:joins).with(:compta_lines).and_return(@ar)
        @ar.should_receive(:where).with('locked = ?', false).and_return @ar
        @ar.should_receive(:any?).and_return true
        @b.should be_provisoire
      end

      it 'should return false if all accounts locked' do
        @ar.stub_chain(:joins, :where, :any?).and_return false
        @b.should_not be_provisoire 
      end

    end

    describe 'balance lines' do

      it 'should be an array' do
        @b.balance_lines.should be_an Array
        @b.balance_lines.should have(2).elements
        @b.balance_lines.first.should ==
       { :account_id=>@a1.id,
         :empty=>true,
         :provisoire=>false, # car il n'y a pas de ligne
         :number=>"60",
         :title=>"Achats (sauf 603)",
         :cumul_debit_before=>0,
         :cumul_credit_before=>0,
         :movement_debit=>0,
         :movement_credit=>0,
         :sold_at=>0 }

      end


    end

    describe 'page' do

     def bal_line(value)
       { :account_id=>value,
         :account_title=>"compte #{value}",
         :account_number=>'60'+value.to_s,
         :empty=>false,
         :provisoire=>true,
         :number=>'60'+value.to_s,
         :title=>"compte #{value}",
         :cumul_debit_before=>10,
         :cumul_credit_before=>1,
         :movement_debit=>value,
         :movement_credit=>value*2,
         :sold_at=>1+value*2 - 10 - value}
     end

     

     before(:each) do 
       @b.stub(:balance_lines).and_return(1.upto(100).collect {|i| bal_line(2) })
     end

     it 'total_balance renvoie le total' , wip:true do
       @b.total_balance.should == [1000, 100, 200, 400, -700]
     end

     it 'nb page' do
       @b.balance_lines.should have(100).elements 
       @b.nb_pages.should == 5
     end

     it 'should be able to_pdf' do
       @b.to_pdf.should be_an_instance_of(PdfDocument::PdfBalance)
     end
    end

  end
end
