# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe OdBook do

  before(:each) do
    @odb = OdBook.new
  end

 it 'income_outcome renvoie true' do
   @odb.income_outcome.should be_true
 end
end
