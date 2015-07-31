# coding: utf-8

require 'spec_helper'


describe'admin/organisms/_form' do
    include JcCapybara

  before(:each) do
    assign(:organism, stub_model(Organism))
  end

  it 'should render form ' do
    render :template=>'admin/organisms/new'
  end

  it 'avec 3 radio button pour le statut' do
     render :template=>'admin/organisms/new'
     page.all('.radio-inline').should have(3).elements
     page.find('#organism_status_association').value().should == 'Association'
     page.find('#organism_status_comit_dentreprise').value().should == 'Comité d\'entreprise'
     page.find('#organism_status_entreprise').value().should == 'Entreprise'
  end
end
