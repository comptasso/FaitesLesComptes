# coding: utf-8

require 'list_months'

describe 'list_months' do
  it 'crée un nombre de MonthYear correspondant au nombre de mois' do
    d = Date.today.beginning_of_month
    e = d.years_since(1)-1
    m = ListMonths.new(d,e)
    m.count.should == 12 
  end

end

