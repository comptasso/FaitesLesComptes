# coding: utf-8

require 'spec_helper'

describe Admin::PeriodsHelper do

  describe 'period_class' do
    before(:each) do
      @period = mock_model(Period)
      
    end
    
    it 'current si la period est la bonne' do
      period_class(@period).should == 'current'
    end

    it 'other autrement' do
      period_class(mock_model(Period)).should == 'other'
    end

  end

end
