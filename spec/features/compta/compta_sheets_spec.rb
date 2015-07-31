# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe "Writings" do
  include OrganismFixtureBis

  before(:each) do
    use_test_user
    use_test_organism
    login_as(@cu, 'MonkeyMocha')
    # visit admin_room_path(@r)
  end

  after(:each) do
    Writing.delete_all
  end

  describe "GET compta/sheets" do

    describe 'Calcul des rubriques en arrière plan' do

      before(:each) do
        @nomen = @o.nomenclature
      end



      it 'la première fois Nomenclature recalcule', wip:true do
        pending 'revoir avec delayed_job'
        @o.nomenclature.update_attribute(:job_finished_at, nil)
        Nomenclature.any_instance.stub(:fill_rubriks_with_values).with(@p).and_return('fait')
        visit benevolats_compta_sheets_path

        response.should == 'preparing'
      end

      it 'la deuxième fois ne recalcule pas' do
        @nomen.fill_rubrik_with_values(@p)
        @nomen.should_not_receive(:fill_rubriks_with_values).with(@p)
        visit resultats_compta_sheets_path
      end



    end

    describe 'la vue bilan' do

      it 'contient un actif et un passif avec deux tables' do
        visit bilans_compta_sheets_path
        titres = page.all('.champ h3')
        titres.size.should == 2
        titres.first.should have_content('BILAN ACTIF')
        titres.last.should have_content('BILAN PASSIF')

      end

      it 'actif et passif ont des lignes' do
        visit bilans_compta_sheets_path
        page.all('.actif tr').should have(31).elements
        page.all('.passif tr').should have(22).elements
      end

      it 'benevolat a 1 table et 10 lignes' do
        visit benevolats_compta_sheets_path
        page.all('.champ h3').size.should == 1
        page.all('.passif tr').should have(7).elements
      end

      it 'et compte de résultats en a 50' do
        visit resultats_compta_sheets_path
        page.all('.champ h3').size.should == 1
        page.all('.passif tr').should have(38).elements
      end

      it 'liasse comprend les 4 tableaux dans la même vue' do
        visit liasse_compta_sheets_path
        page.all('.champ h3').should have(4).elements
      end

    end



  end

  describe 'compta/sheets/show' do

    it 'affiche le détail d un folio' do
      visit compta_sheet_path(@o.nomenclature.folios.first)
      page.find('.champ h3').should have_content('BILAN ACTIF')
    end

  end
end
