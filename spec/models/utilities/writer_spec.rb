# coding: utf-8

require 'spec_helper'
require 'month_year'

describe Utilities::Writer do
  include OrganismFixtureBis
  
  
  let(:mask) {mock_model(Mask)}
  let(:my) {Date.current.beginning_of_month + 4.days} 
  
  before(:each) do
    @mask = mask
    @sub = Subscription.new(day:5, title:'un abonnement', mask_id:mask.id)
    @sub.stub(:mask).and_return @mask
    @sub.stub_chain(:writings, :size).and_return 3
    @uwr = Utilities::Writer.new(@sub)
    @mask.stub(:complete_writing_params).and_return({:narration=>'bonjour'})
    @mask.stub_chain(:book, :in_out_writings).and_return(@ar = double(Arel))
    
  end
  
  describe 'write' do
    it 'demande les 3 éléménts de l écriture à mask' do
      @ar.stub(:create).and_return true
      @mask.should_receive(:complete_writing_params).with(Date.current.beginning_of_month + 4.days).
        and_return({:narration=>'bonjour'})
       @uwr.write(my)
    end
    
    it 'modifie narrationdemande à book de créer l écriture' do
      @ar.should_receive(:create).with({:narration=>'bonjour n°4'}).and_return true
      @uwr.write(my).should be_true
    end
    
    
  end
  
end