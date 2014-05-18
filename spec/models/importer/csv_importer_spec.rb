# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end

describe Importer::CsvImporter do
  
  describe 'validations' do
    
    subject {Importer::CsvImporter.new(file:'releve.csv', bank_account_id:1)}
    
    it {subject.should be_valid}
    it {subject.file = nil; subject.should_not be_valid}
    it {subject.bank_account_id= nil; subject.should_not be_valid}
     
  end
  
  describe 'importation d un fichier' do
    
    context 'avec un fichier bien formé' do
    
      let(:source_file) {File.join(Rails.root, 'spec/fixtures/importer/releve.csv')}
    
      subject {Importer::CsvImporter.new(file:source_file, bank_account_id:1)}
    
      it 'sait lire les lignes d un fichier' do
        subject.should have(49).imported_rows
      end
    
    end
    
    context 'avec un ficher illisible' do
      let(:source_file) {File.join(Rails.root, 'spec/fixtures/importer/releve.slk')}
     
      subject {Importer::CsvImporter.new(file:source_file, bank_account_id:1)}
      
      it 'indique CSVMalformedCSVError' do
        subject.imported_rows
        subject.errors[:read].first.should == 'Fichier mal formé, fin de la lecture en ligne 11'
      end
    end
    
    context 'avec un fichier avec des lignes mal formées' do
      let(:source_file) {File.join(Rails.root, 'spec/fixtures/importer/releve_bad.csv')}
     
      subject {Importer::CsvImporter.new(file:source_file, bank_account_id:1)}
    
      it 'enregistre des erreurs en notant les lignes' do
        subject.save
        subject.should have(8).imported_rows
      end
      
      it 'et comprend 5 erreurs sur la base' do
        subject.save
        # p subject.errors.full_messages
        subject.should have(5).errors
      end
      
    end
    
  end
  
  
  
  
  
end