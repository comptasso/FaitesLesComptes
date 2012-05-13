# coding: utf-8

require 'spec_helper'

describe StandardBankExtractLine do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @be = @ba.bank_extracts.create!(:begin_date=>Date.today.beginning_of_month,
      end_date:Date.today.end_of_month,
      begin_sold:1,
      total_debit:2,
      total_credit:5,
      locked:false)
    @d7 = Line.create!(narration:'bel', line_date:Date.today, debit:7, credit:0, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ib.id, nature_id:@n.id)
    @c29 = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:29, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ib.id, nature_id:@n.id)
     @ch97 = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:97, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
     @ch5 = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:5, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
    @cd = CheckDeposit.create!(bank_account_id:@ba.id, deposit_date:(Date.today + 1.day))
    @cd.checks << @ch97 << @ch5
    @cd.save!


  end


  describe 'un extrait bancaire avec les différents éléments' do

    before(:each) do
      @be.bank_extract_lines << StandardBankExtractLine.new(bank_extract_id:@be.id, :lines=>[@d7])
      @be.bank_extract_lines << StandardBankExtractLine.new(bank_extract_id:@be.id, :lines=>[@c29])
      @be.bank_extract_lines << CheckDepositBankExtractLine.new(:check_deposit_id=>@cd.id)
      @be.save!
    end


    it 'checks values' do
      @be.total_lines_credit.to_f.should == 131
      @be.total_lines_debit.to_f.should == 7
    end

    it 'checks positions' do
      @be.bank_extract_lines.all.map {|bel| bel.credit}.should == [0,29,102]
      @be.bank_extract_lines.all.map {|bel| bel.debit}.should == [7,0,0]
      @be.bank_extract_lines.all.map {|bel| bel.position}.should == [1,2,3]
    end

    describe 'testing move_higher and move_lower' do

      before(:each) do
        @bel7, @bel29, @bel102 = *@be.bank_extract_lines.all
      end

      it 'tst du splat' do
        @be.bank_extract_lines.order('position').all.should  == [@bel7, @bel29, @bel102]
      end

      it '@bel7 is in first position' do
        @bel7.position.should == 1
      end

      it 'move lower' do
        @bel7.move_lower
        @be.bank_extract_lines.order('position').all.should  == [@bel29, @bel7, @bel102]
      end


    end

  end



end
