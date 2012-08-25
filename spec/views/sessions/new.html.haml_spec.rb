#coding: utf-8

require 'spec_helper'

describe "sessions/new" do
  

  before(:each) do
    render
  end

  it 'indique Connexion' do
   
    assert_select 'h3', 'Connexion'
  end

  it 'affiche un formulaire' do
    assert_select 'form' do
      assert_select "input[type='text']", 1
    end
  end

  it 'avec un bouton Entrée' do
    assert_select "input[value='Entrée']", 1
  end



end