# coding: utf-8

# TODO voir pour étendre la classe Period  puisque ce module ne
# sert que pour seeds.rb
# ou en faire une classe data_filler

module FillDatas

  def self.fill_accounts(period)
    Utilities::PlanComptable.new.create_accounts(period, "comptable.yml")
  end

  def self.fill_full_period(period)
    period.nb_months.times do |t|
      fill_lines(period, t, t)
    end
    fill_subventions(period, [2,8])
  end

  def self.fill_first_quarter(period)
    3.times do |t| # pour 2012 on ne remplit que les 3 premiers mois
      fill_lines(period, t, 20+t)
    end
    fill_subventions(period, [2])
  end


  # pour toutes les écritures à périodicité mensuelle
  def self.fill_lines(period, month, decalage)
    self.fill_cotisations(period, month, decalage)
  end



  # 2 subventions par an, l'une correspondant à 10 fois le montant de l'année,
  # l'autre à 15 fois, touchées le 10 mars et l'autre le 20 septembre
  # les subventions sont affectées à la destination Global (celle qui ne permet
  # pas de distinguer entre les deux sites
  def self.fill_subventions(period, months)
    start_date=period.start_date
    amount = period.start_date.year*10
    nature_id=period.natures.find_by_name('subventions').id
    destination_id =period.organism.destinations.find_by_name('Global').id
    book_id=period.organism.books.find_by_type('IncomeBook')
    months.each do |m|

      Line.create!(line_date: start_date.months_since(m) + m , narration: 'subvention', nature_id: nature_id,
        destination_id: destination_id, # on alterne une fois sur deux Lille et une autre fois Valenciennes
        credit: amount + m*1000, book_id: book_id, payment_mode: 'Virement')
    end

  end

  protected

  # fill_lines va remplir les lignes de comptes pour un mois (month) d'un exercice (period)
  # les montants sont prédéterminés mais décalage permet de les modifier
  def self.fill_cotisations(period, month, decalage)
    # on a dix cotisations qui rentrent dont 8 en chèque et 2 en espéces
    # une sur la caisse de Lille, l'autre sur la caisse de Valenciennes
    # le montant est de 80 € plus décalage
    # la date part du 1 et avance par pas de 2
    start=period.start_date.months_since(month)
    amount=80 + decalage
    nature_id=period.natures.find_by_name('cotisations').id
    destinations=period.organism.destinations.map{|d| d.id}
    book_id=period.organism.books.find_by_type('IncomeBook')
    8.times do |t|
      Line.create!(line_date:start+2*t, narration: 'cotisation', nature_id: nature_id,
        destination_id: destinations[t%2], # on alterne une fois sur deux Lille et une autre fois Valenciennes
        credit: amount, book_id: book_id, payment_mode: 'Chèque')
    end
    cashes=period.organism.cashes.map{|d| d.id}
    Line.create!(line_date:start+16, narration: 'cotisation', nature_id: nature_id,
      destination_id: destinations[0],credit: amount, book_id: book_id, payment_mode: 'Espèces', cash_id: cashes[0])
    Line.create!(line_date:start+18, narration: 'cotisation', nature_id: nature_id,
      destination_id: destinations[1],credit: amount, book_id: book_id, payment_mode: 'Espèces',cash_id: cashes[1] )
  end

end
