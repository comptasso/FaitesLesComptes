# coding: utf-8

module Editions

  # Classe destinée à imprimer le livre virtuel d'un compte bancaire
  # au format pdf
  #
  # Cette classe hérite de Editions::Book et surcharge fetch_lines
  class BankAccount < Editions::Book

    # TODO comme bank_account_extract est produit en mentionnant une période, on pourrait
    # envisager de faire cette initialisation sans l'argument period.
    def initialize(period, bank_extract)
      super(period, bank_extract)

       set_columns ['writings.date AS w_date', 'writings.ref AS w_ref',
        'writings.narration AS w_narration',  'credit', 'debit']
       set_columns_methods ['w_date', 'w_ref', 'w_narration',
        'credit', 'debit']
       
       set_columns_widths([12, 12, 52,12,12])
       set_columns_to_totalize [3,4]
       set_columns_alignements [:left, :left, :left, :right, :right]
    end

   
    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # le rescue nil permet de ne pas générer une erreur si un champ composé n'est
    # pas présent.
    # Par exemple nature.name lorsque nature est nil
    def prepare_line(line)
      pl = columns_methods.collect { |m| line.send(m) rescue nil }
      pl[0] = I18n::l(Date.parse(pl[0])) rescue pl[0]
      pl
    end
  end

end
