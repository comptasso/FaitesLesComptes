# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
   # config.filter =  {wip:true}
end


describe Account do   
  include OrganismFixture 
  
  
  context  'méthode de classe' do

    describe 'available' do

      it 'retourne 5301 si pas encore de compte' do
        clean_test_base
        Account.available('53').should == '5301'
      end
 
      it 'retourne 5301 si organisme est créé' do
        create_organism
        Account.available('53').should == '5301'
      end

    end
  end

  context 'avec un organisme' do

    before(:each) do
      create_minimal_organism
    end

    context  'méthode de classe' do

      describe 'available' do

        it 'retourne 5301 si c est la première caisse' do
          Account.stub_chain(:where, :order).and_return(@ar = double(Arel))
          @ar.stub(:empty?).and_return false
          @ar.stub_chain(:last, :number).and_return '53'
          Account.available('53').should == '5301'
        end

        it 'retourne 5302 avec minimal_organism' do
          Account.available('53').should == '5302'
        end
      end
    end
  
    describe 'solde initial'  do

      before(:each) do
        @acc1 = Account.create!({number:'100', title:'Capital', period_id:@p.id})
        @acc2 = Account.create!({number:'5201', title:'Banque', period_id:@p.id})
        @od.writings.create!(date:Date.today.beginning_of_year, narration:'ecriture d od',
          :compta_lines_attributes=>{'0'=>{account_id:@acc1.id, credit:1000},
            '1'=>{account_id:@acc2.id, debit:1000}})
      end

      it 'sans exercice précédent, et sans report à nouveau, zero' do
        @acc1.init_sold_debit.should == 0
        @acc1.init_sold_credit.should == 0
      end
    
      context 'avec report à nouveau' do
      
      
        before(:each) do
          @o.an_book.writings.create!(date:Date.today.beginning_of_year, narration:'ecriture d an',
            :compta_lines_attributes=>{'0'=>{account_id:@acc1.id, credit:66},
              '1'=>{account_id:@acc2.id, debit:66}})
        end

        it 'sans exercice précédent et avec RAN, donne ce montant' do
          @acc1.init_sold_debit.should == 0
          @acc1.init_sold_credit.should == 66
        end

        it 'donne un an_sold' do
          @acc1.init_sold('debit').should == 0
          @acc1.init_sold('credit').should == 66
        end


    

        context 'avec exercice précédent clos' do

          before(:each) do
            eve = @p.start_date - 1
            @p.stub(:previous_period?).and_return true
            Period.any_instance.stub(:previous_period).and_return @pp = mock_model(Period, close_date:eve, closed?:true)
            Period.any_instance.stub(:previous_period_open?).and_return false
            @pp.stub(:accounts).and_return @arel = double(Arel)

          end

          it 'avec exercice précédent clos, prend le report à nouveau' do
            @acc1.init_sold_debit.should == 0
            @acc1.init_sold_credit.should == 66
          end




        end

      end
    
     
  
    end





    it "un account non valide peut être instancié" do
      Account.new.should_not be_valid
    end

    def valid_attributes
      {number:'601',
        title:'Titre du compte',
        period_id:@p.id
      }
    end

    describe 'validations' do

      before(:each) do
        @account = Account.new(valid_attributes)
        # puts @account.errors.messages unless @account.valid?
      end
  
      it "should be valid"  do
        @account.should be_valid
      end

      describe 'should not be valid lorsque' do

        it 'sans number' do
          @account.number = nil
          @account.should_not be_valid
        end

        it 'sans title' do
          @account.title =  nil
          @account.should_not be_valid
        end

        it 'sans exercice' do
          @account.period = nil
          @account.should_not be_valid
        end
      end
    end

    describe 'polymorphic' do
      it 'la création d\'une caisse entraîne celle d\'un compte' do
        @ba.should have(1).accounts
      end

      it 'la création d\'une caisse entraîne celle d\'un compte' do
        @c.accounts.length.should == 1
      end
    end



    describe 'all_lines_locked?' do

      it 'vrai si pas de lignes' do
        Account.new(valid_attributes).should be_all_lines_locked
      end

      context 'avec des lignes' do
      
    
        before(:each) do
          @account = Account.create!(valid_attributes)
          @n.account_id = @account.id
          @n.save!
          @l1 = create_outcome_writing(97)
          @l2 = create_outcome_writing(3)

        end

        it 'faux si des lignes dont au moins une n est pas locked' do
          @account.should_not be_all_lines_locked
        end
    
        it 'false si une ligne est unlocked' do
          @l1.lock
          @account.should_not be_all_lines_locked
        end

        it 'true si toutes les lignes sont locked' do
          @l1.lock
          @l2.lock
          @account.should be_all_lines_locked
        end
      end

    end

    describe 'fonctionnalités natures' do
      before(:each) do
        @account = Account.create!(valid_attributes)
        @n.account_id = @account.id
        @n.save!
      end

      it 'un compte peut avoir des natures' do
        @account.should have(1).natures
      end
    
   
    end

    describe 'to_pdf' do
      it 'on peut imprimer un listing' do
        # Account.create!(valid_attributes)
        Account.to_pdf(@p).should be_a_instance_of(PdfDocument::Simple)
      end
    end

    describe 'classe' do
      it 'un compte connait sa classe comptable' do
        @account = Account.create!(valid_attributes)
        @account.classe.should == '6'
      end
    end


    

  end

  
end 

