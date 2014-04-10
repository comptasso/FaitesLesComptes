# coding: utf-8

require'spec_helper' 

describe Editions::BankAccount do  

  def line(date, debit, credit)
      double(ComptaLine, writing_id:1, w_ref:'ma réf', w_narration:'Une compta line', 
        debit:debit,
        credit:credit,
        w_date:date, locked?:false)  
    end

  before(:each) do
     @bank_account = mock_model(BankAccount)
     @vb = VirtualBook.new
     @vb.virtual = @bank_account 
     @vb.stub(:extract_lines).and_return (50.times.collect {line(Date.today, 1.25, 0.3)})
     @period = double(Period, start_date:Date.today.beginning_of_month,
       close_date:Date.today.end_of_month,
       organism:double(:title=>'L\'organisme'), :exercice=>'Exercice en cours')
     @extract = Extract::BankAccount.new(@vb, @period)



  end

 it 'peut se créer' do
   Editions::BankAccount.new(@period, @extract)
 end


# FIXME prepare_line semble être rendu appelé 150 fois, ce qui laisse penser
# que perpare_line est appelé à chaque page pour l'ensemble des 50 lignes
# et non simplement pour les 22 lignes de la page
  it 'et peut alors rendre un pdf' do
    pending 'à mettre au point après refonte de PdfTotalized'
    Editions::BankAccount.new(@period, @extract).render
  end


  # FIXME ce ne devrait pas être Date.today mais I18n::l Date.today 
  # voir la méthode de Editions::Book.
  it 'prepare_line' do
    pending
    Writing.stub(:find_by_id).and_return(double(Writing, support:'CrédiX', :payment_mode=>'Chèque' ))
    @eb = Editions::BankAccount.new(@period, @extract)
    @eb.prepare_line(line(Date.today, 1.25, 0.3)).should == [I18n.l(Date.today, format:'%d/%m/%Y'),
        "", 
        "Une compta line",
        "La destination",
        "La nature",
        0.3,
        1.25]

  end


end