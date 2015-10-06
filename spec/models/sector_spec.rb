require 'spec_helper'

describe Sector do

  describe 'validations' do

    before(:each) do
      Tenant.set_current_tenant(1)
      @s = Sector.new(organism_id:1, name:'Global')
    end

    it 'name peut être Global Commun Fonctionnement ASC ' do
      %w(Global Commun ASC Fonctionnement).each do |nom|
        @s.name = nom
        expect(@s).to be_valid
      end
    end

    it 'le nom est obligatoire' do
      @s.name = nil
      expect(@s).not_to be_valid
    end

    it 'l organisme est obligatoire' do
      @s.organism_id = nil
      expect(@s).not_to be_valid
    end
  end



end
