# coding: utf-8

# TODO voir pour étendre la classe Period  puisque ce module ne
# sert que pour seeds.rb
# ou en faire une classe data_filler

module FillDatas

  def self.fill_accounts(period)
    Utilities::PlanComptable.new.create_accounts(period, "comptable.yml")
  end

  def self.fill_lines(period, month, decalage)
    self.fill_cotisations(period, month, decalage)
  end

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
