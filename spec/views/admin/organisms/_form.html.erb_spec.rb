# coding: utf-8

require 'spec_helper'


describe'admin/organisms/_form' do
  before(:each) do
    assign(:organism, mock_model(Organism))
  end

  it 'should render form with two inputs ' do
    render :template=>'admin/organisms/new' 
  end
end