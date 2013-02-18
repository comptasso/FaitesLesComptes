# coding: utf-8

require 'spec_helper'

describe Compta::SheetsHelper do
  def rubrik
    [['produits', 200], ['dépenses', 120]]
  end

  before(:each) do
    @rubrik = rubrik
    @rubrik.stub(:totals).and_return ['Résultat',80]
  end

  it 'total retourne le compte 12' do
    totals_result_with_account(@rubrik).should == ['12 - Résultat', 80] 
  end

end

