# coding: utf-8

# Création d'une base de données test complète pour le développement
#
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
# création des écritures
per_2010 = Period.create(:organism_id=>o.id, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2010,12,31))
# le second 2011 est achevé mais non verrouillé
per_2011 = Period.create(:organism_id=>o.id, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))


# les natures de dépenses sont les mêmes pour les trois organismes
RECETTES= %w(subventions  cotisations dons sorties)
DEPENSES= %w(pièces de rechange, salaires, charges sociales, locaux, fournitures de bureaux)

# Création des natures pour les 3 exercices
RECETTES.each do |r|
  o.periods.each do |p|
    p.natures.create!(name: r, income_outcome: true)
  end
end

RECETTES.each do |r|
  o.periods.each do |p|
    p.natures.create(name: r, income_outcome: false)
  end
end

# le troisième 2012 est en cours. Il doit être créé après fermeture du premier
per_2010.close
per_2012 = Period.create(:organism_id=>o.id, :start_date=>Date.civil(2012,01,01), :close_date=>Date.civil(2012,12,31))
RECETTES.each do |r|
  per_2012.natures.create(name: r, income_outcome: true)
end
DEPENSES.each do |r|
  per_2012.natures.create(name: r, income_outcome: false)
end