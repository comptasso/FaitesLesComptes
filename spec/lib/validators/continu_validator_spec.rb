# coding: utf-8

require 'spec_helper'

describe 'ContinuValidator' do
  before(:each) do
    @cv = ContinuValidator.new({:attributes => {}})
    Writing.stub(:last_continuous_id).and_return 100
  end
  
  it 'crée une erreur si la numérotation n est pas continue' do
    w = mock_model(Writing, :continuous_id=>50)
    @cv.validate_each(w, :continuous_id, 50)
    w.errors[:continuous_id].should == ['La numérotation des écritures doit être continue']   
  end
  
end