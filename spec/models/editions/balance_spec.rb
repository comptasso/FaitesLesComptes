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
       { :account_id=>value,
         :account_title=>"compte #{value}",
         :account_number=>'60'+value.to_s,
         :empty=>false,
         :provisoire=>true,
         :number=>'60'+value.to_s,
         :title=>"compte #{value}",
         :cumul_debit_before=>10,
         :cumul_credit_before=>1,
         :movement_debit=>value,
         :movement_credit=>value*2,
         :sold_at=>1+value*2 - 10 - value}
     end



  before(:each) do

       @b = Compta::Balance.new(valid_arguments)

       @b.stub(:provisoire?).and_return true
       @b.stub(:accounts).and_return(@ar = double(Arel))
       @ar.stub(:collect).and_return (1..100).map {|i| bal_line(2)}
       @ar.stub(:count).and_return 100 
     end

     it 'total_balance renvoie le total'  do
       @b.total_balance.should == [1000, 100, 200, 400, -700]
     end

     it 'should be able to_pdf with 5 pages' do
       pdf = @b.to_pdf
       pdf.should be_an_instance_of(Editions::Balance)
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
     @acc = mock_model(Account, :number=>'152', :title=>'Un compte comme un autre')
     @acc.should_receive(:cumulated_debit_before).with(@b.from_date).and_return 1
     @acc.should_receive(:cumulated_credit_before).with(@b.from_date).and_return 2
     @acc.should_receive(:movement).with(@b.from_date, @b.to_date, :debit).and_return 2000
     @acc.should_receive(:movement).with(@b.from_date, @b.to_date, :credit).and_return 1000225.20
     @acc.should_receive(:sold_at).with(@b.to_date).and_return(5)
     pdf = @b.to_pdf
     pdf.prepare_line(@acc).should == ['152', 'Un compte comme un autre', '1,00', '2,00', '2 000,00', '1 000 225,20', '5,00' ]
   end

end