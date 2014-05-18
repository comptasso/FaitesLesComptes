# coding: utf-8

require 'spec_helper'


RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end

describe Importer::OfxImporter do 
  
  describe 'importation d un fichier' do
    
    context 'avec un fichier bien formé' do
    
      let(:source_file) {File.join(Rails.root, 'spec/fixtures/importer/releve.ofx')}
    
      subject {Importer::OfxImporter.new(source_file, 1)}
    
      it 'sait lire les lignes d un fichier' do
        subject.load_imported_rows.should have(216).lines
      end
    
    end
    
  end
  
end