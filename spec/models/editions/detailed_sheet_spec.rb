# coding: utf-8

require 'spec_helper'



describe Editions::DetailedSheet do 

  let(:p) {mock_model(Period, exercice:'Exercice 2013')}
  let(:source) {double(Compta::Sheet, :sens=>:actif)}

  it 'crée une instance' do
    Editions::DetailedSheet.new(p, source, {}).should be_an_instance_of(Editions::DetailedSheet)
  end

  it 'fetch_lines' do
    @ds = Editions::DetailedSheet.new(p, source, {})
    source.should_receive(:fetch_lines).with(1).and_return('bonjour')
    @ds.fetch_lines
  end

end 