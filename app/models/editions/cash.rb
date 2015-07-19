# coding: utf-8

module Editions 

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  #
  # Cette classe hérite de Editions::Book et surcharge fetch_lines
  # TODO voir pour faire hériter cette classe de Default plutôt que Book
  class Cash < Editions::Book

    
    def fill_default_values
      super 
      @columns_select = ['writings.date AS w_date', 
        'writings.piece_number AS w_piece_number',
        'writings.ref AS w_ref',
        'writings.narration AS w_narration', 'destination_id',
        'nature_id', 'credit', 'debit']
       @columns_methods = ['w_date', 'w_piece_number', 'w_ref', 'w_narration',
        'destination.name', 'nature.name', 'credit', 'debit']
       
       @columns_titles = source.titles
  # ie ['Date', 'Pièce', 'Réf', 'Libellé', 'Activité', 'Nature', 'Sorties', 'Entrées']
       @columns_widths = [12, 6, 6, 28, 12, 12, 12, 12]
       @columns_to_totalize = [6,7]
       @columns_alignements = [:left, :left, :left, :left, :left, :left, :right, :right]
       
    end

   
    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # le rescue nil permet de ne pas générer une erreur si un champ composé n'est
    # pas présent.
    # Par exemple nature.name lorsque nature est nil
    def prepare_line(line)
      pl = columns_methods.collect { |m| line.instance_eval(m) rescue nil }
      pl[1] = pl[1].to_s # pour éviter que format_line (défini dans
      # lib/pdf_document/page.rb) ne transforme ce chiffre
      # comme si c'était un montant en euros
      pl
    end
  end

end
