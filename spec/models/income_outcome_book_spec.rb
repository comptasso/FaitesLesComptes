# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IncomeOutcomeBook do
  include OrganismFixtureBis

  before(:each) do
    use_test_organism
    @w = create_outcome_writing # montant 99, nature @n, pas de destination
  end

      after(:each) do
        erase_writings
      end

  it 'tests spécifiques à IncomeBook à faire'

  describe 'destruction d un IncomeBook' do
    after(:each) do
      @o.destroy
    end

    it 'la destruction doit entraîner celle des écritures et des compta_lines' do
      wn = Writing.count
      bwn = @ob.writings.count
      cln = ComptaLine.count
      clbn = @ob.in_out_lines.count

      @ob.destroy
      expect(Writing.count).to eq(wn-bwn)
      expect(ComptaLine.count).to eq(cln - (2*clbn))
    end

    it 'et ceci même pour une écriture verrouillée' do
      @w.update_attribute(:locked_at, Time.now)
      wn = Writing.count
      bwn = @ob.writings.count
      cln = ComptaLine.count
      clbn = @ob.in_out_lines.count

      @ob.destroy
      expect(Writing.count).to eq(wn-bwn)
      expect(ComptaLine.count).to eq(cln - (2*clbn))

    end







  end

end

