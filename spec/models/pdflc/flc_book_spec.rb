#coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
  # c.filter = {:wip=>true}
end

describe Pdflc::FlcBook do
  
  
  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end 
  
  def five_accounts
    5.times.collect {|i| Account.new(number:"#{i}#{i}#{i}",
        title:"Compte Numero #{i}#{i}#{i}")}
  end
  # ['w_id', 'w_date', 'b_abbreviation', 'w_ref', 'w_narration',
  #    'nat_name', 'dest_name', 'debit', 'credit']
  def twenty_two_lines
    22.times.collect do |i|
      double(ComptaLine, 
        w_id:i+1,
        w_date:Date.today,
        b_abbreviation:'AB',
        w_ref:nil,
        w_narration:'Ecriture',
        nat_name:'nature',
        dest_name:'destination',
        debit:0,
        credit:(i+1)*1.10)
      
    end
  end
  
  # on a deux pages  par compte et 22 lignes à chaque fois
  before(:each) do
    @fas = five_accounts
    Pdflc::FlcTable.any_instance.stub(:nb_pages).and_return 2
    Pdflc::FlcTable.any_instance.stub(:lines).and_return twenty_two_lines
    Pdflc::FlcBook.any_instance.stub(:set_accounts).and_return @fas
    Account.any_instance.stub(:period).and_return(double Period, 
      organism:double(Organism, title:'Asso Essai'),
      long_exercice:'Exercice 2014')
    Account.any_instance.stub(:cumulated_at).and_return 0
    
    @b = Pdflc::FlcBook.new(from_account:@fas.first, 
    to_account:@fas.last, from_date:Date.today.beginning_of_year,
    to_date:Date.today.end_of_year,
    fond:'Mise au point')
  end
  
  # le pdf fera 8 pages, 2 pages pour chacun des comptes sauf pour le second
  # qui n'a pas de lignes.  
  it 'peut rendre le texte avec un fond' do
    @b.stub(:book_arel).and_return(@as = double(Arel, count:44))
    @b.stub(:book_arel).with(@fas.second).and_return(@ar = double(Arel))
    @ar.stub(:count).and_return 0
    @b.draw_pdf
    render_file(@b.pdf, 'book')
  end
  
end