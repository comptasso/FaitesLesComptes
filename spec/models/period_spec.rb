# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|  
  #  c.filter = {wip:true}
end

describe Period do  
  include OrganismFixtureBis 
  
  def valid_params
    {start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year}
  end

  describe 'validations' do

    before(:each) do
      @org = mock_model(Organism)
      @p  = Period.new(valid_params)
      @p.organism_id = @org.id
    end

    it 'est valide' do
      @p.should be_valid
    end

    it 'non valide sans organism' do
      @p.organism_id = nil
      @p.should_not be_valid
    end

    it 'non valide sans close_date' do
      @p.close_date = nil
      @p.should_not be_valid
    end

    it 'non valide si close date est < start_date' do
      @p.close_date = @p.start_date - 60 
      @p.should_not be_valid
    end

    it 'ne peut durer plus de 24 mois' do
      @p.close_date = @p.close_date + 400
      @p.should_not be_valid
    end

    it 'appelle fix_days avant la validation' do
      @p.should_receive(:fix_days)
      @p.valid?
    end

    it 'fix_days remplit start_date si un exercice précédent et pas de start_date'  do
      Period.stub(:find).with(:last).and_return(stub_model(Period, close_date:(Date.today.beginning_of_year - 1)))
      @p.valid?
      @p.start_date.should == Date.today.beginning_of_year
    end

    it 'ne peut avoir un trou dans les dates' do
      @p.stub(:previous_period?).and_return true
      @p.stub(:previous_period).and_return(stub_model(Period, :close_date=>Date.today.end_of_year.years_ago(2)))
      @p.should_not be_valid
      @p.errors[:start_date].first.should match 'ne peut avoir un trou dans les dates'
    end

      

    it 'n est pas valide si plus de deux exercices ouverts' do
      @p.stub(:max_open_periods?).and_return true
      expect {@p.save}.not_to change {Period.count}
      @p.save
      @p.errors[:base].first.should == 'Impossible d\'avoir plus de deux exercices ouverts'
        
    end

  end
    
  describe 'max_open_periods?'  do
      
    subject {Period.new}
      
    it 'faux si moins de deux exercices ouverts pour cet organisme' do
      subject.stub_chain(:organism, :periods, :opened, :count).and_return 1
      subject.max_open_periods?.should be_false
    end
      
    it 'vrai si moins de deux exercices ouverts pour cet organisme' do
      subject.stub_chain(:organism, :periods, :opened, :count).and_return 2
      subject.max_open_periods?.should be_true
    end
          
  end

  describe 'un exercice est destroyable?' do
     
    subject {Period.new(valid_params)}

    it 's il est le premier' do
      subject.stub('previous_period?').and_return false
      subject.should be_destroyable
    end

    it 's il est le dernier' do
      subject.stub('next_period?').and_return false
      subject.should be_destroyable
    end

    it 'mais pas autrement' do
      subject.stub('next_period?').and_return true
      subject.stub('previous_period?').and_return true
      subject.should_not be_destroyable
    end

  end

  describe 'les fonctionnalités pour trouver un mois'   do
      
    before(:each )do
      # un exercice de mars NN à avril NN+1
      @p = Period.new(start_date: Date.today.beginning_of_year.months_since(2), close_date:Date.today.end_of_year.months_since(4))
    end

    it 'find_month renvoie un mois si 11'  do
      @p.find_month(11).should == [MonthYear.new(month:11, year:Date.today.year)]
    end

    it 'find_first_month trouve le premier des deux possibilités' do
      @p.find_first_month(3).should == MonthYear.new(month:3, year:Date.today.year)
    end

    it 'include month' do
      @p.should be_include_month(3)
    end

    it 'si le mois n est pas compris' do
      @p.close_date = Date.today.beginning_of_year.months_since(6)
      @p.should_not be_include_month(8)
    end

  end
  
  describe 'two_period_accounts'  do

    before(:each) do
      @p1 = Period.new
      @p2 = Period.new
    end

    it 'renvoie la liste des comptes si pas d ex précédent' do
      @p1.stub(:account_numbers).and_return %w(un deux trois)
      @p1.stub('previous_period').and_return @p1
      @p1.two_period_account_numbers.should == %w(un deux trois)
    end

    it 'fait la fusion des listes de comptes si ex précédent'  do
      @p2.stub(:previous_period).and_return @p1
      @p1.stub(:account_numbers).and_return  ['bonsoir', 'salut']
      @p2.stub(:account_numbers).and_return(['alpha', 'salut'])
      @p2.two_period_account_numbers.should == ['alpha', 'bonsoir', 'salut']
    end

    it 'sait retourner le compte de même number'  do
      @p2.stub(:previous_period?).and_return true
      @p2.stub(:previous_period).and_return(@ar = double(Arel))
      acc13 = mock_model(Account, number:'2801')
      @ar.should_receive(:accounts).and_return @ar
      @ar.should_receive(:find_by_number).with('2801').and_return(acc10 = mock_model(Account))
      @p2.previous_account(acc13).should == acc10
    end


    it 'sans compte corresondant previous_account retourne nil' do
      @p2.stub(:previous_period?).and_return true
      @p2.stub(:previous_period).and_return(@ar = double(Arel))
      acc13 = mock_model(Account, number:'2801')
      @ar.should_receive(:accounts).and_return @ar
      @ar.should_receive(:find_by_number).with('2801').and_return(nil)
      @p2.previous_account(acc13).should == nil
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
      @p = Period.new(valid_params, :open=>true)
      @p.stub('accountable?').and_return true
      @p.stub('next_period?').and_return true
      @p.stub(:next_period).and_return(@np = mock_model(Period, :report_account=>'oui'))
      @p.stub(:previous_period).and_return(@pp = mock_model(Period, :open=>false))
      @p.stub_chain(:compta_lines, :unlocked).and_return []
      @p.stub(:organism).and_return mock_model(Organism, :od_books=>[mock_model(OdBook)])
      error_messages
    end

    it 'p feut être fermé' do
      @p.closable?.should == true
    end
    context 'test des messages d erreur' do

      it 'ne peut être ferme si on ne peut pas passer une écriture' do
        @p.should_receive('accountable?').and_return false
        @p.closable?
        @p.errors[:close].should == [@nat_error]
      end

      

      it 'un exercice déja fermé ne peut être fermé' do
        @p.should_receive(:open).and_return(false)
        @p.closable?
        @p.errors[:close].should == [@open_error]
      end

      it 'non fermeture de l exercice précédent' do
        @p.should_receive(:previous_period?).and_return true
        @p.should_receive(:previous_period).and_return(@a=double(Period))
        @a.should_receive(:open).and_return true
        @p.closable?
        @p.errors[:close].should == [@previous_error]
      end

      it 'des lignes non verrouillées' do
        @p.should_receive(:compta_lines).at_least(1).times.and_return( @a = double(Arel) )
        @a.should_receive(:unlocked).at_least(1).times.and_return(@a)
        @a.should_receive(:any?).at_least(1).times.and_return true
        @p.closable?
        @p.errors[:close].should == [@line_error]
      end

      it 'doit avoir un exercice suivant' do
        @p.should_receive(:next_period?).and_return(false)
        @p.closable?
        @p.errors[:close].should == [@next_error]
      end

      it 'doit avoir un livre d OD' do
        @p.should_receive(:organism).and_return(@a=double(Arel))
        @a.should_receive(:od_books).and_return @a
        @a.should_receive('empty?').and_return true
        @p.closable?
        @p.errors[:close].should == [@od_error]
      end


    end

  end

  context 'avec un comité d entreprise et 2 exercices' do
      
    before(:each) do
      create_organism('Comité d\'entreprise')
      @p2 = @o.periods.create!(start_date:(@p.close_date + 1),
        close_date:(@p.close_date >> 12))
      @p2.create_datas
      
    end
      
    after(:each) do
      clean_organism
    end
      
    it 'report_accounts retourne 3 comptes' do
      expect(@p2.report_accounts.count).to eq 3
    end
      
    it 'report_account ne retourne que le compte 12' do
      expect(@p.report_account.number).to eq '12'
    end
      
    context 'avec des écritures de recettes dans chacun des secteurs' do
        
      before(:each) do
        @sasc = Sector.where('name = ?', 'ASC').first
        @sfonc = Sector.where('name = ?', 'Fonctionnement').first
        @sglob = Sector.where('name = ?', 'Commun').first
          
        @basc = @sasc.income_book
        @bfonc = @sfonc.income_book
          
        @accasc = @p.accounts.where('sector_id = ?', @sasc.id).classe_7.first
        @accfonc = @p.accounts.where('sector_id = ?', @sfonc.id).classe_7.first
          
        @nasc = @basc.natures.first
        @nfonc = @bfonc.natures.first
          
        w1 = create_writing(@basc, nature_id:@nasc.id, account_id:@accasc.id)
        w2 = create_writing(@bfonc, nature_id:@nfonc.id, account_id:@accfonc.id, montant:66)
          
        [w1, w2].each {|l| l.lock}
      end
        
      it 'calcul du résultat' do
        cr = Compta::RubrikResult.new(@p, 'passif', '1201')
        expect(cr.brut).to eq -33.33
      end
        
      it 'sait trouver le compte de report' do
        @p2.report_account_for_sector(@sasc).should be_an_instance_of(Account)
        expect(@p2.report_account_for_sector(@sglob).number).to eq '12' 
      end
        
      it 'report à nouveau crée 2 lignes' do
        ran = @p.send(:report_a_nouveau)
        # ran.each {|r| puts r.inspect}
        expect(ran.count).to eq 2          
      end
        
      it 'les reports sont sur les bons comptes' do
        @p.close
        expect(@p.open).to be_false
        # @p2.compta_lines.find_each { |cl| puts cl.inspect}
        @p2.accounts.where('number = ?', '1201').first.sold_at(@p2.close_date).should == -33.33 
        @p2.accounts.where('number = ?', '1202').first.sold_at(@p2.close_date).should == -66
        @p2.accounts.where('number = ?', '12').first.sold_at(@p2.close_date).should == 0.0 
  
      end
         
    end
       
  end
    
  context 'avec un exercice' do
      
    before(:each) do
      use_test_organism
    end
      
    describe 'methodes diverses'  do

      it 'used_accounts ne prend que les comptes actifs' do
        n = @p.accounts.count
        n.should == @p.used_accounts.size
        expect {@p.accounts.first.update_attribute(:used, false)}.to change {@p.used_accounts.count}.by(-1)
      end

      it 'recettes_natures' do
        @p.should_receive(:natures).and_return(@a = double(Arel, :recettes=>%w(bonbons cailloux)))
        @p.recettes_natures.should == %w(bonbons cailloux)
      end

      it 'report à nouveau renvoie une ComptaLine dont le montant est le résultat et le compte 12'  do
        @p.send(:report_a_nouveau).should be_an_instance_of(ComptaLine)
      end
        
      it 'un exercice a un export_pdf' do
        expect {@p.build_export_pdf}.not_to raise_error
      end

    end
  end

    
  context 'avec deux exercices'  do
      
    before(:each) do
      use_test_organism
      @p2 = @o.periods.create!(start_date:(@p.close_date + 1),
        close_date:(@p.close_date >> 12))
      @p2.create_datas
    end
      
    after(:each) do
      @p2.destroy
    end
   
    describe 'period_next'  do
      it "p doit répondre p2" do
        @p.next_period.should == @p2
      end

      it "le dernier exercice renvoie lui même comme exercice suivant" do
        @p2.next_period.should  == @p2
      end
    end

    describe 'close' do

      it 'vérifie closable avant tout' do
        @p.should_receive(:closable?).and_return false
        @p.close.should be_false
      end

      context 'l exerice est closable' do
      
        before(:each) do
          @l6 = create_in_out_writing(60)
          @l7 = create_in_out_writing(55)
          [@l6, @l7].each {|l| l.lock}
        end
        
        after(:each) do
          Writing.delete_all
          ComptaLine.delete_all
          @p.update_attribute(:open, true)
        end

        it "génère les écritures d'ouverture de l'exercice"  do
          @p.close
          @p.should be_closed
        end

        it 'exercice precedent est clos' do
          # TODO à tester ailleurs (avec next_period probablement)
          @p.previous_period_open?.should be_false
        end
      
        it '1 lignes ont été créées' do
          expect {@p.close}.to change {Writing.count}.by(1)
        end

        it 'doit générer une écriture sur le compte 120 correspondant au solde' do
          @p.close
          @p2.report_account.init_sold('credit').should == 115
        end

        context 'gestion des erreurs' do

          it 'retourne false si writing est invalide' do
            Writing.any_instance.stub(:valid?).and_return false
            @p.close.should be_false
          end

          it 'retourne false si writing ne peut être sauvée' do
            Writing.any_instance.stub(:save).and_return false
            @p.close.should be_false
          end

          it 'renvoie true si tout va bien' do
            @p.close.should be_true
          end

        end

      end
    end
    
  end
  
  
  describe 'provisoire?' do
    before(:each) do
      @p = Period.new
      @p.stub(:compta_lines).and_return @r = double(Arel)
      @r.stub(:unlocked).and_return @r
    end
        
    it 'est provisoire si des lignes ne sont pas verrouillées' do
      @r.should_receive(:any?).and_return true
      expect(@p.provisoire?).to be_true
    end
        
    it 'et ne l est pas si toutes les lignes sont verrouillées' do
      @r.should_receive(:any?).and_return false
      expect(@p.provisoire?).to be_false
    end
  end

  describe 'destruction d un exercice' do
    
    before(:each) do
      create_minimal_organism
      
    end
    
    it 'la destruction de l exercice entraîne celle des comptes' do
      nb_accounts = Account.count
      nb_period_accounts = @p.accounts.count
      @p.destroy
      Account.count.should == nb_accounts - nb_period_accounts
    end

    it 'détruit les natures' do
      Nature.count.should > 0
      @p.destroy
      Nature.count.should == 0
    end

    it 'détruit les écritures' do
      Writing.delete_all
      @w = create_in_out_writing
      @p.compta_lines.count.should > 0 
      Writing.count.should > 0
      @p.destroy
      Writing.count.should == 0
      @p.compta_lines(true).count.should == 0
    end

    describe 'détruit les bank_extract et leurs bank_extract_lines'  do

       
      before(:each) do
        BankExtractLine.delete_all
        @w = create_in_out_writing
        @be =  @ba.bank_extracts.create!(begin_date:@p.start_date, end_date:@p.start_date.end_of_month, begin_sold:0, total_debit:0, total_credit:99)
        @be.bank_extract_lines.create!(:compta_line_id=>@w.support_line.id)
      end

      it 'testing bel' do
        BankExtractLine.count.should == 1
      end

      it 'détruit les relevés de banques et les lignes associées' do
        @p.destroy
        @ba.bank_extracts.count.should == 0
        BankExtractLine.count.should == 0
      end

      

    end

  
  end
end
