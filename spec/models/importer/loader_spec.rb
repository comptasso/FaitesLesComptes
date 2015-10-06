# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|
  #  config.filter =  {wip:true}
end

describe Importer::Loader do

  def uploaded_file(name)
    "#{Rails.root}/spec/assets/importer/#{name}"
  end

  subject {Importer::Loader.new(file:uploaded_file('releve.csv'), bank_account_id:1)}

  it {subject.should be_valid}

  it 'peut lire les lignes' do
    subject.imported_rows.should have(49).lines
  end

  it 'peut lire un ofx' do
    subject.file = uploaded_file('releve.ofx')
    subject.imported_rows.should have(216).lines
  end

  it 'avec une mauvaise extension' do
    subject.file = uploaded_file('releve.slk')
    subject.save
    subject.should have(1).errors_on(:file)
  end

  it 'avec un fichier csv mal formé' do
    subject.file = uploaded_file('releve_slk.csv')
    subject.save
    # puts subject.errors.messages
    subject.errors[:read].should == ['Impossible de lire le fichier; Fichier mal formé ?']
  end

end
