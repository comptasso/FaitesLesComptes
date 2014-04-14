# coding: utf-8

require 'month_year'

module Extract


  # un extrait d'un livre donné avec capacité à calculer les totaux et les soldes.
  # se crée avec deux paramètres : le livre et l'exercice.
  # 
  # Un enfant de cette classe MonthlyInOutExtract permet d'avoir des extraits mensuels
  # se créé en appelant new avec un book et une date quelconque du mois souhaité
  # my_hash est un hash :year=>xxxx, :month=>yy
  class InOut < Extract::Book

    
    # renvoie les titres des colonnes pour une édition ou un export
    #
    # utilisé par to_csv et to_xls et probablement aussi par to_pdf
    def titles
     ['Date', 'Réf', 'Libellé', 'Activité', 'Nature', 'Débit', 'Crédit', 'Paiement', 'Support']
    end

    # extract_lines est une méthode de IncomeOutcomeBook qui récupère les compta_lines
    # mais connait aussi les writings
    def lines
      @lines ||= @book.extract_lines(from_date, to_date)
    end
    
    alias compta_lines lines

    # produit le document pdf en s'appuyant sur la classe Editions::Book
    def to_pdf      
      Editions::Book.new(@period, self)
    end

    protected

  
    
    #  Utilisé pour l'export vers le csv et le xls
    # 
    # Prend une ligne comme argument et renvoie un array avec les différentes valeurs
    # préparées : date est gérée par I18n::l, les montants monétaires sont reformatés poru
    # avoir 2 décimales et une virgule,...
    # 
    # On ne tronque pas les informations car celà est destiné à l'export vers un fichier csv ou xls
    # 
    def prepare_line(line)
      [I18n::l(line.date),
        line.ref, line.narration,
        line.destination ? line.destination.name : '',
        line.nature ? line.nature.name : '',
        french_format(line.debit),
        french_format(line.credit),
        line.writing.payment_mode,
        line.support
      ]
    end 

  end

end
