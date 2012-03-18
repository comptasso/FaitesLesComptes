# -*- encoding : utf-8 -*-

module OrganismsHelper
 
  def infos(org)

    m=[]
    if org.natures.count == 0
      info = {}
      info[:text] = "Vous devez créez des natures de recettes et de dépenses pour pouvoir saisir des écritures dans les livres"
      info[:icon] = icon_to('nouveau.png', new_admin_organism_period_nature_path(org, @period), title: 'Créer une nature')
      m << info
    end

    if org.number_of_non_deposited_checks > 0
      info= {}
      info[:text] = "<b>#{org.number_of_non_deposited_checks} chèques à déposer</b> pour \
            un montant total de #{number_to_currency org.value_of_non_deposited_checks}".html_safe
      info[:icon] = icon_to('nouveau.png', new_organism_check_deposit_path(org))
      m << info
    end

    org.bank_accounts.each  do |ba|
      if ba.bank_extracts.any? && !ba.bank_extracts.last.locked
        info={}
        info[:text] = "Compte <b>#{sanitize ba.number}</b> : Le pointage du dernier relevé n'est pas encore effectué".html_safe
        info[:icon] = icon_to 'pointer.png', pointage_organism_bank_account_bank_extract_path(org,ba, ba.first_bank_extract_to_point)
        m << info
      end
    end
    org.cashes.each do |ca|
      
      unless ca.cash_controls.any?
        info={}
        info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Pas encore de contrôle de caisse à ce jour".html_safe
        info[:icon] = icon_to 'pointer.png', new_cash_cash_control_path(ca)
        m << info
      end
      if ca.cash_controls.any?
        info={}
        cash_control = ca.cash_controls.order('date ASC').last
        delta =((cash_control.amount - ca.sold(cash_control.date)).abs)
        if delta > 0.001
          info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Ecart de caisse de  #{delta}" if delta > 0.001
          info[:icon] = icon_to 'detail.png', cash_cash_control_path(ca, cash_control)
          m << info
        end
      end
    end
    return m
  end

  # appelé par la vue organism#show pour dessiner chacun des pavés qui figurent 
  # dans le dash board.
  def draw_pave(p, html_class)
    partial_and_class =   case p.class.name
    when 'IncomeBook' then  ['book_pave','income_book']
    when 'OutcomeBook' then  ['book_pave', 'outcome_book']
    when 'Period' then ['result_pave', 'result']
    when 'BankAccount' then ['bank_pave','bank_account']
    when 'Cash' then ['cash_pave', 'cash']
    end
    render partial: partial_and_class[0], object: p,  locals: {:position => "#{partial_and_class[1]} #{html_class}" }
  end


  # menu books prend une collection de livres et crée les entrées de menu correspondants
  # join permet de séparer les entrées entre les différents livres
  def menu_books(books)
    content_tag(:ul, :class=>"dropdown-menu") do
      html = []
      books.each do |b|
         inner =  content_tag(:li, :class=>"nav-header") { link_to b.title, book_lines_path(b), title: b.description}
         inner += content_tag(:li) { link_to 'Ecrire', new_book_line_path(b)}  if @organism.can_write_line?
         inner += content_tag(:li) { link_to 'Afficher', book_lines_path(b) }
         html << inner
      end
      html.join(content_tag(:li, :class=>"divider"){}).html_safe
    end
  end

  # menu bnaks prend une collection de comptes bancaires et crée les entrées de menu correspondants
  # join permet de séparer les entrées entre les différents comptes
  def menu_banks(banks)
    content_tag(:ul, :class=>"dropdown-menu") do
      html = []
      banks.each do |b|
         inner =  content_tag(:li, :class=>"nav-header") { link_to b.to_s, organism_bank_account_path(@organism,b)}
         inner += content_tag(:li) { link_to 'Nlle Remise', new_organism_bank_account_check_deposit_path(@organism,b)}
         inner += content_tag(:li) { link_to 'Pointage', pointage_organism_bank_account_bank_extract_path(@organism,b, b.first_bank_extract_to_point)}  if b.unpointed_bank_extract?
         inner += content_tag(:li) { link_to 'Extraits de comptes', organism_bank_account_bank_extracts_path(@organism, b)}
         inner += content_tag(:li) { link_to 'Nouvel Extrait', new_organism_bank_account_bank_extract_path(@organism,b)}
         html << inner
      end
      html.join(content_tag(:li, :class=>"divider"){}).html_safe
    end
  end

  def menu_cashes(cashes)
    content_tag(:ul, :class=>"dropdown-menu") do
      html = []
      cashes.each do |c|
         inner =  content_tag(:li, :class=>"nav-header") {link_to c.name, cash_path(c) }
         inner += content_tag(:li) {  link_to 'Afficher', cash_cash_lines_path(c)}
         inner += content_tag(:li) {link_to 'Listes contrôles', cash_cash_controls_path(c) }
         inner += content_tag(:li) {link_to 'Ajouter controle ', new_cash_cash_control_path(c) }
         html << inner
      end
      html.join(content_tag(:li, :class=>"divider"){}).html_safe
    end
  end






end

