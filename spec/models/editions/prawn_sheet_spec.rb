# coding: utf-8

require 'spec_helper'

class StubDoc
  def page(number); self; end
  def top_left; 'Top left'; end
  def title; 'Le titre du document'; end
  def top_right; 'Top right'; end
  def stamp; 'Le timbre'; end
  def exercice; 'Exercice 2013'; end
  def table_lines
     [["une rubrique enfant", "-50,25", "-100,00", "49,75", "0,00"],
       ["Une ligne de test", "-50,25", "-100,00", "49,75", "0,00"]] 
  end
  def table_title 
    ['', 'Montant brut', "Amortisst\nProvision", 'Montant net', 'Montant net']
  end
  def columns_alignements; [:left, :right, :right, :right, :right]; end
  def subtitle; nil; end 
  def table_lines_depth; [1,0]; end
  def columns_widths; [40, 15, 15, 15, 15]; end
end

describe Editions::PrawnSheet do
  
  before(:each) do 
    @ps = Editions::PrawnSheet.new
    @doc = StubDoc.new
  end
  
  it 'est une instance de Editions::PrawnSheet' do
    @ps.should be_an_instance_of Editions::PrawnSheet
  end
  
  it 'fill_actif_pdf remplit le pdf' do
    @ps.fill_pdf(@doc)
  end
  
  describe 'style' do
    it 'devrait appeler le style lié à la profondeur de la ligne' do
      pending 'à faire'
    end
  end
  
  
end
