# coding: utf-8

require 'spec_helper'

describe 'PeriodCoherentValidator' do

  let(:p) {stub_model(Period)}
  let(:n) {stub_model(Nature, period:p)}
  let(:a1) {stub_model(Account, period:p)}
  let(:a2) {stub_model(Account, period:p)}

  before(:each) do
     @w = Writing.new(date:Date.today, narration:'test du validator', book_id:1)
     @w.compta_lines.new(nature_id:n.id, account_id:a1.id, debit:5)
     @w.compta_lines.new(nature_id:n.id, account_id:a2.id, credit:5)
  end

  it 'l ecriture doit être valide' do

    puts @w.errors.messages unless @w.valid?
    @w.should be_valid
  end
end