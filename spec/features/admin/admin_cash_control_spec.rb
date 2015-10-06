# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin cashes

describe 'admin cash_control' do
  include OrganismFixtureBis


  before(:each) do
    use_test_user
    login_as(@cu, 'MonkeyMocha')
    use_test_organism
  end


  it 'check minimal organism' do
    Organism.count.should == 1
    Cash.count.should == 1
  end

  it 'les requests de cash control sont à faire'



end

