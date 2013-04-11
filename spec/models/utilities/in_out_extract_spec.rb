# coding: utf-8

require 'spec_helper'
require "#{Rails.root}/app/models/income_outcome_book"
require "#{Rails.root}/app/models/outcome_book"

RSpec.configure do |config|  
#  config.filter = {wip:true}

end
 
describe Utilities::InOutExtract do 
  include OrganismFixture
  before(:each) do
    create_minimal_organism
  end

  it "is created with a book and a date" do
    @book_extract = Utilities::InOutExtract.new(@ob, @p)
  end

  it 'respond to book' do
    @book_extract = Utilities::InOutExtract.new(@ob, @p)
    @book_extract.book.should == @ob
  end

  context "when a InOutExtract exists" do 

    before(:each) do
      # on créé 10 lignes sur le mois de janvier, de montant = à 1 €
      # 10 sur février de montant = à 2 €
      # 10 sur mars avec 3 euros
      start = @p.start_date
      3.times do  |i|
        10.times do |t|
          w = create_outcome_writing(i+1)
          w.update_attribute(:date, start >> i)
        end
      end

      @extract = Utilities::InOutExtract.new(@ob, @p)

    end

    it 'les écritures sont créées' do
      Writing.count.should == 30
    end

    it "has a collection of lines qui sont filtrées par le scope in_out_lines", wip:true do
      
      @extract.lines.all.should == @ob.compta_lines.in_out_lines.order(:id).all
    end

    it 'il y a 30 lignes' do
      @extract.lines.count.should == 30
    end

    it "knows the total debit" do
       @extract.total_debit.should == 60
    end

    it "knows the total credit" do
      @extract.total_credit.should == 0
    end

    it "respond to debit_before" do
      @extract.debit_before.should == 0
    end

    it "respond to debit_before" do
      @extract.credit_before.should == 0
    end

   
  end
end

