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
    {bank_extract_id:@be.id, line_id:@l.id}
  end

  describe 'with valid attributes' do
    it 'is created' do
      bel = @be.bank_extract_lines.new(valid_attributes)
      bel.should be_valid 
    end 
  end

end
