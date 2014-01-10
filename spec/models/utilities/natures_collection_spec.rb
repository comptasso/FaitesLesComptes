# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'natures_collection' do
  let(:p) {mock_model Period}
  let(:b) { mock_model Book, title:'recettes'}
  
  subject {Utilities::NaturesCollection.new(p, b)}
  
  it 'is instantiaded with period and book' do
    subject.should be_an_instance_of(Utilities::NaturesCollection)
  end

  it 'to_s' do
    subject.name.should == 'Recettes'
  end

  it 'test natures returns natures and call the scope' do
    b.should_receive(:natures).and_return(@ar = double(Object))
    @ar.stub(:within_period).with(p).and_return(['bonjour', 'bonsoir'])
   subject.natures.should == ['bonjour', 'bonsoir']
  end
 
end
