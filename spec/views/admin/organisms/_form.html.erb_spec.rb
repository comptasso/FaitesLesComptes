# coding: utf-8

require 'spec_helper'


describe'admin/organisms/_form' do
    include JcCapybara

  before(:each) do
    assign(:organism, mock_model(Organism))
  end

  it 'should render form with two inputs ' do
    render :template=>'admin/organisms/new' 
  end

  it 'has des radio button avec association et entreprise' do
     render :template=>'admin/organisms/new'
     page.find('select#organism_status').all('option').should have(2).elements # 'association et entreprise'
     page.find('select#organism_status').find('option').text.should == 'Association'
     page.find('select#organism_status').find('option:last').text.should == 'Entreprise'
  end
end