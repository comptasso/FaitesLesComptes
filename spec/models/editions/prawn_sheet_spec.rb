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
  def subtitle; nil; end 
  def table_lines_depth; [1,0]; end
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
    @ps.fill_actif_pdf(@doc)
  end
  
  it 'fill_passif_pdf remplit le pdf' do
    @doc.stub(:table_lines).and_return  [["une rubrique enfant", "49,75", "0,00"],
       ["Une ligne de test", "49,75", "0,00"]] 
    @ps.fill_passif_pdf(@doc)
  end
  
  
  
end
