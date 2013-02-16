# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
  # c.filter = {:wip=> true }
end

describe BankExtract do   
  include OrganismFixture 
  
  
  before(:each) do
    create_minimal_organism
   
    
    @be2= @ba.bank_extracts.create!( 
      begin_date: Date.today.beginning_of_month,
      end_date: Date.today.end_of_month,
      begin_sold: 2012,
      total_credit: 11,
      total_debit: 10)


  end

  describe 'date_pickers' do
    it 'begin_date_picker'  do
      @be2.begin_date_picker.should == I18n.l(@be2.begin_date) 
    end

    it 'end_date_picker' do
      @be2.end_date_picker.should == I18n.l(@be2.end_date)
    end

    it 'begin_date=' do
      @be2.begin_date_picker = I18n.l Date.today
      @be2.begin_date.should == Date.today
    end

    it 'invalid model if date not acceptable' do
      @be2.begin_date_picker = 'bonjour'
      @be2.valid?
     #  puts @be2.errors.messages
      @be2.should have(2).errors_on(:begin_date_picker) 
      
      @be2.errors[:begin_date_picker].should ==  ['obligatoire', 'Date invalide']
    end
  end


  describe "vérification du scope period" do

    before(:each) do
      @precedent_period = @o.periods.create!(start_date:Date.today.years_ago(1).beginning_of_year, close_date:Date.today.years_ago(1).end_of_year)
      debut_mois = @precedent_period.start_date.months_since(10)
      @be1 = @ba.bank_extracts.create!(begin_date: debut_mois, end_date: debut_mois.end_of_month, begin_sold: 2011, total_credit: 11, total_debit: 10)

    end
    it "le spec de period renvoie @be1 pour 2011 et @be2 pour 2012" do
      @ba.bank_extracts.period(@precedent_period).should == [@be1]
      @ba.bank_extracts.period(@p).should == [@be2]
    end

    

  end

  describe 'vérification des attributs' do

    def valid_attributes
      { begin_sold:0, total_debit:1,
        total_credit:2, begin_date:Date.today, end_date:Date.today}
    end

    before(:each) do
      @be=@ba.bank_extracts.new(valid_attributes)
    end

    it 'valid begin sold' do
      @be.should be_valid
    end

    it 'la date de début doit être dans l\'exercice' do
      @be.begin_date = @p.start_date - 1 
      @be.should_not be_valid
    end

    it 'la date de fin doit être dans l\'exercice' do
      @be.begin_date = @p.close_date + 1
      @be.should_not be_valid
    end

    it 'les deux dates doivent être dans le même exercice' do
      @precedent_period = @o.periods.create!(start_date:Date.today.years_ago(1).beginning_of_year, close_date:Date.today.years_ago(1).end_of_year)
      @be.begin_date = @precedent_period.close_date
      @be.should_not be_valid
      @be.should have(2).errors  # 1 erreurs pour begin_date  et autant pour les date_picker
    end

    it 'end_sold doit être présent' do
      @be.begin_sold = nil
      @be.should_not be_valid
      # puts @be.errors.messages
      @be.should have(3).errors_on(:begin_sold) # numericality presence et format 
    end

    it 'pas valide sans begin_date' do 
      @be.begin_date = nil
      @be.should_not be_valid 
    end

    it 'pas valide sans end_date' do
      @be.end_date = nil
      @be.should_not be_valid
    end

    it 'pas valide sans total_debit' do
      @be.total_debit = nil
      @be.should_not be_valid
    end

    it 'pas valide sans total_credit' do
      @be.total_credit = nil
      @be.should_not be_valid
    end

    it 'begin_sold doît être un nombre' do
      @be.begin_sold = 'bonjour'
      @be.begin_sold.should  == 0
    end

  
    it 'les valeurs sont arrondies par valid' do
      @be.begin_sold = 1.124
      @be.valid?
      @be.should_not be_valid
    end

    it 'testing two decimals validators with valid values' do
      vals = [+1, -1, +1.1, -1.1, +1.12, -1.12, 1.1, 1.12, 256, 256.1, '-.01']
      vals.each do |v|
        @be.begin_sold = v
        @be.valid?
        @be.errors[:begin_sold].should have(0).messages
      end
    end

    it 'testing two decimals validators with invalid values' do
      vals = ['b1', -1.254 , '+1.1b', 1.254]
      vals.each do |v|
        @be.begin_sold = v
        @be.valid?
      
        @be.errors[:begin_sold].should have_at_least(1).messages
      end
    end
  end

  describe 'when locked' do  

    before(:each) do
      @be = @ba.bank_extracts.create!(:begin_date=>Date.today, end_date:Date.today, begin_sold:1,
        total_debit:1, total_credit:2)
      @w1 = create_in_out_writing(97 , 'Chèque')
      @bel = @be.bank_extract_lines.create!(compta_lines:[@w1.support_line])
      @be.locked = true
      @be.save!
    end

    it 'cant be edited' do
      @be.begin_sold = 0
      @be.should_not be_valid
      @be.errors.should have(1).error_on(:begin_sold)
    end
    
    it 'toutes les lignes de l extrait sont verrouillées' do 
      @be.bank_extract_lines.each do |bels|

          bels.compta_lines(true).each {|l| l.should be_locked}
        
      end
    end
    
    it 'toutes les siblings sont verrouillés' do
      @be.bank_extract_lines.each do |bels|
        bels.compta_lines.each do |ls|
          ls.siblings.each {|l| l.should be_locked}
        end
      end
    end


  end

  describe 'contrôle des bank_extract_lines'  do

   before(:each) do
      @l1 = create_in_out_writing(97, 'Chèque') 
      @cd = @ba.check_deposits.new(deposit_date:(Date.today + 1.day))
      @cd.checks << @l1.children.last
      @cd.save!
      
      @bel1 = @be2.bank_extract_lines.new()
      @bel1.compta_lines <<  @cd.debit_line
      @bel1.save!

      @l2 = create_outcome_writing(13)
      @bel2 = @be2.bank_extract_lines.create!(compta_lines:[@l2.support_line])


    end

     

    it "should have two bank_extract_lines" do
      @be2.bank_extract_lines.count.should == 2
    end

    
    it 'total lines debit' do
      @be2.total_lines_debit.should == 97
    end


    it 'total lines credit' do
      @be2.total_lines_credit.should == 13 
    end

    it 'lines belongs to max one bank_extract_line' do
      expect {@be2.bank_extract_lines.new(compta_lines:[@l2.support_line])}.to raise_error(ArgumentError)
    end

    context 'suppression du bank_extract' do
      
      it 'la destruction du bank_extract supprime les bank_extract_lines'  do
        expect {@be2.destroy}.to change {BankExtractLine.count}.by(-2)
      end
 
      it 'et les lines peuvent être de nouveau rattachées' do
        @be2.destroy
        debut_mois = @p.start_date.months_since(10) 
        @be3= @ba.bank_extracts.create!( begin_date: debut_mois, end_date: debut_mois.end_of_month, begin_sold: 2012, total_credit: 11, total_debit: 10)
        @bel3 = @be3.bank_extract_lines.create!(compta_lines:[@l2.support_line])
        @l2.support_line.should have(1).bank_extract_lines
      end


    end

    

  
  end



end

