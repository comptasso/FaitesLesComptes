# coding: utf-8

require 'spec_helper'
# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class TestSold
  include Utilities::Sold
end

class Test2Sold < TestSold
  def cumulated_at(date, sens); 0; end
end

describe 'sold' do

  before(:each) do
    @ts = TestSold.new
  end
  it 'cumulated_at doit être implémenté dans les classes utilisant ce module' do
    expect {@ts.cumulated_at(Date.today, :credit)}.to raise_error
  end

  context 'avec cumulated_at défini' do

    before(:each) do
      @ts = Test2Sold.new
      @ts.stub(:title).and_return 'Le titre'
    end

    it 'monthly_value doit retourner une string 0' do
      @ts.monthly_value(Date.today).should == 0.0
      
    end

    

  end
end
