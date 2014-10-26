#coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
  # c.filter = {:wip=>true}
end

describe Pdflc::FlcPage do
  include OrganismFixtureBis
  
  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end  
  
  def set_table(account, from_date, to_date)
    cls = ['writings.id AS w_id', 'writings.date AS w_date', 
      'books.abbreviation AS b_abbreviation', 
      'writings.ref AS w_ref',
      'writings.narration AS w_narration', 
      'nature_id',
      'destination_id',
      'debit',
      'credit']
    champs = ['w_id', 'w_date', 'b_abbreviation', 'w_ref', 'w_narration',
      'nature_id', 'destination_id', 'debit', 'credit']
 
    ar = account.compta_lines.with_writing_and_book.
      select(cls).without_AN.range_date(from_date, to_date)
    
    Pdflc::FlcTable.new(ar, 1, 22, champs, [7, 8], [1] )
  end
  
  def set_pdf
    Pdflc::FlcPage.new(%w(N° Date Jnl Réf Libellé Nature Activité Débit Crédit), # les titres
      [6, 8, 6, 8, 24, 15, 15, 9, 9], # les largeurs
      7.times.collect {:left} + 2.times.collect {:right}, # les alignements
      [0, 10.56],  # les reports
      @flc_table, @flc_trame) 
  end
  
  before(:each) do
    use_test_organism
    @flc_trame = Pdflc::FlcTrame.new(title:'Le titre', subtitle:'Le sous-titre',
      organism_name:@o.title, exercice:@p.exercice)
    acc = @p.accounts.classe_7.first
    @flc_table = set_table(acc, @p.start_date, @p.close_date)
  end
  
#  it 'un fichier vierge' do
#    pdf = set_pdf
#  
#    pdf.should be_an_instance_of(Pdflc::FlcPage)
#    pdf.draw_pdf(1)
#    render_file(pdf, 'listing')
#  end
  
  describe 'avec des lignes' do
    
    before(:each) do
      @flc_table.stub(:prepared_lines).and_return(
        22.times.collect do |i|
          [i, Date.today.to_s, 'AB', i, 'une écriture', 'nid', 'did', i, i]
        end
      )
      @flc_table.stub(:totals).and_return([200.14, 540.12])
      @pdf = set_pdf
    end
    
    after(:each) do
      Writing.delete_all
      ComptaLine.delete_all
    end
    
    it 'sait caluler ses totaux' do
      totrs = @pdf.to_reports
      totrs.should == [200.14, 550.68]
    end
    
    it 'peut rendre les lignes' do
      @pdf.draw_pdf(1)
      # render_file(@pdf, 'listing')
    end
    
    it 'peut rendre plusieurs pages' do
      @pdf.draw_pdf(3)
      render_file(@pdf, 'listing')
    end
  end
  
  
  
  
end