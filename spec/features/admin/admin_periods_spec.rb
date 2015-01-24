# coding: utf-8

require 'spec_helper'


describe "Periods" do
  include OrganismFixtureBis

  before(:each) do 
    use_test_user
    login_as('quidam')
    use_test_organism 
    @next_period = find_second_period
    # puts "début #{@next_period.inspect}"
  end
  
  after(:each) do
    # puts @next_period.inspect
    @next_period.destroy if @next_period 
    # puts "nombre d exercice #{Period.count}"
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
      page.find('.brand').should have_content "#{(Date.today.year) + 1}"
      visit change_organism_period_path(@o, @p)
      page.find('.brand').should have_content "#{Date.today.year}"
    end
  
end
