# coding: utf-8

require 'spec_helper'

ActiveRecord::Base.shared_connection = nil

###
RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.before :each do
    DatabaseCleaner.start
  end
  config.after :each do
    DatabaseCleaner.clean
  end
end


describe "Periods" do
  include OrganismFixture

  before(:each) do
    create_user
    create_minimal_organism
    sd=@p.close_date + 1
    cd = ((@p.close_date) +1).end_of_year
    @next_period = @o.periods.create!(:start_date=>sd, :close_date=>cd)
    @o.should have(2).periods
 
    ActiveRecord::Base.stub!(:use_org_connection).and_return(true) 
    ActiveRecord::Base.stub!(:use_main_connection).and_return(true)
    login_as('quidam') 
  end

     it "par défaut va sur le dernier exercice" do
      visit organism_path(@o)
      current_path.should == organism_path(@o)
     end

    it 'change period' do
   
      visit organism_path(@o)
      save_and_open_page
      page.find('a.brand').should have_content 'Exercice 2013'
      visit change_organism_period_path(@o, @p)
      page.find('a.brand').should have_content 'Exercice 2012'
    end
  
end
