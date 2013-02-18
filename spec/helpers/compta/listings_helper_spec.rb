# coding: utf-8

require 'spec_helper'


describe Compta::ListingsHelper do
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year)}

  before(:each) do
    assign(:period, p)
  end

 
describe 'open_sold_ordinalized' do
  it 'si la date est le début de l exercice' do
    helper.open_sold_ordinalized(Date.today.beginning_of_year).should == 'Soldes d\'ouverture'
  end

    it 'autrement' do
      j = Date.civil(2013, 2, 17)
      helper.open_sold_ordinalized(j).should == "Soldes au 17 février 2013"
    end
end
end

