# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|  
  #  config.filter =  {wip:true} 
end


# Classe de test ayant pour objet d'écrire concrètement un fichier pdf 
# à partir d'un livre de recettes ou de dépenses pour en vérifier la présentation.
#
# Attention, du fait des nombreux stub et mock, le test est rapide mais 
# ne permet pas de vérifier que la fonctionnalité est opérationnelle. D'autant 
# qu'elle passe par delayed_jobs.
describe 'Editions::Book qui est l édition d un listing de compte' do
  let(:from_date) {Date.today.beginning_of_year}
  let(:to_date) {Date.today.end_of_year}
  let(:b) {mock_model(Book, 
      compta_lines:stub_compta_lines(100),
      all_lines_locked?:false,
      formatted_sold:['0,00', '0,00'],
      from_date:from_date, to_date:to_date,
      )}
  let(:p) {mock_model(Period, long_exercice:'Exercice 2013')}
  
  def render_file(pdf, file_name)
    file =  "#{File.dirname(__FILE__)}/test_pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end
 
  def stub_compta_lines(n)
    n.times.collect do |t|
      double(ComptaLine,
      writing_id:t,
      
      w_date:I18n::l(Date.today),
      w_piece_number:'31',
      b_abbreviation:(t.even? ? 'VE' : 'AC'),
      w_ref:"Réf #{t}",
      w_narration:"Ecriture n° #{t}",
      nature:double(Object, name:'Une nature'),
      destination:double(Object, name:'Une destination'),
      debit:(t.even? ? t*100 : 0),
      credit:(t.even? ? 0 : t*100 )
      )
    end
  end
  
  before(:each) do
    @eb = Editions::Book.new(p,b)
    @eb.stub(:nb_pages).and_return 5
    @eb.stub(:organism_name).and_return 'Association Test'
    @eb.stub(:fetch_lines).and_return(stub_compta_lines(22))
    Writing.stub(:find_by_id).and_return(double(Writing, support:'Compte courant', payment_mode:'Chèque'))
  end
  
  
  it 'peut créer un Listing' do
    @eb.should be_an_instance_of Editions::Book
   end
   
  it 'et le rendre' do
    @eb.render
  end
  
  it 'créée le fichier correspondant' do
    render_file(@eb, 'livre') 
  end
  
end