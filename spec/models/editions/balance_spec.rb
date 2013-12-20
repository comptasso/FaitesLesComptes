# coding: utf-8

require'spec_helper'

describe 'Editions::Balance' do

  let(:p) {mock_model(Period)} 
  let(:a1) { mock_model(Account) }
  let(:a2) { mock_model(Account) }

   def valid_arguments
      { period_id:p.id,
        from_date:Date.today.beginning_of_month,
        to_date:Date.today.end_of_month,
        from_account_id:a1.id,
        to_account_id:a2.id
      }
    end


   def bal_line(value)
       { "account_id"=>value,
         "title"=>"compte #{value}",
         "number"=>'60'+value.to_s,
         "empty"=>false,
         "provisoire"=>true,
         "cumul_debit_before"=>10,
         "cumul_credit_before"=>1,
         "movement_debit"=>value,
         "movement_credit"=>value*2,
         "sold_at"=>1+value*2 - 10 - value}
     end



  before(:each) do

       @b = Compta::Balance.new(valid_arguments)
       Compta::Balance.any_instance.stub(:balance_lines).and_return (1..100).map {|i| bal_line(2)}
       @b.stub(:provisoire?).and_return true
     #  @b.stub(:balance_lines).and_return (1..100).map {|i| bal_line(2)}
       @b.stub(:accounts).and_return [@a1, @a2]
   #    @ar.stub(:length).and_return 100 
     end

    it 'should be able to_pdf with 5 pages' do
       pdf = @b.to_pdf
       pdf.collection.should_receive(:length).and_return 100
       pdf.nb_pages.should == 5
     end

   it 'before_title renvoie une ligne de titre avec des cellules fusionnées' do
     pdf = @b.to_pdf
     pdf.before_title.should == ['', "Soldes au #{I18n.l(Date.today.beginning_of_month, :format=>'%d/%m/%Y')}",
       'Mouvements de la période',
       "Soldes au #{I18n.l(Date.today.end_of_month, :format=>'%d/%m/%Y')}"
     ]
   end

   it 'prepare_line appelle les méthodes de account' do
     pdf = @b.to_pdf
     lines = pdf.fetch_lines(1)
     pdf.prepare_line(lines.first).should ==  ["602", "compte 2", 10.0, 1.0, 2.0, 4.0, -7.0]
   end

end