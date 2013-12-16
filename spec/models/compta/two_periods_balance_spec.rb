# coding: utf-8

require 'pdf_document/base'

require 'spec_helper' 

RSpec.configure do |c| 
  #  c.filter = {:wip=>true}
end

describe Compta::TwoPeriodsBalance do
  
  before(:each) do
    @p = double(Period, start_date:Date.civil(2014,1,1), close_date:Date.civil(2014,12,31))
  end

  it 'se déclare avec une period' do
    Compta::TwoPeriodsBalance.new(@p).should be_an_instance_of(Compta::TwoPeriodsBalance)
  end 
  
  describe 'lines' do
    
    subject {Compta::TwoPeriodsBalance.new(@p)} 
    
    it 'appelle two_periods_accounts' do
      @p.should_receive(:two_period_account_numbers).and_return(['1','2'])
      Compta::RubrikLine.should_receive(:new).once.with(@p, :actif, '1')
      Compta::RubrikLine.should_receive(:new).once.with(@p, :actif, '2')
      subject.lines
    end
    
    it 'et construit un array de Compta::RubrikLine' do
      @p.stub(:two_period_account_numbers).and_return(@a = double(Array))
      @a.should_receive(:map).and_return('two compta::rubriklines')
      subject.lines.should == 'two compta::rubriklines'
    end
    
    
  end  
  
  describe 'to_pdf' do
    subject {Compta::TwoPeriodsBalance.new(@p)}
    
    before(:each) do
      subject.stub(:lines).and_return(['1','2'])
      @p.stub(:organism).and_return(double(Organism, title:'Asso test'))
      @p.stub(:long_exercice).and_return('Exercice 2014')
      @p.stub(:closed?).and_return false
    end
    
    it 'retourne un PdfDocument::Base' do
      subject.to_pdf.should be_an_instance_of(PdfDocument::Base)
    end
  end
end
