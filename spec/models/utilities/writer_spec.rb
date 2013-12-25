# coding: utf-8

require 'spec_helper'
require 'month_year'

describe Utilities::Writer do
  
  let(:mask) {mock_model(Mask)}
  let(:my) {MonthYear.new(month:Date.current.month, year:Date.current.year)}
  
  before(:each) do
    @sub = Subscription.new(day:5, title:'un abonnement', mask_id:mask.id)
  end
  
  it 'peut écrire' do
    Utilities::Writer.new(@sub).write(my)  
  end
  
  
end