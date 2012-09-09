# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config|
#  config.filter = {wip:true}

end
 
describe Utilities::MonthlyBookExtract do
  include OrganismFixture
  before(:each) do
    create_minimal_organism
  end

  it "is created with a book and a date" do
    @book_extract = Utilities::MonthlyBookExtract.new(@ob, year:Date.today.year, month:Date.today.month)
  end

  it 'respond to book' do
    @book_extract = Utilities::MonthlyBookExtract.new(@ob, year:Date.today.year, month:Date.today.month)
    @book_extract.book.should == @ob
  end

  context "when a MonthlyBookExtract exists" , wip:true do

    before(:each) do
      # on créé 10 lignes sur le mois de janvier, de montant = à 1 €
      # 10 sur février de montant = à 2 €
      # 10 sur mars avec 3 euros
      params = {book_id: @ob.id, counter_account_id:@baca.id, nature_id: @n.id, narration: 'test', payment_mode: 'Chèque', bank_account_id: @ba.id}
      2.times do  |i|
        params[:line_date]=@p.start_date.months_since(i)
        params[:debit] = i+1
        10.times {|t| Line.create!(params)}
      end

      # création du MonthlyBookExtract
      @monthly_book_extract = Utilities::MonthlyBookExtract.new(@ob, year:2012, month:2)

    end

    it 'vérifier que MonthlyBookExtract est bien également initialisé avec un hash month et year'

    it "has a collection of lines" do
      @monthly_book_extract.lines.should == @ob.lines.where('line_date >= ? AND line_date <= ? AND owner_id IS NULL',
        @p.start_date.months_since(1), @p.start_date.months_since(1).end_of_month).all
    end

    it 'il y a 10 lignes' do
      @monthly_book_extract.should have(10).lines
    end

    it "knows the total debit" do
       @monthly_book_extract.lines.each {|l| puts l.inspect}
      @monthly_book_extract.total_debit.should == 20
    end

    it "knows the total credit" do
      @monthly_book_extract.total_credit.should == 0
    end

    it "respond to debit_before" do
      @monthly_book_extract.debit_before.should == 10
    end

    it "respond to debit_before" do
      @monthly_book_extract.credit_before.should == 0
    end

    it "gives the sold" do
      @monthly_book_extract.sold.should == -30 # les 10 de débit de janvier et les 20 de février
    end

  end
end

