# coding: utf-8

require 'spec_helper'

describe "natures/stats" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :name => "Name"
      ),
      stub_model(User,
        :name => "Name"
      )
    ])
  end

  it "affiche le h3 statistiques par natures"

  it "affiche un formulaire avec les destinations"

  it "affiche une table avec autant de colonnes qu un exercice a de mois"

  it "affiche dans la première colonne les natures dans l'ordre alphabétique recettes puis dépenses"

  it "affiche dans les mois le montant correspondant"

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
