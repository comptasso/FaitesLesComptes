# coding: utf-8


require 'spec_helper'

describe CheckDepositBankExtractLine do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @be = @ba.bank_extracts.create!(:begin_date=>Date.today.beginning_of_month,
      end_date:Date.today.end_of_month,
      begin_sold:1,
      total_debit:2,
      total_credit:5,
      locked:false)
    @l = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:97, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
    @cd = CheckDeposit.create!(bank_account_id:@ba.id, deposit_date:(Date.today + 1.day))
    @cd.checks << @l
    @cd.save!
  end

  def valid_attributes
    {bank_extract_id:@be.id, check_deposit_id:@cd.id}
  end

  describe 'testing attributes' do

    before(:each) do
      @bel = CheckDepositBankExtractLine.new(valid_attributes)
    end

    it 'is created with valid attributes' do
      @bel.should be_valid
    end

    it 'knows the date' do
      @bel.date.should == Date.tomorrow
    end

    it 'testing attributes readers' do
      @bel.narration.should == 'Remise de chèques'

    end

    it 'is able to give debit and credit value' do
      @bel.credit.should == @cd.total_checks
      @bel.debit.should == 0
    end

    it 'not valid without check_deposit_id' do 
      @bel.check_deposit_id = nil  # on retire la seule ligne du tableau de lignes
      @bel.should_not be_valid
    end


  end



end

