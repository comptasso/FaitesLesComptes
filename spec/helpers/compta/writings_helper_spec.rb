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
  
  describe 'new_compta_line_to_add' do
    
    # on a un tableau de lignes dont on veut garder les lignes entre
    # form-inputs"> et <div><form>
    # donc on prend le texte on le split sur les retours à la ligne
    # on obtient un tableau de lignes dont on élimine toute les lignes
    # y compris form_inputs et les deux dernières lignes de la fin
    let(:p) {mock_model(Period, 
        start_date:Date.today.beginning_of_year, 
        used_accounts:[double(Account, id:1, long_name:'compte 1'),
                        double(Account, id:2, long_name:'Compte 2')])}
    
    before(:each) do
      assign(:period, p)
      assign(:num_line, 5)
      view.stub(:compta_writings_path).and_return('test')
      @writing = Writing.new
      @writing.compta_lines.build
      @tableau = render 'add_line', local:@writing
      @res = helper.new_compta_line_to_add(@tableau)
    end
    
    it 'garde 12 lignes' do
      # 12 lignes correspondent au lignes qui commencent par le label
      # et qui se termine avec le champ debit et credit
      # @res.split("\n").each {|l| puts l}
      expect(@res.split("\n").size).to eq(12)
    end
    
    it 'la première ligne est <div class="row">' do
      expect(@res.split("\n").first).to eq('<div class=\'row\'>')
    end
    
    it 'il n\' y a plus de form' do
      expect(@res.scan('<form').size).to eq(0) 
    end
    
    it 'il y a trois labels' do
      expect(@res.scan('<label').size).to eq(3)
    end
    
    it 'il y a trois input' do
       expect(@res.scan('input').size).to eq(3)
    end
    
  end
end
