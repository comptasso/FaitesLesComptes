# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe 'Modification d une nature' do
  include OrganismFixtureBis


  before(:each) do
    use_test_user
    login_as(@cu, 'MonkeyMocha')
    use_test_organism
  end

  describe 'Changement de nom' do

    before(:each) do
      # création d'un masque dépendant de la nature
      @m = @o.masks.new(book_id:@ob.id, title:'Masque de test', nature_name:@n.name)
      @m.save!
    end

    after(:each) do
      @o.masks.delete_all
    end

    it 'le changement se répercute sur un masque' do
      @n.name = 'Autre nom'
      @n.save
      expect(@o.masks.first.nature_name).to eq('Autre nom')
    end


  end

  describe 'Changement de compte de rattachement' do
    pending 'A faire'
  end

end
