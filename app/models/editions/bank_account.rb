# coding: utf-8

module Editions

  # Classe destinée à imprimer le livre virtuel d'un compte bancaire
  # au format pdf
  #
  # Cette classe hérite de Editions::Book et surcharge prepare_line
  #
  # Le résultat est un pdf qui a pour titre 'Livre de Banque' (du fait de la méthode title)
  # et pour sous-titre quelque chose comme 'Compte courant n°
  #
  class BankAccount < Editions::Book

    def fill_default_values
      super 
       @columns_titles = %w(Pièce Date Réf Libellé Dépenses Recettes)
       @columns_select = ['writings.id as w_id', 'writings.date AS w_date', 'writings.ref AS w_ref',
        'writings.narration AS w_narration',  'credit', 'debit']
       @columns_methods =  ['w_id.to_s', 'w_date', 'w_ref', 'w_narration',
        'credit', 'debit']
       @columns_widths = [8, 12, 12, 44, 12, 12]
       @columns_to_totalize = [4,5]
       @columns_alignements = [:left, :left, :left, :left, :right, :right]
       @subtitle = "#{source.book.virtual.bank_name} - n° #{source.book.virtual.number} - " + @subtitle
       
       
    end
    
    

   
    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # le rescue nil permet de ne pas générer une erreur si un champ composé n'est
    # pas présent.
    # Par exemple nature.name lorsque nature est nil
    def prepare_line(line)
      pl = columns_methods.collect { |m| line.instance_eval(m) rescue nil }
      pl[1] = I18n::l(Date.parse(pl[1])) rescue pl[1]
      pl
    end
    
    
    # TODO pour essayer dealyed job; à déplacer ensuite à un niveau plus élevé dans 
    # la hiérarchie
    # Crée le fichier pdf associé
    def render
      pdf_file = PdfDocument::DefaultPrawn.new(:page_size => 'A4', :page_layout => @orientation) 
      pdf_file.fill_pdf(self)
      pdf_file.render
    end
    
  end

end
