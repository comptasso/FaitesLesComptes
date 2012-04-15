# coding: utf-8
require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the TransfersHelper. For example:
#
# describe TransfersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe TransfersHelper do


  describe 'show_transferable' do
    before(:each) do
       @dc = stub_model(BankAccount, name: 'Debix', number: '123456Z')
       @ca = mock_model(Cash, name: 'Magasin')
    end

    it 'return DebiX Cte N° 124567 if bank_account' do
      @dc.should_receive(:class).and_return BankAccount 
      @dc.should_receive(:to_s).and_return  'Debix Cte n° 124567'
      show_transferable(@dc).should ==  'Debix Cte n° 124567'
    end

    it 'return Magasin if cash' do
      @ca.stub(:class).and_return Cash
      @ca.stub(:name).and_return 'Magasin'
      show_transferable(@ca).should ==  'Magasin'
    end

  end
end
