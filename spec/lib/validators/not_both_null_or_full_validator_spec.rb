# coding: utf-8

require 'spec_helper'

describe 'NotBothNullOrFullValidator' do
  
   subject {NotBothNullOrFullValidator.new(double(Object))} 
   
  it 'ajoute des erreurs si credit et debit sont tous deux null' do
    ibel = ImportedBel.new(:debit=>0, :credit=>0)
    subject.validate ibel
    ibel.errors[:values].should == ['Montant débit et crédit tous deux à zéro']
  end
  
  it 'ne renvoie qu une seule erreur' do
    ibel = ImportedBel.new(:debit=>0, :credit=>0)
    subject.validate ibel
    subject.validate ibel
    ibel.errors[:values].should == ['Montant débit et crédit tous deux à zéro']
  end
  
  it 'ajoute une erreur sur line si debit et credit tous deux remplis' do
    ibel = ImportedBel.new(:debit=>5, :credit=>6)
    subject.validate ibel
    ibel.errors[:values].should == ['Montant débit et crédit tous deux remplis']
  end
  
end
