# coding: utf-8

require 'spec_helper'


describe "Periods" do
  include OrganismFixtureBis

  before(:each) do 
    create_user
    create_minimal_organism
    sd = @p.close_date + 1
    cd = ((@p.close_date) +1).end_of_year
    @next_period = @o.periods.create!(:start_date=>sd, :close_date=>cd)
    @o.should have(2).periods
    login_as('quidam')
  end

     it "par défaut va sur le dernier exercice" do
      visit organism_path(@o)
      current_path.should == organism_path(@o)
     end

    it 'change period' do
   
      visit organism_path(@o)
      page.find('.brand').should have_content "Exercice #{(Date.today.year) + 1}"
      visit change_organism_period_path(@o, @p)
      page.find('.brand').should have_content "Exercice #{Date.today.year}"
    end
  
end
