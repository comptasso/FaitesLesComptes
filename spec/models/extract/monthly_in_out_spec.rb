# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "#{Rails.root}/app/models/income_outcome_book"
require "#{Rails.root}/app/models/outcome_book"

RSpec.configure do |config|  
 #  config.filter = {wip:true}

end
 
describe Extract::MonthlyInOut do
  include OrganismFixtureBis
  before(:each) do
    create_minimal_organism
  end

  describe 'création' do

    let(:y) {Date.today.year}
    let(:m) {Date.today.month}

    before(:each) do
   
     @book_extract = Extract::MonthlyInOut.new(@ob, year:y, month:m)
    end


  
  it 'respond to book' do
    @book_extract.book.should == @ob
  end

  it 'subtitile rend le mois et l année' do
    @book_extract.subtitle.should == I18n.l(Date.today, :format=>'%B %Y')
  end
  
  it 'a initialité begin_date et end_date' do
    @book_extract.begin_date.should == Date.today.beginning_of_month
    @book_extract.end_date.should == Date.today.end_of_month
  end

    it 'a demandé au livre de trouver l exercice' do
      @ob.should_receive(:organism).and_return(@o)
      @o.should_receive(:find_period).with(Date.today.beginning_of_month).and_return @p
      Extract::MonthlyInOut.new(@ob, year:y, month:m)
    end

    it 'appelle super'  do
      Extract::InOut.should_receive(:new)
      Extract::MonthlyInOut.new(@ob, year:y, month:m)
    end

  end
  
  
  context "when a MonthlyInOutExtract exists" do 

    before(:each) do
      # on créé 10 lignes sur le mois de janvier, de montant = à 1 €
      # 10 sur février de montant = à 2 €
      # 10 sur mars avec 3 euros
      start = @p.start_date
      2.times do  |i|
        10.times do |t|
          w = create_outcome_writing(i+1)
          w.update_attribute(:date, start.months_since(i)) 
        end
      end

      # création du MonthlyInOutExtract puor le mois de février
      @extract = Extract::MonthlyInOut.new(@ob, year:Date.today.year, month:2)

    end

    

    it "has a collection of lines" do
     @extract.lines.should == @ob.writings.where('date >= ? AND date <= ?',
        @p.start_date.months_since(1), @p.start_date.months_since(1).end_of_month).all.map {|w| w.in_out_line}
        
    end

    it 'il y a 10 lignes' do 
      @extract.lines.count.should == 10
    end

    it "knows the total debit" do
       @extract.total_debit.should == 20
    end

    it "knows the total credit" do
      @extract.total_credit.should == 0
    end

    it "respond to debit_before" do
      @extract.debit_before.should == 10
    end

    it "respond to debit_before" do
      @extract.credit_before.should == 0
    end

   
  end
end

