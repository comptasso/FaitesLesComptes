# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  #  c.filter = {wip:true}
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe 'admin destinations' do
  include OrganismFixtureBis

  before(:each) do

    use_test_user
    use_test_organism
    login_as(@cu, 'MonkeyMocha')
  end

  # TODO compléter ces specs

  describe 'vue index' do

    it 'affiche la table des destinations' do
      visit admin_organism_destinations_path(@o)
      page.should have_selector("tbody", :count=>1)
    end

    it 'cliquer sur la case à cocher Used change le champ' do #js:true do
      pending 'problème selenium-webdriver et firefox 35'
      visit admin_organism_destinations_path(@o)
    end

  end
end
