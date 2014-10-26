#coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
   # c.filter = {:wip=>true}
end

describe Pdflc::FlcTable do
  include OrganismFixtureBis  
  
  describe 'La création ' do
    it 'se fait avec trois arguments' do
      Pdflc::FlcTable.new(1,2,3,4).should be_an_instance_of(Pdflc::FlcTable) 
    end
  end
  
  describe 'sait faire une requete' do
    
    before(:each) do
      @arel = Arel::Table.new(:compta_lines)
      @table = Pdflc::FlcTable.new(@arel, 22, [:debit])
    end
    
    it 'fait une requête avec un offset et une limit' do
      @arel.should_receive(:offset).with(0).and_return @arel
      @arel.should_receive(:limit).with(22).and_return @arel
      @table.lines
    end
    
    
    
    
  end
  
  describe 'avec une base réelle' do
    
    before(:each) do
      use_test_organism
      50.times do |i|
        create_outcome_writing(i+1)
      end
      
      @ar = ComptaLine.
        with_writing_and_book.
        select(['writings.id AS w_id', 'writings.date AS w_date', 'debit']).
        without_AN.range_date(@p.start_date, @p.close_date).
        order(['writings.id ASC'])
      
      @pdft = Pdflc::FlcTable.new(@ar, 22, [:debit], [0])
    end
    
    after(:each) do
      Writing.delete_all
      ComptaLine.delete_all
    end
    
    it 'sait extraire ses 22 lignes' do
      @pdft.lines.should have(22).compta_lines
    end
    
    it 'sait calculer le total' do
       p = Pdflc::FlcTable.new(@ar, 22, [:debit], [0] )
       p.totals.should == [66.to_d] # 11*12/2
       @pdft.totals.should == [66.to_d]
       @pdft.next_page
       @pdft.totals.should == [(23*11 - 66).to_d]
    end 
    
  end
  
  describe 'prepared_line' , wip:true  do
    before(:each) do
      use_test_organism
      @w = create_outcome_writing(10000)
      @ar = ComptaLine.
        with_writing_and_book.
        select(['writings.id AS w_id', 'writings.date AS w_date', 'debit', 'credit']).
        without_AN.range_date(@p.start_date, @p.close_date).
        order(['w_date ASC', 'w_id ASC'])
      @pdf = Pdflc::FlcTable.new(@ar, 22, [:w_id, :w_date, :debit, :credit],
        [2, 3], [1] )
    end
    
    it 'sait mettre en forme les lignes' do
      d = I18n::l(Date.today, format:'%d-%m-%Y')
      @pdf.prepared_lines.should == [
        [@w.id.to_s, d, '10 000,00', '0,00'],
        [@w.id.to_s, d, '0,00', '10 000,00']
      ]
    end
  end
  
  
end