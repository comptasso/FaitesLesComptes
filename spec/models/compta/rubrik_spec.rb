# coding: utf-8

require 'spec_helper'

describe Compta::Rubrik do
  
  let(:p) {mock_model(Period, resultat:56.25)}
  let(:r) {mock_model(Rubrik, depth:3, title:'Le titre')}
  
  subject {Compta::Rubrik.new(r,p)}
  
  it 'une compta rubrik se créé avec une rubrik et un exercice' do
    subject.should be_an_instance_of Compta::Rubrik
  end
  
  it 'et instancie ces deux variables' do
    subject.period.should == p
    subject.rubrik.should == r
  end
  
  it 'title et depth sont délégués à Rubrik' do
    subject.title.should == r.title
    subject.depth.should == r.depth
  end
  
  
  describe 'lines' do
     
    context 'r est une feuille'  do
    
      it 'lines appelle all_lines' do
        r.stub('leaf?').and_return true
        subject.should_receive(:all_lines).and_return 'mes lignes'
        subject.send(:lines).should == 'mes lignes'
      end
       
    end 
  
    context 'r n est pas une feuille' do
      
      it 'lines appelle les enfants de rubrik' do
        r.stub('leaf?').and_return false
        r.should_receive(:children).and_return([double(Rubrik, :to_compta_rubrik=>true)])
        subject.send(:lines)
      end
      
    end
    
    
 
 
  
  end
  
  
  
  
end