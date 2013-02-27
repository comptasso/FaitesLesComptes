# coding: utf-8

module Compta
  # GeneralBook est proche de balance, l'instance se crée avec
  # un range de date, un range de comptes
  # Les informations de type balance_line sont utiles à GeneralBook pour
  # pouvoir donner les soldes au début de la période et à la fin de la période
  #
  # La différence essentielle est l'édition du pdf puisqu'on enchaîne en fait des listings
  # de compte.
  #
  # GeneralBook se crée comme Balance soit en fournissant tous les paramètres, soit
  # en fournissant period_id et en appelant with_default_values
  #
  # GeneralBook n'est pas destiné à être affiché à l'écran, il n'a de raison
  # d'être que pour faire une édition papier sous forme de pdf.
  #
  # Pour éviter d'avoir de trop nombreuses pages inutiles, GeneralBook n'imprime pas
  # les comptes inutilisés (ie avec un solde nul de départ, aucune opération et
  # don un solde final nul)
  #
  class GeneralBook < Balance
    # permet de déclarer des colonnes
    def self.columns() @columns ||= []; end

    def self.column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    # malgré l'héritage, il faut déclarer les colonnes
    column :from_date, :string
    column :to_date, :string
    column :from_account_id, :integer
    column :to_account_id, :integer
    column :period_id, :integer

   
    def render_pdf
      to_pdf.render
    end

    protected
    
     # fait une édition du grand livre
     # pour chacun des comptes, faire un listing donc on aura fixé les informations
      # de page : page de début et page total.
      # La classe Listing a donc été enrichie de méthode pour gérer cette question
      # de pagination
      # pour chacun des comptes, on affiche le listing correspondant
      # mais on a d'abord besoin du nombre de pages nécessaires à chacun des comptes
      # pour chacun des comptes on cherche le nombre de pages
      # et on veut le total
    def to_pdf
      final_pdf = Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape)
      range_accounts.each do |a|
        Compta::Listing.new(account_id:a.id, from_date:from_date, to_date:to_date).
          to_pdf({title:'Grand livre', :select_method=>'compta_lines',
            subtitle:"Compte #{a.number} - #{a.title} \n Du #{I18n::l from_date} au #{I18n.l to_date}"} ).
            render_pdf_text(final_pdf)
        final_pdf.start_new_page unless a == range_accounts.last
      end
      final_pdf.number_pages("page <page>/<total>",
        { :at => [final_pdf.bounds.right - 150, 0],:width => 150,
               :align => :right, :start_count_at => 1 })
      final_pdf
    end


  
  end
end
