# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'natures_collection' do
  let(:o) {mock_model Organism}
  let(:ns) { [mock_model(Nature, income_outcome:true, name:'R1'),
              mock_model(Nature, income_outcome:true, name:'R2'),
              mock_model(Nature, income_outcome:false, name:'D1'),
              mock_model(Nature, income_outcome:false, name:'D2'),
              mock_model(Nature, income_outcome:false, name:'D3'),
  ]}



  it 'is instantiaded with org et sens' do
    nc = Utilities::NaturesCollection.new(o, :recettes)
    nc.should be_an_instance_of(Utilities::NaturesCollection)
  end

  it 'to_s' do
    Utilities::NaturesCollection.new(o, :recettes).name.should == 'Recettes'
  end

  it 'test natures returns natures and call the scope' do
    o.should_receive(:natures).and_return(ns)
    ns.stub(:recettes).and_return([ns[0], ns[1]])
   tn = Utilities::NaturesCollection.new(o, :recettes)
   tn.natures.should == [ns[0], ns[1]]
  end
 
end
