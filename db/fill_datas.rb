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
    fill_loyers(period)
    fill_salaires(period)
    fill_charges_sociales(period)
    fill_pieces_de_rechange(period)
  end

  def self.fill_first_quarter(period)
    3.times do |t| # pour 2012 on ne remplit que les 3 premiers mois
      fill_lines(period, t, 20+t)
    end
    fill_subventions(period, [2])
    fill_loyers(period,3)
    fill_salaires(period, %w(janvier12  février12 mars12))
    fill_pieces_de_rechange(period, 3)
    # pas de charges sociale encore sur T1 puisqu'on s'arrête à fin mars
  end


  # pour toutes les écritures à périodicité mensuelle
  def self.fill_lines(period, month, decalage)
    self.fill_cotisations(period, month, decalage)
  end


  # le loyer est égale à l'année divsée par 10 et multipliée par 3 pour Lille
  # Seul Lille paye un loayer
  #
  def self.fill_loyers(period, nb_months=nil)
    start_date=period.start_date
    amount=start_date.year*3/10
    nature_id=period.natures.find_by_name('locaux').id
    destination_id=period.organism.destinations.find_by_name('Lille')
    bid=period.organism.outcome_books(title: 'Dépenses').first.id
    bkid=period.organism.bank_accounts.first.id
    nb_months ||= period.nb_months
    nb_months.times do |m|
        Line.create(line_date: start_date.months_since(m) + 10 ,
        narration: 'loyer', nature_id: nature_id,
        destination_id: destination_id, # Lille
        debit: amount, book_id: bid, payment_mode: 'Virement',
        bank_account_id: bkid)
    end

  end

   def self.fill_salaires(period, nb_months=nil)
    h= prepare_ids(period, 'salaires', 'Dépenses', 'Global', 'Virement')
    start_date=period.start_date
    amount=1800*(1 + (start_date.year-Period.first.start_date.year)*0.025 )# 1800 € au départ + 2.5 % d'augmentation par an
    nb_months ||= period.list_months('%B')
    nb_months.each_with_index do |m,i|
        Line.create(line_date: start_date.months_since(i).end_of_month ,
        narration: "salaires de #{m}", nature_id: h[:nature_id],
        destination_id: h[:destination_id], # Lille
        debit: amount, book_id: h[:book_id], payment_mode: 'Virement',
        bank_account_id: h[:bank_account_id])
    end

  end

 

   def self.fill_charges_sociales(period,months=nil)
    h= prepare_ids(period, 'charges sociales', 'Dépenses', 'Global', 'Virement')
    amount=(1800 + (h[:start_date].year-Period.first.start_date.year)*0.025)*3*0.43 # 1800 € au départ + 2.5 % d'augmentation par an
    # 3 fois car on les paye par trimestre, et 43% de taux de charge
    months ||= period.list_months('%m').select { |m| m.to_i%3 == 0 }
    months.each do |m|
        Line.create(line_date: h[:start_date].months_since(m.to_i).end_of_month ,
        narration: "charges sociales trimestrielles", nature_id: h[:nature_id],
        destination_id: h[:destination_id], # Lille
        debit: amount, book_id: h[:book_id], payment_mode: h[:payment_mode],
        bank_account_id: h[:bank_account_id])
   end
   end

    def self.fill_pieces_de_rechange(period,months=nil)
    h= prepare_ids(period, 'pièces de rechanges', 'Dépenses', 'Global', 'Chèque')
    destination_ids=period.organism.destinations.all.map {|d| d.id}
    nb_months ||= period.nb_months
     nb_months.times do |m|
       amount = m%2 == 0 ? (nb_months-m)*100+100 : m*50
        Line.create(line_date: h[:start_date].months_since(m) + 15 ,
        narration: 'pièces pour locomotive', nature_id: h[:nature_id],
       destination_id: destination_ids[m%3], # les destinations sont soit Global soit Lille soit Valenciennes
       # on choisit donc ces destinations à tour de rôle
        debit: amount, book_id: h[:book_id], payment_mode: h[:payment_mode],
        bank_account_id: h[:bank_account_id])
    end

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
    book_id=period.organism.income_books(title: 'Recettes').first.id
    months.each do |m|

      Line.create!(line_date: start_date.months_since(m) + m ,
        narration: 'subvention', nature_id: nature_id,
        destination_id: destination_id, # on alterne une fois sur deux Lille et une autre fois Valenciennes
        credit: amount + m*1000, 
        book_id: book_id,
        payment_mode: 'Virement')
    end

  end

  protected

    def self.prepare_ids(period, nature, book_type, destination, payment_mode)
     h={}
     h[:start_date]=period.start_date.beginning_of_year
     h[:nature_id]=period.natures.find_by_name(nature).id
     h[:destinations_id]=period.organism.destinations.find_by_name(destination).id
     h[:bank_account_id] = period.organism.bank_accounts.first.id if payment_mode == 'Virement'
     h[:book_id]=period.organism.outcome_books(title: book_type).first.id
     h[:payment_mode]= payment_mode
     h
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
    book_id=period.organism.books.find_by_type('IncomeBook').id
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
