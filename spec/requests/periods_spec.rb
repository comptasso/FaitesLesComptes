# coding: utf-8

require 'spec_helper'
include JcCapybara
include OrganismFixture

describe "Periods" do

  before(:each) do
    create_minimal_organism
    sd=@p.close_date + 1
    cd = ((@p.close_date) +1).end_of_year
    @next_period = @o.periods.create!(:start_date=>sd, :close_date=>cd)
    
    @o.should have(2).periods
  end


  describe "Change periods" do

    it 'check periods' do
      @p.exercice.should == 'Exercice 2012'
      @next_period.exercice.should == 'Exercice 2013'
    end

    it "par défaut va sur le dernier exercice" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get organism_path(@o)
      response.status.should be(200)
      assigns(:period).should == @next_period 
      
    end

    it 'change period' do
      visit organism_path(@o)
      page.find('.container').should have_content 'Exercice 2013'
      visit change_organism_period_path(@o, @p)
      page.find('.container').should have_content 'Exercice 2012'  
    end
  end 
end
