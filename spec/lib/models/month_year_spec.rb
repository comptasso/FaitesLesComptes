# coding: utf-8

require 'spec_helper'

describe 'MonthYear' do

  it 'is created from a hash' do
    m = MonthYear.new(:year=>2011, :month=>12)
    m.should be_an_instance_of MonthYear  
  end
end