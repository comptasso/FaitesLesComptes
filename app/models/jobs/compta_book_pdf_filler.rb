autoload :ComptaBook, 'extract/book'

module Jobs

  # Cette classe est un delayed job qui a pour fonction de préparer le
  # contenu du fichier pdf pour un livre de recettes ou de dépenses.
  #
  # Les arguments sont
  # - db_name : la base de données
  # - export_pdf_id : qui est l'id du record export_pdf
  # - et des options qui doivent donner l'id de l'exercice (:period_id),
  #   et :an et :mois qui permettent de savoir quel mois est demandé.
  #
  # L'utilisation se fait dans le controller (voir in_out_writings_controller)
  # Delayed::Job.enqueue Jobs::WritingsPdfFiller.new(@organism.database_name,
  # export_pdf.id, {period_id:@period.id, mois:params[:mois], an:params[:an]})
  #
  # L'argument database_name permet de gérer les jobs dans la schéma Public
  # alors que les enregistrements sont dans les schémas particuliers.
  #
  class ComptaBookPdfFiller < BasePdfFiller

    protected

    def set_document(options)
        @book = @export_pdf.exportable
        @period = Period.find(options[:period_id])
        @document = Extract::ComptaBook.new(@book, @period, options[:from_date], options[:to_date])
    end





  end


end
