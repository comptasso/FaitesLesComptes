## coding: utf-8

module Extract
  #
  # un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
  # 
  #
  class BankAccount < Extract::InOut
  
    # définit les titres des colonnes
    def titles
      ['Date', 'Réf', 'Libellé', 'Dépenses', 'Recettes']
    end

    # pour une banque, les lignes sont obtenues par une relation has_many :compta_lines,
    # :through=>:accounts et par la création d'un virtual book
    def lines
      @lines ||= book.extract_lines(@begin_date, @end_date)
    end

    # produit le document pdf en s'appuyant sur la classe PdfDocument::Book
    def to_pdf
      Editions::BankAccount.new(@period, self)
    end
    
    
    # stocke le rendu du pdf dans la table des Export.
    def render_pdf
      # effacer l'enregistrement exportpdf s'il existe
      Exportpdf.first.destroy if Exportpdf.any?
      exp = Exportpdf.new!(content:to_pdf.render)
      exp.save!  
    end

  
    protected

  
    # ce prepare_line prépare les lignes pour les exports en csv et xls
    #
    # ne pas le confondre avec celui qui préparer les lignes pour le pdf
    # et qui se situe dans la classe Editions::BankAccount
    def prepare_line(line)
    
      [I18n::l(line.date),
        line.ref,
        line.narration.truncate(40),
        french_format(line.credit),
        french_format(line.debit)]
    end

  end


end