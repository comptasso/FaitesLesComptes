# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "vue organisme"  do
  context "quand il n'y a aucun organisme" do
    it 'root aboutit vers new_organism' do
      visit root_path
      response.should contain('Nouvel organisme')
    end

    it 'création du nouvel organisme' do
      visit root_path
      fill_in 'Titre', :with=>'Association TRI'
      click_button 'Créer'
      response.should contain('créer un exercice')
    end

context 'un organisme est créé' do
  before(:each) do
    visit root_path
    fill_in 'Titre', :with=>'Association TRI'
    click_button 'Créer'
  end

    it 'création de l exercice' do
      select 'janvier', :from=>'period_start_date_2i'
      select '2011', :form=>'period_start_date_1i'
      select 'décembre', :from=>'period_close_date_2i'
      select '2011', :form=>'period_close_date_1i'
      click_button "Créer l'exercice"
    end

      it 'créer quelques autres cas'
  end
  end
end


