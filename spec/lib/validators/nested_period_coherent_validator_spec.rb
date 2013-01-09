# coding: utf-8

require 'spec_helper'

describe 'PeriodCoherentValidator' do 

  let(:p) {stub_model(Period)} 
  let(:n) {mock_model(Nature, period:p)}
  let(:a1) {stub_model(Account, period:p)}
  let(:a2) {stub_model(Account, period:p)}
  let(:b) {mock_model(Book, :type=>'IncomeBook')}

  before(:each) do
     @w = Writing.new(date:Date.today, narration:'test du validator', book:b)
     @w.compta_lines.new(nature:n, account:a1, debit:5)
     @w.compta_lines.new(account:a2, credit:5)
     @w.stub(:period).and_return(p)
  end

  it 'l ecriture doit être valide' do
    @w.should be_valid
  end

  it 'est invalide si la date correspond à un autre exercice que nature' do
    @p2 = mock_model(Period)
    @w.stub(:period).and_return(@p2)
    @w.should_not be_valid
    @w.should have(3).errors_on(:date) # deux incohérences par lignes et 2 lignes
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