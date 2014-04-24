# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end

describe Jccallbacks::StripCallback do
  
  subject {Organism.new(title:'un test', comment:'un commentaire', 
      database_name:'unebase', status:'Association')}
  
  it 'doit striper le title avant la validation' do
    subject.title = ' un test '
    subject.valid?
    subject.title = 'un test'
  end
  
  it 'doit striper le commentaire avant la validation' do
    subject.comment = ' un commentaire '
    subject.valid?
    subject.title = 'un commentaire'
  end
  
  
end


