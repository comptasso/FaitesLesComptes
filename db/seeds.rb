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
   global = Destination.create({ :organism_id=>o.id, :name=>'Global'})


# Il y a un livre des recettes et un livre de dépenses
recettes = o.income_books(title: 'Recettes')
depenses = o.outcome_books(title: 'Dépenses')

# Il y a un compte bancaire et deux caisses
ba=o.bank_accounts.create(number: '124578A', name: 'Micro Banque')
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

# remplissage des écritures de 2010
FillDatas::fill_full_period(per_2010)

# le second 2011 est achevé mais non fermé
per_2011 = Period.create(:organism_id=>o.id, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))

# remplissage des écritures de 2011
FillDatas::fill_full_period(per_2011)


# le troisième 2012 est en cours. Il ne peut être créé qu'après fermeture du premier
# règle comme quoi on ne peut avoir 3 exercices ouverts
# Verrouillage de toutes les lignes d'écritures de per_2010 (pour pouvoir le fermer)
per_2010.lines.all.each {|l| l.update_attribute(:locked, true)}
per_2010.close

# EXERCICE 2012
per_2012 = Period.create!(:organism_id=>o.id, :start_date=>Date.civil(2012,01,01), :close_date=>Date.civil(2012,12,31))
# remplissage des écritures de 2011
FillDatas::fill_first_quarter(per_2012)

# remplissage des remises de chèques
puts "rempplissage des remises de chèques"
date=per_2010.start_date + 14 # on part du début du premier exeercice
while date < Date.civil(2012,02,29) # jusqu'au 29 février (pour laisser des chèques non remis en banque
 cd= ba.check_deposits.new(deposit_date: date)
 cd.checks.where(['line_date < ?', date]).all.each do |c|
   cd.checks << c
 end
 cd.save! unless cd.checks.empty?
 date +=14 # on fait une remise de chèque toutes les deux semaines
end

# création des extraits bancaires
puts "création des extraits bancaires"
date=per_2010.start_date # on part du début du premier exercice
sold = 0
while date < Date.civil(2012,03,01) # jusqu'au 29 février (pour laisser des chèques non remis en banque
  total_credit=total_debit=0
 be= ba.bank_extracts.new(begin_date: date, end_date: date.end_of_month, begin_sold: sold)
 # on fait le remplissage des bank_extract avec les écritures qui sont dans la période
 nplines = ba.np_lines.select {|l| l.line_date <= date.end_of_month}
 nplines.each do |npl|
  be.bank_extract_lines.new(:line_id=>npl.id)
 end
 total_credit += nplines.sum(&:credit)
 total_debit += nplines.sum(&:debit)
 # on fait également le remplissage avec les remises de chèques qui sont dans la période
 rem_checks = ba.check_deposits.where(['deposit_date <= ? and bank_extract_id IS NULL', date.end_of_month])
 rem_checks.each do |rc|
  be.bank_extract_lines.new(:check_deposit_id=>rc.id)
  puts "remise chèques n° #{rc.id} pour un montant de #{rc.checks.sum(:credit)}"
  total_credit += rc.checks.sum(:credit)
 end
 
 # maintenant on remplit les totaux
 be.total_debit=total_debit
 be.total_credit=total_credit
 be.reference="#{I18n.l date, format: '%y%m'}"
 be.save!
 # fait par le after_save de bank_extract
 # rem_checks.each {|rc| rc.update_attribute(:bank_extract_id, be.id) } # on met à jour les remises chèques pour ne plus les prendre en compte
 puts "Création de l'extrait #{be.id} Débit : #{be.total_debit} - Crédit : #{be.total_credit}"
 sold += be.total_credit-be.total_debit
 date = date.months_since(1) # on fait une remise de chèque tous les mois





end

puts "Verrouillage des extraits bancaires sauf le dernier"
 nb = BankExtract.count
 BankExtract.limit(nb-1).each do |be|
    be.locked = true
    be.save!
 end