# coding: utf-8

require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the WritingsHelper. For example:
#
# describe WritingsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe CheckDepositsHelper do

  describe 'options_for_checks' do
    it 'un option for checks ne peut avoir que 2 groupes (target et tank) - un autre crée une exception' do
      expect {OptionsForChecksSelect.new('Déja inclus', :bizarre, 'peu importe').checks}.to raise_error 'Type inconnu'
    end

    it 'quand le type est target, check_deposit renvoie ses chèques' do
      cd= double(Object)
      cd.should_receive(:checks).and_return 'les chèques'
      OptionsForChecksSelect.new('Déja inclus', :target, cd).checks.should == 'les chèques'
    end

    it 'demande les pending checks si tank' do
      cd= double(Object)
      CheckDeposit.should_receive('pending_checks').and_return 'les chèques à remettre'
      OptionsForChecksSelect.new('Déja inclus', :tank, cd).checks.should == 'les chèques à remettre'
    end
  end

end  
