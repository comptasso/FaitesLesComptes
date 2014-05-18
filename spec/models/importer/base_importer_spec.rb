# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end

describe Importer::CsvImporter do
  
  subject {Importer::BaseImporter.new}
  
  it 'save retourne false si non valide' do
    subject.stub('valid?').and_return false
    subject.save.should be_false
    
  end
  
  it 'extension de base.csv retourn csv' do
    subject.file = 'base.csv'
    subject.extension.should == 'csv'
  end
  
  it 'extension de base retourne chaine vide' do
    subject.file = 'base'
    subject.extension.should == ''
  end
  
  describe 'validations' do
    
    subject {Importer::BaseImporter.new(file:'base.csv', bank_account_id:1)}
    
    it {subject.should be_valid}
    
    it 'non valide avec une mauvaise extension' do
      subject.file = 'base.zip'
      subject.should_not be_valid
    end
    
    it 'accepte également l extensions ofx' do
      subject.file = 'base.ofx'
      subject.should be_valid
    end
    
  end
  
end