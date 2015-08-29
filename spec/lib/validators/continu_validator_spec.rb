# coding: utf-8

require 'spec_helper'

describe 'ContinuValidator' do
  before(:each) do
    @cv = ContinuValidator.new(:attributes=> 1)

  end

  it 'ne crée pas d erreur si la numérotation est continue' do
    w = mock_model(Writing, :continuous_id=>50)
    w.stub(:last_continuous_id).and_return 49
    @cv.validate_each(w, :continuous_id, 50)
    w.errors[:continuous_id].should == []
  end

  it 'crée une erreur si la numérotation n est pas continue' do
    w = mock_model(Writing, :continuous_id=>50)
    w.stub(:last_continuous_id).and_return 48
    @cv.validate_each(w, :continuous_id, 50)
    w.errors[:continuous_id].should == ['La numérotation des écritures doit être continue']
  end

end
