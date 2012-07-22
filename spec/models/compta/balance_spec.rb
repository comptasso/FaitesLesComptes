# coding: utf-8

require 'spec_helper'

describe Compta::Balance do
  before(:each) do
    @o=Organism.create!(title:'test balance sans table')
    @p= Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @a1 = @p.accounts.create!(number:'60', title:'compte 1')
    @a2 = @p.accounts.create!(number:'70',title:'compte 2')
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

  it 'should have a period_id' do
    b = Compta::Balance.new
    b.valid?
    b.should have(1).errors_on(:period_id)
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
        b.from_account.should == @a1
        b.to_account.should == @a2
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

    describe 'balance lines' do

      it 'should be an array' do
        @b.balance_lines.should be_an Array
        @b.balance_lines.should have(2).elements
        @b.balance_lines.first.should ==
       { :account_id=>@a1.id,
         :account_title=>'compte 1',
         :account_number=>"60",
         :empty=>true,
         :provisoire=>true,
         :number=>"60",
         :title=>"compte 1",
         :cumul_debit_before=>0,
         :cumul_credit_before=>0,
         :movement_debit=>0,
         :movement_credit=>0,
         :cumul_debit_at=>0,
         :cumul_credit_at=> 0 }

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
         :cumul_debit_at=>10+value,
         :cumul_credit_at=> 1+value*2 }
     end

     before(:each) do
       @b.stub(:balance_lines).and_return(1.upto(100).collect {|i| bal_line(i) })
     end

     it 'nb page' do
       @b.balance_lines.should have(100).elements
       @b.nb_pages.should == 5
     end

     it 'should respond to report_line' do
       pending 'en attente d un éventuel module Listing ou Page (inspiré de ce qui est fait dans Stats'
     end
    end

  end
end
