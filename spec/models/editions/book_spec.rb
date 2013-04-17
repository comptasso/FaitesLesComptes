# coding: utf-8

require'spec_helper'

describe Editions::Book do

  def line(date, debit, credit)
      double(ComptaLine, ref:'', narration:'Une compta line',
        destination:stub(:name=>'La destination'),
        nature:stub(:name=>'La nature'),
        debit:debit,
        credit:credit,
        date:date,
        writing:stub(payment_mode:'Chèque'),
        support:'Ma banque',
        locked?:true)
    end

  before(:each) do
     @book = mock_model(Book)
     @period = stub(Period, organism:stub(:title=>'L\'organisme'), :exercice=>'Exercice en cours')
     @extract = stub(Utilities::InOutExtract, :book=>@book,
       begin_date:Date.today.beginning_of_year,
       end_date:Date.today.end_of_year,
       'provisoire?'=>true,
     title:'Le livre',
     subtitle:'Le sous titre',
     titles:%w(un deux trois quatre cinq),
     lines:(50.times.collect {line(Date.today, 1.25, 0.3)}))

   
  end

 it 'peut se créer' do
   Editions::Book.new(@period, @extract)
 end

  it 'les différents éléments sont établis' do
    pending 'A faire'
  end

  it 'et peut alors rendre un pdf' do
    pending 'finaliser ces spec quand simple aura été plus avancé'
    eb = Editions::Book.new(@period, @extract)
    eb.render
  end


end