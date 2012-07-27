# coding: utf-8

module PdfDocument

  # la classe Table du module PdfDocument est une classe qui doit alimenter le
  # template de prawn avec les méthodes nécessaires pour fournir
  # la ligne de titre de la table,
  # la ligne de report si elle existe,
  # les lignes de la table
  # la ligne de total de la table
  # la ligne A reporter si nécessaire
  # la ligne Total Général pour la dernière page
  #
  # La classe se constuit à partir d'un numéro de page, d'un nombre de lignes
  # d'une source pour les lignes
  # et des indications de colonnes en terme de largeur,
  # ainsi que le fait de savoir si les colonnes doivent être totalisées ou non
  #
  # C'est le PdfDocument qui définit les colonnes que l'on retient,
  # leur largeur et quelles colonnes on veut totaliser.


  class Table
    def initialize(page, document)
      @page = page
      @document = document
    end

    # retourne la ligne de titre à partir des informations de PdfDocument::Base
    def title
      @document.columns_titles
    end

    # retourne le tableau de lignes à partir du numéro de la page fourni par
    # @page, du nombre de lignes par pages, de la source et de la méthode
    # fournis par PdfDocument::Base
    def lines
      @lines ||= fetch_lines
    end

    def prepared_lines
      lines.collect {|l| prepare_line(l)}
    end

   
    # total_lines renvoie un array correspondant à une première colonne
    # intitulée Total, puis des nils ou des totaux si la colonne a été indiquée
    # par document comme devant être totalisée
    def total_line
      r = []
      @document.columns.each_with_index do |c,i|
        
        if @document.columns_to_totalize.include? i
          r << lines.sum {|l| l.instance_eval(c)}
        else
          r << (i == 0 ? 'Totaux' : '')
        end
       end
      r
   
    end

     # appelles les méthodes adéquate pour chacun des éléments de la lignes
    def prepare_line(line)
      @document.columns_methods.collect do |c|
        line.instance_eval(c)
      end
    end

     
    protected

    def fetch_lines
      select =@document.columns
      limit = @document.nb_lines_per_page
      offset = (@page.number - 1)*limit
      @document.source.lines.select(select).offset(offset).limit(limit)
    end

   

  end

end
