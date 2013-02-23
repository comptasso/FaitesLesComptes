# coding: utf-8

require 'spec_helper'

describe BankExtractLinesHelper do

  describe 'details_for_popover' do

    before(:each) do
      @bel = mock_model(Writing)
      @bel.stub(:compta_lines).and_return(
      [mock_model(ComptaLine, date:Date.today, narration:'ligne1', debit:10, credit:0),
        mock_model(ComptaLine,date:Date.today, narration:'ligne2', debit:0, credit:205 )
      ]
      )
    end

    it 'donne le détail de lignes chainées' do
      result =  ["<ul><li>#{I18n.l(Date.today)} - ligne1 - 10.00 - 0.00</td></li></ul>", "<ul><li>#{I18n.l(Date.today)} - ligne2 - 0.00 - 205.00</td></li></ul>"]
      helper.details_for_popover(@bel).should == result 
    end


  end


end
