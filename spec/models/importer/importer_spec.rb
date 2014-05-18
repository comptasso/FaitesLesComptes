# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end

describe Importer::Importer do
  
  def uploaded_file(name)
    "#{Rails.root}/spec/fixtures/importer/#{name}"
  end
  
  subject {Importer::Importer.new(file:uploaded_file('releve.csv'), bank_account_id:1)}
  
  it {subject.should be_valid} 
  
  it 'peut lire les lignes' do
    subject.imported_rows.should have(49).lines 
  end
  
  it 'peut lire un ofx' do
    subject.file = uploaded_file('releve.ofx')
    subject.imported_rows.should have(216).lines
  end
  
end