# coding: utf-8

require 'spec_helper'

RSpec.configure do |config| 
  #  config.filter =  {wip:true} 
end



# Classe de test ayant pour objet d'écrire concrètement un fichier pdf 
describe 'Editions::Account qui est l édition d un listing de compte' do
  let(:from_date) {Date.today.beginning_of_year}
  let(:to_date) {Date.today.end_of_year}
  let(:a) {mock_model(Account)}
  let(:p) {mock_model(Period)}
  
  def render_file(pdf, file_name)
    file =  "#{File.dirname(__FILE__)}/test_pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end
  
  before(:each) do
    cl = Compta::Listing.new(account_id:a.id, from_date:from_date, to_date:to_date)
    cl.stub(:account).and_return a
    Account.any_instance.stub(:formatted_sold).and_return ['0,00', '0,00']
    Account.any_instance.stub(:fetch_lines).and_return
  end
  
  
  it 'peut créer un listing' do
    cl = Compta::Listing.new(account_id:a.id, from_date:from_date, to_date:to_date)
    cl.should be_an_instance_of(Compta::Listing) 
  end
  
  it 'to_pdf crée un Editions::Account' do
    cl = Compta::Listing.new(account_id:a.id, from_date:from_date, to_date:to_date)
    cl.to_pdf.should be_an_instance_of(Editions::Account) 
  end
  
  # TODO finir ces spec
  
  
  
  
  


end
