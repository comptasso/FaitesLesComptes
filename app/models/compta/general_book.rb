# coding: utf-8
require 'pdf_document/default_prawn'
# require 'pdf_document/base_prawn'

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

    # malgré l'héritage, il faut déclarer les colonnes; 
    # voir aussi la classe Balance pour la définition 
    # de la méthode de classe column.
    column :from_date, :string
    column :to_date, :string
    column :from_account_id, :integer
    column :to_account_id, :integer
    column :period_id, :integer

   
    # ne fait qu'appeler la méthode render du Prawn::Document généré par to_pdf
    def render_pdf
      to_pdf.render
    end
 
    # TODO on pourrait rajouter une page de garde
    # TODO gérer l'affichage d'un tampon provisoire
    def to_pdf
      # stamp  = "brouillard" unless account.all_lines_locked?(from_date, to_date)
      # options = {fond:stamp} if stamp
      options = {}
      options[:from_account] = Account.find(from_account_id)
      options[:to_account] = Account.find(to_account_id)
      options[:from_date] = from_date
      options[:to_date] = to_date
      pdf = Pdflc::FlcBook.new(options)
      pdf.draw_pdf
    end
    
#    def to_pdf
#      final_pdf = PdfDocument::DefaultPrawn.new(:page_size => 'A4', :page_layout => :landscape)
#      ras = accounts.select {|ra| ra.compta_lines.any? }
#      ras.each do |a|
#        # crée un Compta::Listing
#        cl = Compta::Listing.new(account_id:a.id, 
#          from_date:from_date, 
#          to_date:to_date).
#          to_pdf
#        
#        final_pdf cl.draw_pdf
#        final_pdf.start_new_page unless a == ras.last # page suivante sauf si le dernier
#      end
#      final_pdf.numerote
#      final_pdf
#    end
# 
    
    protected
    
    def organism_name
      Period.find(period_id).organism.title
    end
    
  end

end