# coding: utf-8

require'spec_helper' 

describe Editions::Cash do 

  def line(date, debit, credit)
      double(ComptaLine, writing_id:1, w_ref:'',w_narration:'Une compta line',
        destination:double(:name=>'La destination'),
        nature:double(:name=>'La nature'),
        debit:debit,
        credit:credit,
        w_date:date,
        w_mode: 'Chèque',
        writing:double(payment_mode:'Chèque'),
        support:'Ma banque',
        locked?:true)
    end

  before(:each) do
     @cash = mock_model(Cash)
     @period = double(Period, organism:double(:title=>'L\'organisme'), :exercice=>'Exercice en cours')
     @extract = double(Extract::InOut, :book=>@cash,
       begin_date:Date.today.beginning_of_year,
       end_date:Date.today.end_of_year,
       'provisoire?'=>true,
     title:'Le livre',
     subtitle:'Le sous titre',
     titles:%w(un deux trois quatre cinq),
     lines:(50.times.collect {line(Date.today, 1.25, 0.3)}))



  end

 it 'peut se créer' do
   Editions::Cash.new(@period, @extract)
 end


# FIXME prepare_line semble être rendu appelé 150 fois, ce qui laisse penser
# que perpare_line est appelé à chaque page pour l'ensemble des 50 lignes
# et non simplement pour les 22 lignes de la page
  it 'et peut alors rendre un pdf' do
    @extract.stub(:instance_eval).and_return(@ar = double(Arel, :count=>50))
    @ar.stub_chain(:select, :offset, :limit).and_return(@extract.lines)
    @eb = Editions::Cash.new(@period, @extract)
    @eb.should_receive(:prepare_line).at_least(50).times.and_return %w(un doux)
    @eb.render
  end


  # FIXME ce ne devrait pas être Date.today mais I18n::l Date.today
  # voir la méthode de Editions::Book.
  it 'prepare_line' do
    Writing.stub(:find_by_id).and_return(double(Writing, support:'CrédiX', :payment_mode=>'Chèque' ))
    @eb = Editions::Cash.new(@period, @extract)
    @eb.prepare_line(line(Date.today, 1.25, 0.3)).should == [Date.today,
        "", 
        "Une compta line",
        "La destination",
        "La nature",
        0.3,
        1.25]

  end


end