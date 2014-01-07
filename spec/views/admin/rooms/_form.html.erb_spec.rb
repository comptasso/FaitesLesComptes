# coding: utf-8

require 'spec_helper'


describe'admin/rooms/_form' do 
    include JcCapybara

  before(:each) do
    assign(:organism, mock_model(Organism)) 
  end

  it 'should render form with two inputs ' do
    render :template=>'admin/rooms/new'
  end

  it 'has des radio button avec association et entreprise' do
     render :template=>'admin/rooms/new'
     page.all('.controls .inline_radio_buttons').should have(2).elements # 'association et entreprise'
     page.find('#organism_status_association').value().should == 'Association'
     page.find('#organism_status_entreprise').value().should == 'Entreprise'
  end
end