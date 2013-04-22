# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  let(:o) {mock_model(Organism, title:'Ma petite affaire')}

  
  describe 'header_title' do
    
    it 'affiche Faites Les Comptes sans organisme' do
      helper.header_title.should match 'Faites les comptes'
    end

    it 'mais le titre de l\'organisme autrement' do
      assign(:organism, o)
      helper.header_title.should match 'Ma petite affaire'
    end

  end
end

