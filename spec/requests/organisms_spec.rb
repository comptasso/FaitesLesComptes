# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


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

describe "vue organisme"  do
  include OrganismFixture

  context 'avec un organisme' do

  before(:each) do
   #  ActiveRecord::Base.establish_connection(adapter:'sqlite3', database:File.join(Rails.root, 'db','test', 'organisms', 'assotest1.sqlite3') )
    ActiveRecord::Base.stub!(:use_org_connection).and_return(true)
    ActiveRecord::Base.stub!(:use_main_connection).and_return(true) # pour éviter
    # l'appel d'establish_connection dans le before_filter find_organism
   
    create_user
    create_minimal_organism
    visit '/'
    fill_in 'name', :with=>'quidam'
    click_button 'Entrée' 
  end

  it 'should show organism' do
     page.find('h3').should have_content 'Description de l\'organisme'
     current_path.should == admin_organism_path(@o)

  end

  end

  context 'sans organisme' do

    before(:each) do
      @cu = User.create!(name:'untel')
    end

    it 'est dirigé vers la création d un organisme' do
      visit '/'
      fill_in 'name', :with=>'untel'
      click_button 'Entrée'
      current_path.should == new_admin_organism_path
    end

  end
end


