# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe Period do 


  describe 'validations' do
    it 'faire les tests de validation' 
  end
  
  describe 'after_create'  do 
    before(:each) do
      @organism= Organism.create(title: 'test asso', database_name:'assotest1')
      @p = @organism.periods.create(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    end
    
    it 'les comptes du fichier asso.yml plus le compte bancaire et le compte de caisse' do
      @p.should have(84).accounts
    end

    it '10 natures de dépenses et 6 de recettes ont été créées' , wip:true do
      @p.should have(16).natures 
    end

  end

  context 'avec deux exercices' do 
 
  before(:each) do
    @organism= Organism.create(title: 'test asso', database_name:'assotest1')
    @p_2010 = @organism.periods.create!(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
    @p_2011= @organism.periods.create!(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
    @ba = @organism.bank_accounts.create!(name:'DebiX', number:'123Z')
  end

  describe 'compte de remise de chèque' do
  
    it 'avec un compte le retourne' do
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
      @p_2010.natures.create!(name:'nouvelle', income_outcome:false)
      @p_2010.closable?
      @p_2010.errors[:close].should == [@nat_error]
    end

    context 'test des autres messages d erreur' do

      it 'un exercice déja fermé ne peut être fermé' do
        @p_2010.should_receive(:open).and_return(false)
        @p_2010.closable?
        @p_2010.errors[:close].should == [@open_error]
      end
        
      it 'non fermeture de l exercice précédent' do
        @p_2010.should_receive(:previous_period?).and_return true
        @p_2010.should_receive(:previous_period).and_return(@a=double(Period))
        @a.should_receive(:open).and_return true
        @p_2010.closable?
        @p_2010.errors[:close].should == [@previous_error]
      end

      it 'des lignes non verrouillées' do
        @p_2010.should_receive(:compta_lines).at_least(1).times.and_return( @a = double(Arel) )
        @a.should_receive(:unlocked).at_least(1).times.and_return(@b = double(Arel))
        @b.should_receive(:any?).at_least(1).times.and_return true
        @p_2010.compta_lines.unlocked.any?.should be_true
        @p_2010.closable?
        @p_2010.errors[:close].should == [@line_error]
      end

      it 'doit avoir un exercice suivant' do
        @p_2010.should_receive(:next_period?).and_return(false)
        @p_2010.stub_chain(:compta_lines, :unlocked, :any?).and_return(false)
        @p_2010.closable?
        @p_2010.errors[:close].should == [@next_error]
      end

      it 'doit avoir un livre d OD' do
        @p_2010.should_receive(:organism).and_return   @organism
        @organism.should_receive(:books).and_return(@a=double(Arel))
        @a.should_receive(:find_by_type).with('OdBook').and_return nil
        @p_2010.stub_chain(:compta_lines, :unlocked, :any?).and_return(false)
        @p_2010.closable?
        @p_2010.errors[:close].should == [@od_error]
      end


    end

    it 'quand tout est bon'  do
      @p_2010.should_receive(:accountable?).and_return(true)
      @p_2010.should_receive(:next_period).at_least(1).and_return(@p_2011)
      @p_2011.should_receive(:report_account).and_return(mock_model(Account, number:'12'))
   #   puts @p_2010.errors[:close].messages unless @p_2010.closable?
      @p_2010.should be_closable
    end



  end

  describe 'close' do

    it 'vérifie closable avant tout' do
      @p_2010.should_receive(:closable?).and_return false
      @p_2010.close.should be_false
    end

    context 'l exerice est closable' do
      
      before(:each) do
        @baca = @ba.current_account(@p_2010)
        @acc60 = @p_2010.accounts.find_by_number '60'
        @acc70 = @p_2010.accounts.find_by_number '701'
        @acc61 = @p_2011.accounts.find_by_number '60'
        @acc71 = @p_2011.accounts.find_by_number '701'
        @n_dep = @p_2010.natures.create!(name:'nature_dep', account_id:@acc60.id)
        @n_rec = @p_2010.natures.create!(name:'nature_rec', account_id:@acc70.id)
        @ob= @organism.books.find_by_type('OutcomeBook')
        @ib= @organism.books.find_by_type('IncomeBook')

        @l6= @ib.in_out_writings.create!({date:Date.civil(2010,8,15), narration:'ligne créée par la méthode create_outcome_writing',
      :compta_lines_attributes=>{'0'=>{account_id:@acc60.id, nature:@n_dep, credit:54, payment_mode:'Espèces'},
        '1'=>{account_id:@baca.id, debit:54, payment_mode:'Espèces'}
      }

    })
        @l7= @ob.in_out_writings.create!({date:Date.civil(2010,8,15), narration:'ligne créée par la méthode create_outcome_writing',
      :compta_lines_attributes=>{'0'=>{account_id:@acc60.id, nature:@n_dep, debit:99, payment_mode:'Espèces'},
        '1'=>{account_id:@baca.id, credit:99, payment_mode:'Espèces'}
      }
    })

        [@l6, @l7].each {|l| l.lock}
        
     end

      it "génère les écritures d'ouverture de l'exercice" do
        @p_2010.close
        @p_2010.should be_closed
      end

      it 'exercice precedent est clos' do
        @p_2010.previous_period_open?.should be_false
      end
      
      it '1 lignes ont été créées' do
        expect {@p_2010.close}.to change {Writing.count}.by(1)
      end

      it 'doit générer une écriture sur le compte 120 correspondant au solde' do
        @p_2010.close
        @p_2011.report_account.init_sold('credit').should == -45
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
end
