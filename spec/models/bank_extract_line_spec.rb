# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 #  c.filter = {:wip=> true }
end


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
    @d29 = Line.create!(narration:'bel', line_date:Date.today, debit:29, credit:0, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ib.id, nature_id:@n.id)
     @ch97 = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:97, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
     @ch5 = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:5, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
     @cr = Line.create!(narration:'bel', line_date:Date.today, debit:0, credit:27, payment_mode:'Virement', book_id:@ib.id, nature_id:@n.id)
    @cd = CheckDeposit.create!(bank_account_id:@ba.id, deposit_date:(Date.today + 1.day))
    @cd.checks << @ch97 << @ch5
    @cd.save!


  end


  describe 'un extrait bancaire avec les différents éléments' do

    before(:each) do
      @be.bank_extract_lines << StandardBankExtractLine.new(bank_extract_id:@be.id, :lines=>[@d7])
      @be.bank_extract_lines << StandardBankExtractLine.new(bank_extract_id:@be.id, :lines=>[@d29])
      cdbel = CheckDepositBankExtractLine.new()
      cdbel.check_deposit = @cd
      @be.bank_extract_lines << cdbel 
      @be.save!
    end


    it 'checks values' do
      @be.total_lines_credit.to_f.should == 102
      @be.total_lines_debit.to_f.should == 36
    end

    it 'checks positions' do
      @be.bank_extract_lines.all.map {|bel| bel.credit}.should == [0,0,102]
      @be.bank_extract_lines.all.map {|bel| bel.debit}.should == [7,29,0]
      @be.bank_extract_lines.all.map {|bel| bel.position}.should == [1,2,3]
    end

   
    # c'est par construction puisque le rattachement d'une remise de chèque
    # se fait par la méthode belongs_to 
    # TODO en fait actuellement c'est un has_one (mais une modif est prévue)



   
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

    describe 'chainable'  do

      before(:each) do
        @bel7, @bel29,  @bel102 = *@be.bank_extract_lines.order('position')
      end

      it 'a check_deposit_bank_extract_line is not chainable' do
        @bel102.should be_a(CheckDepositBankExtractLine)
        @bel102.should_not be_chainable
      end

      it ' a bel followed by a standard bel is chainable' do
        @bel7.should be_chainable
      end

      it ' a bel followed by a check_deposit is not chainable' do
        @bel29.position.should == 2
        @bel29.should_not be_chainable
      end

      it 'a bel is chainable only if both debit or both credit' , :wip=>true do
        bel_cr = @be.standard_bank_extract_lines.create!(lines:[@cr])
        bel_cr.move_to_top
        bel_cr.should_not be_chainable

      end

      it 'move_lower' do
        @be.bank_extract_lines.order('position').all.should  == [@bel7, @bel29, @bel102]
        @bel102.move_higher
        @be.bank_extract_lines.order('position').all.should  == [@bel7, @bel102, @bel29]
      end

      context 'avec l ordre bel7, 102 et 29' do

        before(:each) do
          @bel102.move_higher
          @cel7, @cel102,  @cel29 = *@be.bank_extract_lines.order('position')
          
        end

        it 'cel29 est le dernier' do
          @cel7.position.should == 1
          @cel102.position.should == 2
          # @bel102.move_higher
          @cel29.position.should == 3
          #be_last
        end

        it 'aucun n est chainable' do
          @cel7.should_not be_chainable
          @cel102.should_not be_chainable
          @cel29.should_not be_chainable
        end


      end


    end

  end



end
