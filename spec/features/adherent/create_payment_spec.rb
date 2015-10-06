# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts

describe 'enregistrement d un payment' do
  include OrganismFixtureBis


  before(:each) do
    use_test_user
    login_as(@cu, 'MonkeyMocha')
    use_test_organism
    create_first_member(@o)
    visit admin_organism_path(@o)

  end

  after(:each) {Adherent::Member.delete_all}

  it 'test à faire'

end
