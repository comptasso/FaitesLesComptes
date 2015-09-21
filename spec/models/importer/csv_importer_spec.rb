# coding: utf-8

require 'spec_helper'


RSpec.configure do |config|
  #  config.filter =  {wip:true}
end

describe Importer::CsvImporter do


  describe 'leture d un fichier' do

    subject {Importer::CsvImporter.new(source_file, 1)}

    context 'avec un fichier bien formé' do

      let(:source_file) {File.join(Rails.root, 'spec/assets/importer/releve.csv')}



      it 'sait lire les lignes d un fichier' do
        subject.should have(49).load_imported_rows
      end

    end

    context 'avec un ficher illisible' do
      let(:source_file) {File.join(Rails.root, 'spec/assets/importer/releve.slk')}

      it 'indique CSV::MalformedCSVError' do

        expect {subject.load_imported_rows}.to raise_error(CSV::MalformedCSVError)

      end
    end



  end





end
