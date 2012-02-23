# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Line do
  
  
  before(:each) do
    @o=Organism.create!(title: 'test_line')
    @ib=IncomeBook.create!(organism_id: @o.id, title: 'Recettes')
    @ob=OutcomeBook.create!(organism_id:@o.id, title: "Dépenses")
    @p=Period.create!(:organism_id=>@o.id, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))
    @n=Nature.create!(name: 'Essai', period_id: @p.id)
  end

   describe "creation de ligne" do
    before(:each) do
      @l=Line.new(:book_id=>@ib.id, :credit=>200 , :line_date=>Date.civil(2012,01,02), :nature_id=>@n.id)
    
    end

    it "should be valid" do

        @l.valid?
        @l.errors.messages.should == {}
      #@l.errors.should == []
    end

   
    it 'should have a line_date' do
      @l.line_date=nil
      @l.should_not be_valid
    end
    it 'debit credit doivent être des nombres avec deux décimales maximum' do
      @l.should_not be_valid if @l.credit= 2.321
      @l.should_not be_valid if @l.credit= '54a2.01'
      @l.should be_valid if @l.credit=2.32
      @l.should be_valid if @l.credit=-502.32 
 
    end   
    it 'doit avoir une nature_id' do
      @l.nature_id=nil
      @l.should_not be_valid
    end
    it 'ne peut pas avoir débit et credit remplis simultanément' do
      pending
      @l.debit=20
      @l.should_not be_valid
    end

    it 'line_date doit correspondre à un exercice' do
      @l.line_date=Date.civil(1999,01,01)
      @l.should_not be_valid
    end
    it 'une ligne ne peut être écrite dans un exercice fermé' do
      p=stub_model(Period, start_date: Date.civil(2011,01,01),close_date: Date.civil(2011,12,31), locked: true)
      @l.line_date= Date.civil(2011,03,15)
      @l.should_not be_valid
    end

    it "should belongs to a book"
  end

  context "vérification des lignes et des soldes sur quelques mois" do

  before(:each) do
    # la somme de 0 à 9 est égale à 45
   
    10.times {|t| Line.create!(:book_id=>@ib.id, :line_date=>Date.civil(2012,01,t+2), :credit=>2*t , :nature_id=>@n.id) }
    10.times {|t| Line.create(:book_id=>@ob.id, :line_date=>Date.civil(2012,01,t+2), :debit=>t , :nature_id=>@n.id) }
    10.times {|t| Line.create(:book_id=>@ib.id, :line_date=>Date.civil(2012,02,t+2), :credit=>3*t , :nature_id=>@n.id) }
    10.times {|t| Line.create(:book_id=>@ob.id, :line_date=>Date.civil(2012,02,t+2), :debit=>2*t , :nature_id=>@n.id) }
    10.times {|t| Line.create(:book_id=>@ib.id, :line_date=>Date.civil(2012,03,t+2), :credit=>4*t , :nature_id=>@n.id) }
    10.times {|t| Line.create(:book_id=>@ob.id, :line_date=>Date.civil(2012,04,t+2), :debit=>5*t , :nature_id=>@n.id) }

  end
  context 'verification que les lignes sont bien là' do

    it "vérif qu on a bien les lignes" do
      Line.count.should == 60
      end

      it 'income and outcomme should each have 30 lines' do
          @ib.lines.should have(30).elements
        @ob.lines.should have(30).elements
      end

    it "scope month return the right number of lines" do
      Line.month('01-2012').should have(20).elements
    end
  end

  it "give a monthly sold" do
    Line.monthly_sold('01-2012').should == 45
    Line.monthly_sold('02-2012').should == 45
    Line.monthly_sold('03-2012').should == 180
    Line.monthly_sold('04-2012').should == -225
  end

  end

 
end

