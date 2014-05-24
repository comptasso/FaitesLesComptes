# coding: utf-8

require 'spec_helper'
require 'support/has_icon_matcher'

describe "bank_extracts/index" do
  include JcCapybara

  before(:each) do 
    
    @be1 = stub_model(BankExtract,
      :reference => "Folio 1",
      :begin_date => Date.today.beginning_of_month,
      :end_date => Date.today.end_of_month,
      :begin_sold => 0,
      :total_debit => 100,
      :total_credit => 40,
      :end_sold => 60,
      :locked=> true
      
    )
    @be2 = stub_model(BankExtract,
      :reference => "Folio 2",
      :begin_date => (Date.today.end_of_month) + 1,
      :end_date => ((Date.today.end_of_month) + 1).end_of_month,
      :begin_sold => 60,
      :total_debit => 110,
      :total_credit => 70, 
      :end_sold => 100
     
    )

    @be1.stub(:first_to_point?).and_return false
    @be2.stub(:first_to_point?).and_return true
    
    @be2.stub_chain(:bank_extract_lines, :empty?).and_return false

    assign(:bank_account, @ba = mock_model(BankAccount, imported_bels:[1]))
    assign(:bank_extracts, [@be1, @be2])
        
    view.stub(:virgule).and_return '25,00'
    
  end

  it "renders a list of bank_extracts" do
    @be1.stub_chain(:bank_extract_lines, :empty?).and_return true
    render
    page.all('table').should have(1).elements
    page.find('table tbody').all('tr').should have(2).rows
  end


  it 'testing has_icon?' do
    @be1.stub_chain(:bank_extract_lines, :empty?).and_return false
    render
    page.find('table tbody tr:first td:last').should have_icon('afficher', href:bank_extract_bank_extract_lines_path(@be1))
  end

  it 'un bank_extract sans ligne n affiche pas l icone afficher' do
    @be1.stub_chain(:bank_extract_lines, :empty?).and_return true
    render
    @be1.bank_extract_lines.should be_empty  
    page.find('table tbody tr:first td:last').should_not have_icon('afficher', href:bank_extract_bank_extract_lines_path(@be1))
  end

  it 'unpointed bank_extract has all icons' do
    @be1.stub_chain(:bank_extract_lines, :empty?).and_return false
    render
    @be2.should be_first_to_point
    actions = page.find('table tbody tr:last td:last')
    actions.should have_icon('afficher', href:bank_extract_bank_extract_lines_path(@be2))
    actions.should have_icon('modifier', href:edit_bank_account_bank_extract_path(@ba, @be2))
    actions.should have_icon('pointer', href:pointage_bank_extract_bank_extract_lines_path(@be2))
    actions.should have_icon('supprimer', href:bank_account_bank_extract_path(@ba, @be2))
  end

  it 'locked bank_extract has only show icon' do
    @be1.stub_chain(:bank_extract_lines, :empty?).and_return false
    render
    @be1.should be_locked
    actions = page.find('table tbody tr:first td:last')
    actions.should have_icon('afficher', href:bank_extract_bank_extract_lines_path(@be1))
    actions.should_not have_icon('modifier', href:edit_bank_account_bank_extract_path(@ba, @be1))
    actions.should_not have_icon('pointer', href:pointage_bank_extract_bank_extract_lines_path(@be1))
    actions.should_not have_icon('supprimer', href:bank_account_bank_extract_path(@ba, @be1))
  end
  
  
  describe 'test du menu' do
    
    before(:each) do
      view.stub(:current_user).and_return(@u = mock_model(User, name:'testeur'))
      view.stub('user_signed_in?').and_return true
    end  
  
    it 'nouveau et afficher avec des imported_bels' do
      render template:'bank_extracts/index', layout:'layouts/application'
      local_icons  = page.find('li.horizontal_icons')
      local_icons.should have_icon('nouveau', href:new_bank_account_bank_extract_path(@ba))
      local_icons.should have_icon('afficher',
        href:bank_account_imported_bels_path(@ba))
    end
    
    it 'nouveau et restauration sans imported_bels' do
      @ba.stub(:imported_bels).and_return []
      render template:'bank_extracts/index', layout:'layouts/application'
      local_icons = page.find('li.horizontal_icons')
      local_icons.should have_icon('nouveau', href:new_bank_account_bank_extract_path(@ba))
      local_icons.should have_icon('restauration',
        href:new_importer_bank_account_bels_importer_path(@ba))
      
    end
    
    
  end 

end
