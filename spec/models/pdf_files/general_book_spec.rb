# coding: utf-8

require 'spec_helper'
require 'pdf_document/simple'

RSpec.configure do |config| 
  #  config.filter =  {wip:true}
end



# Classe de test ayant pour objet d'écrire concrètement un fichier pdf 
describe 'Edition PDF de GeneralBook' do
  
  let(:p) {mock_model(Period, 
      start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2013')}
  
  def account_lines
    100.times.collect do |t|
      mock_model(ComptaLine, 
        nature:double(Object, name:'Cotisations'), 
        destination:double(Object, name:'Adhérents'),
        w_date:I18n::l(Date.today), w_ref:'Pièce 27', w_narration:'une écriture',
        debit:12,
        credit:0)  
    end
  end
  
  it 'peut créer un general_book' do
        
    @general_book = Compta::GeneralBook.new(period_id:p.id, from_account_id:1, to_account_id:6 )
    @general_book.should  be_an_instance_of(Compta::GeneralBook) 
    
  end
  
  it 'peut créer un pdf' do
    pending 'problème pour faire cette spec'
    PdfDocument::Simple.any_instance.stub(:organism_name).and_return('Asso test')
    @general_book = Compta::GeneralBook.new(period_id:p.id,
      from_account_id:1,
      to_account_id:6,
      from_date:Date.today.beginning_of_year,
      to_date:Date.today.end_of_year
    )
    Account.any_instance.stub(:formatted_sold).and_return( ['0,00', '0,00']) 
    @general_book.stub(:accounts).and_return([@acc1 = mock_model(Account, init_sold:100),
        @acc2 = mock_model(Account, init_sold:0)])
    
    @acc1.stub(:compta_lines).and_return(account_lines)
    @acc2.stub(:compta_lines).and_return(account_lines)
    @general_book.send(:to_pdf)
  end
  
  
end
