module Jobs

  # Cette classe est un delayed job qui a pour fonction de préparer le
  # contenu du fichier pdf pour un livre de recettes ou de dépenses.
  #
  # Les arguments sont
  # - db_name : la base de données
  # - export_pdf_id : qui est l'id du record export_pdf
  # - options qui est ici seulement un hash avec comme clé period_id
  #
  #
  # Voir la classe BasePdfFiller pour plus de détail
  #
  class SheetsPdfFiller < BasePdfFiller

    # surcharge de la méthode de la classe Base car ici on doit rendre une collection
    # de documents (on pourrait aussi créer une classe dédiée à ça mais pour l'instant
    # je n'ai l'utilisation que pour Sheets.
    def perform
#      Apartment::Database.process(db_name) do
          @export_pdf.content = produce_pdf(@docs).render
          @export_pdf.save
#        end
    end



    protected

    # TODO cette méthode n'est pas à sa place et devrait être également être testée
    # mais ailleurs.

    # prend une collection de documents et les insère dans un document pdf
    def produce_pdf(documents)
      final_pdf = Editions::PrawnSheet.new(:page_size => 'A4', :page_layout => :portrait)
      documents.each do |doc|
        doc.to_pdf.render_pdf_text(final_pdf)
        final_pdf.start_new_page unless doc == @docs.last
      end
      final_pdf.numerote
      final_pdf
    end

    # fournit la variable d'instance document.
    def set_document(options)
      # TODO faire une méthode dans le modèle
        period  = Period.find(options[:period_id])
        nomenclature = period.organism.nomenclature
        # @docs est une collection de Compta::Sheet
        @docs = options[:collection].map do |c|
          fol = nomenclature.folios.find_by_name(c.to_s)
          nomenclature.sheet(period, fol) if fol
        end.reject { |r| r.nil?}

    end



  end


end
