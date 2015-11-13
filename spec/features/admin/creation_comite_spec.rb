# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
   c.filter = {wip:true}
end

describe "creation d un comité" do

  include OrganismFixtureBis

  describe 'Création d un premier organisme' do

    before(:each) do
      create_only_user
      login_as(@cu, 'MonkeyMocha')
    end

    context 'quand je remplis le formulaire' do

      before(:each) do
        visit new_admin_organism_path
        fill_in 'organism_title', with:'Mon comité'
        fill_in 'organism_comment', with:'Une première'
        fill_in 'organism_siren', with:'123455666'
        choose 'Comité d\'entreprise'
      end

      after(:each) do
        Organism.order('created_at ASC').offset(1).each {|o| o.destroy}
      end

      it 'cliquer sur le bouton crée un organisme'  do
        expect {click_button 'Créer l\'organisme'}.to change {Organism.count}.by(1)
      end

      it 'on est sur la page de création d un exercice' do
        click_button 'Créer l\'organisme'
        page.find('h3').should have_content 'Nouvel exercice'
      end

      describe 'la création de l exercice' do

        before(:each) do
          click_button 'Créer l\'organisme'
          click_button 'Créer l\'exercice'
          @o = Organism.order('created_at ASC').last
          @p = @o.periods.first
        end

        it 'ce comité a trois secteurs' do
          expect(@o.sectors.count).to eq(3)
        end

        it 'et 4 livres + OD + AN' do
          expect(@o.books.count).to eq(6)
        end

        it 'l exercice est créé' do
          expect(@p).to be_an_instance_of(Period)
        end

        it 'et 38 natures' do
          expect(@p.natures.count).to eq(38)
        end

        it 'avec 133 comptes' do
          expect(@p.accounts.count).to eq 133
        end

        it 'les comptes ont des secteurs de l organisme' do
          osids = @o.sectors.map(&:id)
          # puts "Les secteurs #{osids}"
          sids = @p.accounts.map(&:sector_id).reject {|s| s == nil }.uniq!
          # puts "Les secteurs des comptes #{sids}"
          sids.each do |sid|
            # puts "secteur testé : #{sid}"
            expect(sid).to be_in(osids)
          end
        end

        it 'la nomenclature est cohérente', wip:true do
          cn =  Compta::Nomenclature.new(@p, @o.nomenclature)
          expect(cn).to be_valid
        end

        it 'la nomenclature est ok', wip:true do
          expect(Utilities::NomenclatureChecker).to be_period_coherent(@p)
        end

      end

    end
  end
end
