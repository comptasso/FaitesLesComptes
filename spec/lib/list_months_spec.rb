# coding: utf-8

require 'list_months'

describe 'list_months' do
  it 'crée un nombre de MonthYear correspondant au nombre de mois' do
    m = ListMonths.new((1.year.ago.to_date) + 1, Date.today)
    m.count.should == 12
  end

end

