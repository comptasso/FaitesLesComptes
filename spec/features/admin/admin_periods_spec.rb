# coding: utf-8

require 'spec_helper'


describe "Periods" do
  include OrganismFixtureBis

  before(:each) do
    use_test_user
    login_as(@cu, 'MonkeyMocha')
    use_test_organism
    @next_period = find_second_period
  end

  after(:each) do
    @next_period.destroy if @next_period
  end

     it 'deux exercices' do
       @o.should have(2).periods
     end

     it "par défaut va sur le dernier exercice" do
      visit organism_path(@o)
      current_path.should == organism_path(@o)
     end

    it 'change period' do

      visit organism_path(@o)
      visit change_organism_period_path(@o, @next_period)
      page.find('a#home').should have_content "#{(Date.today.year) + 1}"
      visit change_organism_period_path(@o, @p)
      page.find('a#home').should have_content "#{Date.today.year}"
    end

end
