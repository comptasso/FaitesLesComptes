# coding: utf-8

require 'spec_helper'

describe "compta/writings/index" do
  include JcCapybara

  before(:each) do
    assign(:book, @b=stub_model(Book))
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year))
    assign(:writings, @a = [
      stub_model(Writing, date:Date.today),
      stub_model(Writing, date:Date.today, locked?:true),
      stub_model(Transfer, date:Date.today),
      stub_model(Transfer, date:Date.today, locked?:true)
    ])
    @a.stub(:unlocked).and_return(@a)
    @a.stub(:not_transfer).and_return(@a)
    @a.stub(:any?).and_return false 

  render
  end

  it "render une collection avec deux écritures" do
    page.all('.writing').should have(4).elements
  end

  it 'chaque writing non verrouillée a 3 actions représentées par des icones' do
    fra = page.all('.writing').first.all('.title img')
    fra.should have(3).icons # les icones pour modifier, effacer et verrouiller
    fra[0][:src].should == '/assets/icones/modifier.png'
    fra[1][:src].should == '/assets/icones/supprimer.png'
    fra[2][:src].should == '/assets/icones/verrouiller.png'
  end

  it 'la deuxième écriture, verrouillée, ne propose pas de lien' do
    fra = page.all('.writing')[1].all('.title img')
    fra.should have(0).icons
  end
  
  it 'la troisième écriture, Transfert non verrouillé affiche un cadenas en noir et blanc' do
    fra = page.all('.writing')[2].all('.title img')
    fra.should have(1).icons
    fra[0][:src].should == '/assets/icones/nb_verrouiller.png'
  end

  it 'la quatrièe écriture, Transfert verrouillé, n affiche aucune icône' do
    fra = page.all('.writing')[3].all('.title img')
    fra.should have(0).icons
    
  end

  it 'faire les tests du cadenas si pas de unlocked et du cadenas noir et blanc'


end
