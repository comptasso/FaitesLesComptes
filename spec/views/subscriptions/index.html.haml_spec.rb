# coding: utf-8

require 'spec_helper'

describe 'subscriptions/index'  do
  include JcCapybara
  
  let(:sub) {mock_model(Subscription, title:'Un abonnement', 
      end_date:Date.today.end_of_year, day:5, 
    first_to_write:MonthYear.from_date(Date.today << 1))}
  before(:each) do
    assign(:late_subscriptions, [sub])
  end
  
  it 'le titre' do
    render
    page.find('h3').should have_content 'Liste des abonnements ayant des écritures à passer'
  end
  
  it 'rend une table' do
    render
    page.find('table')
  end
  
  
  
  it 'la table doit avoir les champs' do
    pending 'à faire'
    # le titre de l'abonnement
    # jour de l'abonnement
    # les mois à passer avec un titre Depuis 
    # une icone d'action + pour écrire
  end
  
  
end
