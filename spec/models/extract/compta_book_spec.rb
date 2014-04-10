# coding: utf-8

require 'spec_helper'


RSpec.configure do |config|  
  #  config.filter = {wip:true} 

end
 
describe Extract::ComptaBook do 
  
  let(:b) {Book.new(title:'Le titre') }
  let(:p) {Period.new(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}
  
  subject {Extract::ComptaBook.new(b,p)} 
  
  before(:each) do
    b.stub(:organism).and_return(double(Organism, title:'Belle asso'))
  end
  
  
  
  # TODO spec à faire
  it 'peut produire un pdf' do
    expect {subject.to_pdf}.not_to raise_error
  end
  
end