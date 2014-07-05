# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe "in_out_writings/index" do 
  include JcCapybara
     

  def mock_writing_line(montant)
    double(Request::Frontline,
      :ref=>'001',
      :date=>Date.today,
      :narration=>'le libellé',
      :nature_name=>'une dépense',
      :destination_name=>'destinée',
      :debit=>montant,
      :credit=>0,
      :id=>156,
      :payment_mode=>'CB',
      compta_line_id:457,
      acc_title:'Compte courant', 
      writing_type:'InOutWriting',
      'editable?'=>false)
  end
  
  before(:each) do 
    assign(:mois, Date.today.month)
    assign(:an, Date.today.year)
    assign(:book, mock_model(IncomeBook, title:'Recettes'))
    @view.stub(:submenu_mois).and_return(['jan', 'fev']) 
    assign(:monthly_extract, double(Extract::Monthly, frontlines: [], total_debit:0, total_credit:0))
  end

  it 'rend la vue' do
    render 
    page.find('h3').text.should have_content('Recettes : liste des écritures')
  end
  
  context 'avec deux écritures' do
    
    
    before(:each) do
      assign(:monthly_extract, double(Extract::Monthly,
          frontlines: [mock_writing_line(5.25), mock_writing_line(9.9)], total_debit:0, total_credit:0))
    end
    describe 'le corps de la table'  do
    
      it 'a deux lignes' do
        @view.stub(:in_out_line_actions).and_return('stub')
        render
        page.all('tbody tr').should have(2).lines
      end
    end
    
    
  end
  
  
end