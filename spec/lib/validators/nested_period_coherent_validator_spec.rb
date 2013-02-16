# coding: utf-8

require 'spec_helper'

describe 'PeriodCoherentValidator' do 

  let(:p) {stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}
  let(:n) {mock_model(Nature, period:p)}
  let(:a1) {stub_model(Account, period:p)}
  let(:a2) {stub_model(Account, period:p)}
  let(:b) {stub_model(Book, :type=>'IncomeBook')}
 
  before(:each) do
     @w = b.writings.new(date:Date.today, narration:'test du validator')
     @w.compta_lines.new(nature:n, account:a1, debit:5)
     @w.compta_lines.new(account:a2, credit:5)
     @w.stub(:period).and_return(p)
     @w.stub(:book).and_return b
  end

  it 'l ecriture doit être valide' do
    @w.should be_valid
  end

  it 'est invalide si la date correspond à un autre exercice que nature' do
    next_year = p.close_date + 1
    @p2 = mock_model(Period, start_date:next_year, close_date:next_year.end_of_year)
    @w.stub(:period).and_return(@p2)
    @w.should_not be_valid
    # puts @w.errors.messages
    @w.should have(4).errors_on(:date) # une incohérence pour la date, une pour la
    # nature et une pour chacun des comptes
  end

  it 'on ne change pas la date mais la nature ' do
     n.stub(:period).and_return(mock_model(Period))
     @w.should_not be_valid
     @w.should have(1).errors_on(:date)
  end

  it 'on change un compte' do
     a1.stub(:period).and_return(mock_model(Period))
     @w.should_not be_valid
     @w.should have(1).errors_on(:date)
  end
  
 


end