# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "#{Rails.root}/app/models/income_outcome_book"
require "#{Rails.root}/app/models/outcome_book"

RSpec.configure do |config|  
 #  config.filter = {wip:true}

end
 
describe Extract::MonthlyBankAccount do
  include OrganismFixtureBis
  before(:each) do
    create_minimal_organism
    @vb = @ba.virtual_book
  end

  describe 'création' do

    let(:y) {Date.today.year}
    let(:m) {Date.today.month}
    let(:h) { {month:m, year:y} }

    it 'peut créer un extrait' do
      Extract::MonthlyBankAccount.new(@vb, h)
    end
  end
end

