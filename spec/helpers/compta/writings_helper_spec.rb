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
describe Compta::WritingsHelper do

  describe 'class_style' do
    it 'retourne credit pour une écriture avec un credit' do
      line = double(:credit=>7)
      helper.class_style(line).should == 'credit'
    end

    it 'et debit si credit est nul' do
      line = double(:credit=>0)
      helper.class_style(line).should == 'debit'
    end 
  end
end
