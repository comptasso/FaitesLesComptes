# coding: utf-8

require 'spec_helper'



describe 'bank_extract_lines' do

  include OrganismFixtureBis

  before(:each) do
    create_user
    create_minimal_organism
   
    @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
      begin_sold:10, :total_debit=>12.25, :total_credit=>50)

    @d7 = create_outcome_writing(7)
    @d29 = create_outcome_writing(29)

    @be.bank_extract_lines << @be.bank_extract_lines.new(:compta_lines=>[@d7.support_line])
    @be.bank_extract_lines << @be.bank_extract_lines.new(:compta_lines=>[@d29.support_line])
    login_as('quidam')

  end

  it 'bank_extract doit avoir deux lignes' do
    @be.should have(2).bank_extract_lines
  end

  context 'on part du bank_extract' do


    before(:each) do
      visit bank_account_bank_extracts_path(@ba)
    end

    it 'cliquer sur afficher affiche les lignes' do
      within('table') do
        click_link('Afficher')
      end
      current_path.should == bank_extract_bank_extract_lines_path(@be)
      page.find('thead th').should have_content("Liste des écritures")
    end

  end

 

end
