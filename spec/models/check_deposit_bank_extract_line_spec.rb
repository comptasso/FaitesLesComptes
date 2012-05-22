# coding: utf-8


require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {:wip=>true}
end


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
    @l2 = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:3, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
    @cd = CheckDeposit.create!(bank_account_id:@ba.id, deposit_date:(Date.today + 1.day))
    @cd.checks << @l << @l2
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

    it 'is not valid without bank_extract_id' do
      @bel.bank_extract_id = nil
      @bel.should_not be_valid
    end

    it 'saving the instance fill type field' do
      @bel.save!
      @bel.type.should == 'CheckDepositBankExtractLine'
    end

    it 'check_deposit cant belong to two different bels'  do
      @bel.save!
      @bel2 = CheckDepositBankExtractLine.new(valid_attributes)
      @bel2.should_not be_valid

    end


  end

  describe 'lock line' do
    before(:each) do
      @bel= @be.check_deposit_bank_extract_lines.create!(check_deposit_id:@cd.id)
    end

    it 'locks each line of checks' do
      @bel.should have(2).checks
      @bel.lock_line
      @cd.checks(true).each { |ch| ch.should be_locked }
    end
  end



end

