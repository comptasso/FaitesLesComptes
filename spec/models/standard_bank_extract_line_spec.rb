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
    @l = Line.create!(narration:'bel', line_date:Date.today, debit:7, credit:0, payment_mode:'Espèces', cash_id:@c.id, book_id:@ob.id, nature_id:@n.id)
  end

  def valid_attributes
    {bank_extract_id:@be.id, lines: [@l]}
  end 

  describe 'testing attributes' do

    before(:each) do
      @bel = StandardBankExtractLine.new(valid_attributes)
    end

    it 'is created with valid attributes' do
      @bel.should be_valid
    end

    it 'knows the date' do
      @bel.date.should == Date.today
    end

    it 'testing attributes readers' do
      @bel.narration.should == @l.narration
      @bel.payment.should == @l.payment_mode
    end

    it 'is able to give debit and credit value' do
      @bel.save!
      #@bel.credit.should == @l.credit
      @bel.debit.should == @l.debit
    end
  
    it 'not valid without lines' do
      @bel.lines.clear # on retire la seule ligne du tableau de lignes
      @bel.lines.should have(0).line
      @bel.should_not be_valid
    end

    it 'type is BankExtractLine' do
      #  pending 'peut être que type n est pas rempli si c est la classe de base'
      @bel.type.should == 'StandardBankExtractLine'
    end

    
  end

  describe 'regroup two lines' do

    before(:each) do
      @l2 = Line.create!(narration:'première ligne', line_date:Date.today, debit:7, credit:0, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ob.id, nature_id:@n.id)
      @l3 = Line.create!(narration:'deuxième ligne', line_date:Date.today, debit:13, credit:0, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ob.id, nature_id:@n.id)
      @bel2 = @be.standard_bank_extract_lines.create!(lines:[@l2])
      @bel3 = @be.standard_bank_extract_lines.create!(lines:[@l3])
      
      @bel2.regroup(@bel3)
    end

    it 'is possible to chain two standard lines' do
      @bel2.should have(2).lines

    end

    it 'after fusion, il ne reste qu une bel' do
      @be.should have(1).bank_extract_lines
    end

    it 'le total debit est maintenant de 20' do
      @bel2.debit.should == 20
    end

    it 'la narration n a pas changé' do
      @bel2.narration.should == 'première ligne'
    end

    describe 'degroup' do

      before(:each) do
        @array_bels = @bel2.degroup
      end


      it 'degroup tow lines' do
        @be.should have(2).bank_extract_lines
      end

      it 'check array_bels' do
        @array_bels.should be_an Array
        @array_bels.each {|bel| bel.should be_a StandardBankExtractLine }
      end

      it 'first array_bels is similar to @bel2' do
        @array_bels.first.should have(1).lines
        @array_bels.first.id.should == @bel2.id
      end

      it 'first array_bels is similar to @bel2' do
        @array_bels.first.should have(1).lines
        @array_bels.first.lines.first.should == @l2
        @array_bels.first.id.should == @bel2.id
      end

      it 'last array_bels is similar to @bel3' do
        @array_bels.last.should have(1).lines
        @array_bels.last.lines.first.should == @l3
        # on a bien un nouveau bel
        @array_bels.last.id.should_not == @bel3.id
      end



    end


  end



end
