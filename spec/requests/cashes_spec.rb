# coding: utf-8

require 'spec_helper'
include JcCapybara
include OrganismFixture

describe "Cashes" do

 before(:each) do
    create_user
    create_minimal_organism
    login_as('quidam')
  end 


  describe "GET /cash_cash_lines" do
    it "without a month params do a redirect" do
      visit cash_cash_lines_path(@c)
      
      page.should have_content 'Exercice 2012'
      page.find('h3 li.active').should have_content(I18n.l(Date.today,format:'%b'))
    end
  end
end
