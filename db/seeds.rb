# coding: utf-8

# Création d'une base de données test complète pour le développement
#
#
require "#{Rails.root}/db/fill_datas.rb"
# Organism est une petite association culturelle
#
o = Organism.create({:title=>'Association des amoureux des locomotives', :description=>'Notre association entetient et expose des locomtives anciennes'})

# Avec deux lieux d'activité : LILLE et VALENCIENNES qui sont donc ainsi des destinations
   lille = Destination.create({ :organism_id=>o.id, :name=>'Lille'})
   valenciennes = Destination.create({ :organism_id=>o.id, :name=>'Valenciennes'})

# Il y a un livre des recettes et un livre de dépenses
recettes = o.income_books(title: 'Recettes')
depenses = o.outcome_books(title: 'Dépenses')

# Il y a un compte bancaire et deux caisses
o.bank_accounts.create(number: '124578A', name: 'Micro Banque')
o.cashes.create(name: 'Lille')
o.cashes.create(name: 'Valenciennes')

# Trois exercices figurent dans la base de données :
# le premier 2010 est un exercice commencé au 1er avril avec une clôture au 31 décembre. Il sera verrouillé plus loin après

per_2010 = Period.create(:organism_id=>o.id, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2010,12,31))


# Création des comptes
Utilities::PlanComptable.new.create_accounts(per_2010, "comptable.yml")

# les natures de dépenses sont les mêmes pour les trois organismes
RECETTES= {'subventions'=>'708',  'cotisations'=>'706',  'dons'=>'708', 'sorties'=>'706'}

DEPENSES= {'pièces de rechange'=>'61', 'salaires'=>'641', 'charges sociales'=>'645', 'locaux'=>'61', 'fournitures de bureaux'=>'61'}

# Création des natures pour le 1er exercices avec rattachement aux comptes adéquats
RECETTES.each do |k,a|
    acc =per_2010.accounts.find_by_number(a)
    per_2010.natures.create!(name: k, income_outcome: true, account_id: acc.id)
end

DEPENSES.each do |k,a|
    acc =per_2010.accounts.find_by_number(a)
    per_2010.natures.create(name: k, income_outcome: false, account_id: acc.id)
end

per_2010.nb_months.times do |t|
  FillDatas::fill_lines(per_2010, t, t)
end
# le second 2011 est achevé mais non fermé
per_2011 = Period.create(:organism_id=>o.id, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))
per_2011.nb_months.times do |t|
  FillDatas::fill_lines(per_2011, t, 10+t)
end
# le troisième 2012 est en cours. Il ne peut être créé qu'après fermeture du premier
# règle comme quoi on ne peut avoir 3 exercices ouverts
# Verrouillage de toutes les lignes d'écritures de per_2010 (pour pouvoir le fermer)
per_2010.lines.all.each {|l| l.update_attribute(:locked, true)}
per_2010.close

per_2012 = Period.create!(:organism_id=>o.id, :start_date=>Date.civil(2012,01,01), :close_date=>Date.civil(2012,12,31))

3.times do |t| # pour 2012 on ne remplit que les 3 premiers mois
  FillDatas::fill_lines(per_2012, t, 20+t)
end
