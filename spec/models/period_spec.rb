# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe Period do
 
  before(:each) do
    @organism= Organism.create(title: 'test asso', database_name:'assotest1')
    @p_2010 = @organism.periods.create!(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
    @p_2011= @organism.periods.create!(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
    @ba = @organism.bank_accounts.create!(name:'DebiX', number:'123Z')
  end

  describe 'compte de remise de chèque' do
    it 'sans compte doit le créer et le retourner' do
      @p_2010.rem_check_account.number.should == REM_CHECK_ACCOUNT[:number]
    end

    it 'avec un compte le retourne' do
      # on crée d'abord le compte
      @p_2010.accounts.create!(REM_CHECK_ACCOUNT)
      @p_2010.rem_check_account.number.should == REM_CHECK_ACCOUNT[:number]
      # il ne doit y avoir qu'un seul compte
      @p_2010.accounts.where('number = ?', REM_CHECK_ACCOUNT[:number]).should have(1).account
    end
  end
   
  describe 'period_next' do
    it "2010 doit repondre 2011" do
      @p_2010.next_period.should == @p_2011
    end
  

    it "2011, le dernier doit repondre lui meme" do
      @p_2011.next_period.should  == @p_2011
    end
  end


  # test de la clôture d'un exercice
  # on a donc ici 3 exercices
  describe 'closable?'  do

    def error_messages
      @nat_error = "Des natures ne sont pas reliées à des comptes"
      @compte_12_error = "Pas de compte 12 pour le résultat de l'exercice"
      @open_error = 'Exercice déja fermé'
      @previous_error = "L'exercice précédent n'est pas fermé"
      @line_error = "Toutes les lignes d'écritures ne sont pas verrouillées"
      @next_error = "Pas d'exercice suivant"
      @od_error = "Il manque un livre d'OD pour passer l'écriture de report"
    end

    before(:each) do
      error_messages
    end

    it 'p2010 should not be_closable' do
      @p_2010.closable?
      @p_2010.errors[:close].should == [@nat_error,@compte_12_error]
    end

    context 'test des autres messages d erreur' do

      it 'un exercice déja fermé ne peut être fermé' do
        @p_2010.should_receive(:open).and_return(false)
        @p_2010.closable?
        @p_2010.errors[:close].should == [@open_error, @nat_error,@compte_12_error]
      end
        
      it 'non fermeture de l exercice précédent' do
        @p_2010.should_receive(:previous_period?).and_return true
        @p_2010.should_receive(:previous_period).and_return(@a=double(Period))
        @a.should_receive(:open).and_return true
        @p_2010.closable?
        @p_2010.errors[:close].should == [@previous_error, @nat_error,@compte_12_error]
      end

      it 'des lignes non verrouillées' do
        @p_2010.should_receive(:lines).at_least(1).times.and_return( @a = double(Arel) )
        @a.should_receive(:unlocked).at_least(1).times.and_return(@b = double(Arel))
        @b.should_receive(:any?).at_least(1).times.and_return true
        @p_2010.lines.unlocked.any?.should be_true
        @p_2010.closable?
        @p_2010.errors[:close].should == [@nat_error,@line_error, @compte_12_error]
      end

      it 'doit avoir un exercice suivant' do
        @p_2010.should_receive(:next_period?).and_return(false)
        @p_2010.stub_chain(:lines, :unlocked, :any?).and_return(false)
        @p_2010.closable?
        @p_2010.errors[:close].should == [@nat_error, @next_error, @compte_12_error] 
      end

      it 'doit avoir un livre d OD' do
        @p_2010.should_receive(:organism).and_return   @organism
        @organism.should_receive(:books).and_return(@a=double(Arel))
        @a.should_receive(:find_by_type).with('OdBook').and_return nil
        @p_2010.stub_chain(:lines, :unlocked, :any?).and_return(false)
        @p_2010.closable?
        @p_2010.errors[:close].should == [@nat_error, @od_error, @compte_12_error]
      end


    end

    it 'quand tout est bon' do
      @p_2010.should_receive(:accountable?).and_return(true)
      @p_2010.should_receive(:report_account).and_return(mock_model(Account, number:'12'))
   
      @p_2010.should be_closable
    end



  end

  describe 'closable' do

    it 'vérifie closable avant tout' do
      @p_2010.should_receive(:closable?).and_return false
      @p_2010.close.should be_false
    end

    context 'l exerice est closable' do
      
      before(:each) do
        
        @acc60 = @p_2010.accounts.create!(number:'601', title:'test')
        @acc70 = @p_2010.accounts.create!(number:'701', title:'test')
        @acc61 = @p_2011.accounts.create!(number:'601', title:'test')
        @acc71 = @p_2011.accounts.create!(number:'701', title:'test')
        @n_dep = @p_2010.natures.create!(name:'nature_dep', account_id:@acc60.id)
        @n_rec = @p_2010.natures.create!(name:'nature_rec', account_id:@acc70.id)
        @ob= @organism.books.find_by_type('OutcomeBook')
        @l6= Line.create!(book_id:@ob.id, debit:54, narration:'une ligne de dépense', counter_account:@ba.current_account(@p_2010),
          nature_id:@n_dep.id, payment_mode:'Espèces', cash_id:1,
          line_date:@p_2010.start_date)
        @l7= Line.create!(book_id:@ob.id, debit:99, narration:'une ligne de dépense', counter_account:@ba.current_account(@p_2010),
          nature_id:@n_rec.id, payment_mode:'Espèces', cash_id:1,
          line_date:@p_2010.start_date)
        
      end

      it "génère les écritures d'ouverture de l'exercice"

      it '3 lignes ont été créées' do
        pending
        expect {@p_2010.close}.to change {Line.count}.by(3) 
      end

      it 'doit générer une écriture sur le compte 120 ou 129 correspondant au solde' do
        pending
        @p_2010.next_period.should == @p_2011
        @p_2011.report_account.sold_at(@p_2011).start_date.should == 45
      end

    end
  end
  # result est un module qui est destiné à produire les résultats mensuels d'un exercice
  # c'est aussi ce module qui permet de produire les graphiques résultats
  describe "resultat" do
 
    it "without datas, a period return 0" do
      @p_2010.monthly_value(Date.civil(2010,03,01)).should == 0
    end

    context 'the result is calculated from books' do



      let(:b1) {stub_model(IncomeBook)}
      let(:b2) {stub_model(OutcomeBook)}
     
      P2011_RESULTS = [-5, 10,25,40,55,70,85,100,115,130,145,160]
      P2010_RESULTS = [0,0,0,400, 550, 700, 850, 1000, 1150, 1300, 1450, 1600]
  
 
      before(:each) do

        @p_2011.stub_chain(:books, :all).and_return([b1,b2])
        @p_2010.stub_chain(:books, :all).and_return([b1,b2])
        @p_2011.list_months.each do |m|
          
          b1.stub(:monthly_value).with(m.end_of_month).and_return(100 + 10*(m.month.to_i))
          b2.stub(:monthly_value).with(m.end_of_month).and_return(-120 + 5*(m.month.to_i))
        end
        @p_2010.list_months.each do |m|
          b1.stub(:monthly_value).with(m.end_of_month).and_return(1000 + 100*(m.month.to_i))
          b2.stub(:monthly_value).with(m.end_of_month).and_return(-1200 + 50*(m.month.to_i))
        end
        (1..3).each do |i|
          my=Date.civil(2010,i,1).end_of_month
          b1.stub(:monthly_value).with(my).and_return(0)
          b2.stub(:monthly_value).with(my).and_return(0)
        end
      end

      it "check the monthly result" do 
        @p_2011.monthly_value(Date.civil(2011,03,31)).should == 25
      end

      it 'check_previous_period' do
        @p_2011.previous_period.should == @p_2010
      end

     
      it 'have a default graphic method' do
        @p_2011.graphic(@p_2011).should be_an_instance_of(Utilities::Graphic)
      end

      context "check the default graphic with two periods" do
        before(:each) do
          @p_2011.stub(:previous_period).and_return(@p_2010)
          @graphic= @p_2011.graphic(@p_2011)
        end

        it "should have a legend" do  
          @graphic.legend.should == ['avr. à déc. 2010', 'Exercice 2011']
        end
        it "should have two séries" do 
          @graphic.should have(2).series
        end

        it "the first with ..."   do
          b1.monthly_value(Date.civil(2010,04,30)).should == 1400
          b1.monthly_value(Date.civil(2010,03,31)).should == 0
          @graphic.series[0].should == P2010_RESULTS
        end

        it "the second with..." do
          @graphic.series[1].should == P2011_RESULTS
        end

        

      end
      
      context "check the default graphic with one periods" do
        before(:each) do
          @p_2011.stub(:previous_period?).and_return(false)
          @graphic= @p_2011.default_graphic(@p_2011)
        end

        it "shoudl have only one serie" do
          @graphic.should have(1).serie
        end

        it "checks_list_months" do
          @p_2011.list_months.to_list('%m-%Y').should == %w(01-2011 02-2011 03-2011 04-2011 05-2011 06-2011 07-2011 08-2011 09-2011 10-2011 11-2011 12-2011)
        end


        it "checks the monthly_values" do
          @p_2011.monthly_datas_for_chart(@p_2011.list_months).should == P2011_RESULTS
        end

        it "check the legend"  do
          @graphic.legend.should == ['Exercice 2011']
        end

        it "check the datas" do
          @p_2011.monthly_value(Date.civil(2011,01,31)).should == -5
          @graphic.series[0].should == P2011_RESULTS
        end
      end
    end
  end
 
end
