# coding: utf-8

require 'spec_helper'


describe'admin/rooms/_form' do  
    include JcCapybara

  before(:each) do
    assign(:room, stub_model(Room)) 
  end

  it 'should render form with two inputs ' do
    render :template=>'admin/rooms/new'
  end

  it 'has des radio button avec association et entreprise' do
     render :template=>'admin/rooms/new'
     page.all('.radio-inline').should have(3).elements 
     page.find('#room_status_association').value().should == 'Association'
     page.find('#room_status_comit_dentreprise').value().should == 'Comité d\'entreprise'
     page.find('#room_status_entreprise').value().should == 'Entreprise'
  end
end