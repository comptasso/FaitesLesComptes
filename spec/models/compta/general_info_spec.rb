# coding: utf-8

require 'spec_helper'


describe Compta::GeneralInfo do

  class TestModule
    def period; end # nécessaire car le module vérifie que la classe répond à Period.
    
    include Compta::GeneralInfo
   
  end

  before(:each) do
    @tm = TestModule.new
    @tm.stub(:period).and_return mock_model(Period, :organism=>mock_model(Organism, title:'une affaire'), :exercice=>'Exercice 2013')
  end

  it 'donne le nom de l organisme' do
    @tm.organism_name.should == 'une affaire'
  end

  it 'donne l exercice' do
    @tm.exercice.should == 'Exercice 2013' 
  end



end


