# coding: utf-8

require 'pdf_document/default'


module PdfDocument



  # La classe PdfRubriks représente une collection de rubriks qui sont destinées
  # à être imprimée dans la longueur maximum d'une page pour former un document
  # de synthèse, telle que l'actif du bilan, le passif, un compte de résultats
  # ou encore le compte de bénévolat pour les associations.
  #
  # PdfRubriks s'appuie sur la classe PdfDocument::Simple ce qui lui permet
  # d'en reprendre la quasi totalité des fonctionnalitées.
  #
  # Par contre le nombre de pages est fixé à 1
  #
  # Et la méthode fetch_lines a la particularité d'être récursive
  #
  # Enfin le template est différent. Notamment, il utilise la méthode depth des
  # rubriks pour modifier la présentation des lignes.
  #
  class PdfRubriks < PdfDocument::Simple

    # on part de l'idée qu'une rubriks prend toujours moins d'une page à imprimer
    # mais surtout actuellement on surcharge pour éviter que source cherche à compter des lignes
    def nb_pages
      1
    end


    # La source doit être une collection de Rubriks qui peuvent elle même
    # être des collections. Lorsque ce n'en est plus une, on a affaire à une
    # Rubrik simple et on la prend donc telle que.
    #
    # A la fin, on rajoute la source, ce qui permettra d'avoir le total du document
    #
    def fetch_lines(page_number = 1)
      fl = []
      @source.collection.each do |c|
        fl += c.to_pdf.fetch_lines if c.class == Compta::Rubriks
        fl << c if c.class == Compta::Rubrik
      end
      fl << @source
      fl
    end

    
  end

end