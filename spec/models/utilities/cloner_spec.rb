# coding: utf-8

require 'spec_helper'

describe Utilities::Cloner do
  include OrganismFixtureBis

  before(:each) do
    Tenant.set_current_tenant(1)
    use_test_organism
  end

it 'est instancié avec un organisme' do
  expect(@cl = Utilities::Cloner.new(@o)).to be_an_instance_of(Utilities::Cloner)
  expect(@cl.source).to eq(@o)
end

it 'clone crée un nouvel organisme'

it 'cet organisme a le même tenant'

it 'cet organisme a le même user'

it 'cet organisme a le même holder'

it 'toutes les données sont recopiées à l identique'

it 'les références sont conservées'

end
