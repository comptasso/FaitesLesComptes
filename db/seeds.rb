# -*- encoding : utf-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

NATURES= %w( Conseils 'Marchandises Carburant Déplacements Fournitures)
DESTINATIONS= %w(Lille Dunkerque)

Organism.create({:title=>'autoentreprise', :description=>'petite entreprise'})# , {:title=>'CE ste', :description=>'Le CE de la société'}])

Organism.all.each do |o|
  per=Period.create(:organism_id=>o.id, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)
  
  b=BankAccount.create({:name=>'Finansol', :number=>'98745TG12', :organism_id=>o.id})
  c=Cash.create({ :organism_id=>o.id, :name=>'Caisse'})

  NATURES.each do |n|
  Nature.create({ :period_id=>per.id, :name=>n})
  end
  DESTINATIONS.each do |n|
  Destination.create({ :organism_id=>o.id, :name=>n})
  end
  
  Line.create([{
     :line_date=>Date.today,:narration=>'Vente de conseil', :book_id=>i.id,
      :nature_id=>1, :destination_id=>1, :credit=>1245, :bank_account_id=>b.id,
      :payment_mode=>'Virement'},

    {  :line_date=>(Date.today.beginning_of_month+rand(28)),:narration=>'Vente de conseils', :book_id=>i.id,
      :nature_id=>1, :destination_id=>1, :credit=>rand(1000), :payment_mode=>'Chèque'},
     { :line_date=>(Date.today.beginning_of_month+rand(28)),:narration=>'Diagnostic', :book_id=>i.id,
      :nature_id=>1, :destination_id=>1, :credit=>rand(1000), :payment_mode=>'Chèque'},
      { :line_date=>(Date.today.beginning_of_month+rand(28)),:narration=>'Boissons', :book_id=>i.id,
      :nature_id=>1, :destination_id=>1, :credit=>rand(1000), :payment_mode=>'Espèces', :cash_id=>c.id}

  ])

  10.times do
     Line.create({
    :line_date=>Date.today.beginning_of_month+rand(28),:narration=>'Dépenses', :book_id=>ob.id,
      :nature_id=>Random.new.rand(2..4), :destination_id=>Random.new.rand(1..2), :credit=>0.0, :debit=>rand(50), :cash_id=>c.id,
      :payment_mode=>'Espèces'})
  end

  2.times do
     Line.create({
    :line_date=>Date.today.beginning_of_month+rand(28),:narration=>'Dépenses par chèques', :book_id=>ob.id,
      :nature_id=>Random.new.rand(2..4), :destination_id=>Random.new.rand(1..2), :credit=>0.0, :debit=>rand(50), :bank_account_id=>b.id,
      :payment_mode=>'Chèque'})
  end
end


