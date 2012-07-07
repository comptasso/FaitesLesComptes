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
end