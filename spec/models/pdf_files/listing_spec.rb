# coding: utf-8

require 'spec_helper'

RSpec.configure do |config| 
  #  config.filter =  {wip:true} 
end





# Classe de test ayant pour objet d'écrire concrètement un fichier pdf 
# TODO changer le nom en Editions:Listing
describe 'Editions::Account qui est l édition d un listing de compte' do
  let(:from_date) {Date.today.beginning_of_year}
  let(:to_date) {Date.today.end_of_year}
  let(:a) {mock_model(Account, 
      compta_lines:stub_compta_lines(100),
      all_lines_locked?:false,
      formatted_sold:['0,00', '0,00']
      )}
  let(:p) {mock_model(Period, long_exercice:'Exercice 2013')}
  
  def render_file(pdf, file_name)
    file =  "#{File.dirname(__FILE__)}/test_pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end
  
  
#    [I18n::l(Date.parse(line.w_date)), line.b_title, line.w_ref, line.w_narration, (line.nature ? line.nature.name  : ''),
#         (line.destination ? line.destination.name  : ''),
#         ActionController::Base.helpers.number_with_precision(line.debit, precision:2),
#         ActionController::Base.helpers.number_with_precision(line.credit, precision:2)]
  def stub_compta_lines(n)
    n.times.collect do |t|
      double(ComptaLine,
      w_id:t,
      w_date:I18n::l(Date.today),
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
    @el = Editions::Listing.new(p,a, {title:'listing du compte',
        :from_date=>from_date,
      :to_date=>to_date})
  @el.stub(:nb_pages).and_return 5
  @el.stub(:organism_name).and_return 'Association Test'
  @el.stub(:fetch_lines).and_return(stub_compta_lines(22))
  end
  
  
  it 'peut créer un Listing' do
    @el.should be_an_instance_of Editions::Listing
   end
   
  it 'et le rendre' do
    @el.render
  end
  
  it 'créée le fichier correspondant' do
    render_file(@el, 'listing')
  end
  
end