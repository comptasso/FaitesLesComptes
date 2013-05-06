# coding: utf-8

require 'list_months'

describe 'list_months' do

  before(:each) do
    @lm = ListMonths.new(Date.today.beginning_of_year,Date.today.beginning_of_year.years_since(1)-1)
  end
  it 'crée un nombre de MonthYear correspondant au nombre de mois' do
   @lm.count.should == 12
  end

  it 'to_s renvoie la liste des mois' do
    y = Date.today.year
    coll = 1.upto(12).collect {|i| "#{'%02d' % i}-#{y}"}.join(', ')
    @lm.to_s.should == coll
  end

end

