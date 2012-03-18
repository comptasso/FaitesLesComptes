# coding: utf-8

module Admin::OrganismsHelper

   # menu books prend une collection de livres et crée les entrées de menu correspondants
  # join permet de séparer les entrées entre les différents livres
  def admin_menu_books(books)
    content_tag(:ul, :class=>"dropdown-menu") do
      html = []
      html << content_tag(:li) {link_to 'Listes des livres', admin_organism_books_path(@organism)} +
      content_tag(:li) {link_to 'Nouveau', new_admin_organism_book_path(@organism)} +
      content_tag(:li, :class=>"divider"){}
      books.reject {|r| r.new_record? }.each do |b|
         inner =  content_tag(:li, :class=>"nav-header") { link_to b.title, admin_organism_book_path(@organism,b)}
         inner += content_tag(:li) {link_to 'Modifier', edit_admin_organism_book_path(@organism, b)}
         inner += content_tag(:li) {link_to 'Supprimer',[:admin,@organism, b]}
         html << inner
      end
      html.join(content_tag(:li, :class=>"divider"){}).html_safe
    end
  end

def admin_menu_banks(banks)
    content_tag(:ul, :class=>"dropdown-menu") do
      html = []
      html << content_tag(:li) {link_to 'Listes des comptes', admin_organism_bank_accounts_path(@organism)} +
      content_tag(:li) { link_to 'Nouveau', new_admin_organism_bank_account_path(@organism)}
      
      banks.reject {|r| r.new_record? }.each do |b|
         inner =  content_tag(:li, :class=>"nav-header") { link_to b.number, admin_organism_bank_account_path(@organism,b) }
         inner += content_tag(:li) {link_to  'Modifier', edit_admin_organism_bank_account_path(@organism, b)}
         inner += content_tag(:li) { link_to 'Supprimer', [:admin, @organism, b], confirm: 'Etes vous sur ?' }
         html << inner
      end
      html.join(content_tag(:li, :class=>"divider"){}).html_safe
    end
  end
  
def admin_menu_cashes(cashes)
    content_tag(:ul, :class=>"dropdown-menu") do
      html = []
      html << content_tag(:li) {link_to 'Listes des comptes', admin_organism_cashes_path(@organism)} +
       content_tag(:li) { link_to 'Nouveau', new_admin_organism_cash_path(@organism)}
      
      cashes.reject {|r| r.new_record? }.each do |b|
         inner =  content_tag(:li, :class=>"nav-header") { link_to b.name, admin_organism_cash_path(@organism,b) }
         inner += content_tag(:li) {link_to  'Modifier', edit_admin_organism_cash_path(@organism, b)}
         inner += content_tag(:li) { link_to 'Supprimer', [:admin, @organism, b], confirm: 'Etes vous sur ?' }
         html << inner
      end
      html.join(content_tag(:li, :class=>"divider"){}).html_safe
    end
  end



end