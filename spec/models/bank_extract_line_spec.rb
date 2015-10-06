# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 #  c.filter = {:wip=> true }
end


describe BankExtractLine do
  include OrganismFixtureBis

  before(:each) do
    use_test_organism

    @be = find_bank_extract
    @d7 = create_outcome_writing(7)
    @d29 = create_outcome_writing(29)
    @ch97 = create_in_out_writing(97, 'Chèque')
    @ch5 = create_in_out_writing(5, 'Chèque')
    @cr = create_in_out_writing(27) # une recette
    @cd = @ba.check_deposits.new(deposit_date:(Date.today + 1.day))
    @cd.checks << @ch97.support_line << @ch5.support_line
    @cd.save!

  end

  after(:each) do
    BankExtract.delete_all
    Writing.delete_all
    CheckDeposit.delete_all
  end

  it 'les écritures doivent être valides' do
    @d7.should be_valid
    @d29.should be_valid
    @ch97.should be_valid
    @ch5.should be_valid
  end

  describe 'validations' do
    it 'un bank_ectract_line ne peut être vide' do
      bel = @be.bank_extract_lines.new
      bel.should_not be_valid
      bel.errors.messages[:compta_line_id].should == ['obligatoire']
    end

    it 'le champ bank_extract_id est obligatoire' do
      bel = BankExtractLine.new(:compta_line_id=>1)
      bel.should_not be_valid
      bel.errors.messages[:bank_extract_id].should == ['obligatoire']
    end


  end


  describe 'un extrait bancaire avec les différents éléments' do

    before(:each) do
      @be.bank_extract_lines.new(:compta_line_id=>@d7.support_line.id)
      @be.bank_extract_lines.new(:compta_line_id=>@d29.support_line.id)
      @be.bank_extract_lines.new(:compta_line_id=>@cd.debit_line.id)
      puts @be.errors.messages unless @be.valid?

      @be.save!
    end


    it 'checks values'  do
      @be.total_lines_credit.to_f.should == 36
      @be.total_lines_debit.to_f.should == 102
    end

    it 'checks positions' do
      @be.bank_extract_lines.to_a.map {|bel| bel.debit}.should == [0,0,102]
      @be.bank_extract_lines.to_a.map {|bel| bel.credit}.should == [7,29,0]
      @be.bank_extract_lines.to_a.map {|bel| bel.position}.should == [1,2,3]
    end



    describe 'lock_line'  do

      subject {BankExtractLine.new(bank_extract_id:5, compta_line_id:6)}

      it 'appelle lock de sa compta_line' do
        subject.should_receive(:compta_line).and_return(@cl = mock_model(ComptaLine))
        @cl.should_receive(:lock).and_return true
        subject.lock_line
      end

    end



    describe 'testing move_higher and move_lower' do

      before(:each) do
        @bel7, @bel29, @bel102 = *@be.bank_extract_lines.to_a
      end

      it 'test du splat' do
        @be.bank_extract_lines.order('position').to_a.should  == [@bel7, @bel29, @bel102]
      end

      it '@bel7 is in first position' do
        @bel7.position.should == 1
      end

      it 'move lower' do
        @bel7.move_lower
        @be.bank_extract_lines.order('position').to_a.should  == [@bel29, @bel7, @bel102]
      end


    end


  end



end
