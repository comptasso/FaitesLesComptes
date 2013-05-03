# coding: utf-8

require 'spec_helper'
require 'month_year' 

describe 'MonthYear' do

  it 'is created from a hash' do
    m = MonthYear.new(:year=>2011, :month=>12)
    m.should be_an_instance_of MonthYear  
  end

  it 'month est rendu sur deux chiffres' do
    m = MonthYear.new(:year=>2011, :month=>1) 
    m.month.should == '01' 
  end

  it 'bad date raise error' do
    expect {MonthYear.new(year:2012, month:13)}.to raise_error ArgumentError
  end

  it 'sait renvoyer un month_year de l année précédente' do
    m = MonthYear.new(:year=>2011, :month=>12)
    pm = m.previous_year
    pm.should be_an_instance_of MonthYear
    pm.year.should == '2010'
    pm.month.should == m.month
  end


  it 'to_s retourne 01-2012' do
    MonthYear.new(year:2012, month:01).to_s.should == '01-2012'
  end

  it 'to_short_month renvoie jan.' do
    MonthYear.new(year:2012, month:01).to_format('%b').should == 'jan.'
  end

  it '12-2011 est avant 01-2012' do
    m = MonthYear.new(year:2011, month:12)
    n = MonthYear.new(year:2012, month:1)
    m.should < n 

  end

  it 'guess_date' do
    d = Date.today
    my = MonthYear.new(year:d.year, month:d.month)
    my.guess_date.should == d

    my = MonthYear.from_date(d.prev_year)
    my.guess_date.should == my.end_of_month

    my = MonthYear.from_date(d.next_year)
    my.guess_date.should == my.beginning_of_month
  end
end