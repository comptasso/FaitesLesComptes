# coding: utf-8

require 'spec_helper'



describe Editions::DetailedSheet do 

  let(:p) {mock_model(Period)}
  let(:source) {double(Compta::Sheet, :sens=>:actif)}

  it 'crée une instance' do
    Editions::DetailedSheet.new(p, source, {}).should be_an_instance_of(Editions::DetailedSheet)
  end

  it 'fetch_lines' do
    @ds = Editions::DetailedSheet.new(p, source, {})
    source.should_receive(:detailed_lines).and_return('bonjour')
    @ds.fetch_lines
  end

  it 'et sait rendre le pdf en numérotant les pages' do
    @ds = Editions::DetailedSheet.new(p, source, {})
    # on stub le Prawn::Document pour ne tester que l'appel
    Prawn::Document.stub(:new).and_return(double(Prawn::Document, :render=>true))
    @ds.should_receive(:numerote).and_return true
    @ds.render
  end
  
end 