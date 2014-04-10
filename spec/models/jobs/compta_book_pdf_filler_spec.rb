# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config| 
  #  config.filter =  {wip:true}
end


describe Jobs::ComptaBookPdfFiller do  
  
  it 'peut créer une instance' do
    Jobs::ComptaBookPdfFiller.new(SCHEMA_TEST, 1, {}).should be_an_instance_of(Jobs::ComptaBookPdfFiller)
  end 
  
end