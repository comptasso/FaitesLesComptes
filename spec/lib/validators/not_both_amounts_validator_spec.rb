# coding: utf-8

require 'spec_helper'

describe 'NotBothAmountsValidator' do

  # TODO revoir les autres spec de validators à l'aune de celle ci
  
  subject { NotBothAmountsValidator.new}
  
  it 'ajoute des erreurs si credit et debit sont tous deux remplis' do
    cl = mock_model(ComptaLine, :debit=>5, :credit=>6)
    subject.validate cl
    cl.errors[:debit].should == ['débit et crédit sur une même ligne']
    cl.errors[:credit].should == ['débit et crédit sur une même ligne']
  end

  it 'pas d erreur si seulement  debit' do
    cl = mock_model(ComptaLine, :debit=>5, :credit=>0)
    subject.validate cl
    cl.errors[:debit].should == []
    cl.errors[:credit].should == []
  end

  it 'ni si seulement credit' do
    cl = mock_model(ComptaLine, :debit=>0, :credit=>6)
    subject.validate cl
    cl.errors[:debit].should == []
    cl.errors[:credit].should == []
  end


end