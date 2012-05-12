# coding: utf-8

require 'spec_helper'

describe BankExtractLine do
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
      @bel = BankExtractLine.new(valid_attributes) 
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
      pending 'peut être que type n est pas rempli si c est la classe de base'
      @bel.type.should == 'BankExtractLine'
    end

    
  end



end
