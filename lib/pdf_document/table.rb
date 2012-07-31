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
    # lines renvoie donc un Arel
    def lines
      @lines ||= @document.fetch_lines(@page.number)
    end

    # lines renvoie un array
    def prepared_lines
      lines.collect {|l| prepare_line(l)}
    end

   
    # total_lines renvoie un array correspondant à une première colonne
    # intitulée Total, puis des nils ou des totaux si la colonne a été indiquée
    # par document comme devant être totalisée
    def total_line
      # lines est un tableau de lignes dont on veut connaître le total
      # pour chaque colonne qui est dans columns_to_totalize
      r = @document.columns_to_totalize.collect {|index| totalize_column(index)}
      tl = r.collect {|v| format_value(v)}
      tl.insert(0, 'Totaux')
    end

     # appelle les méthodes adéquate pour chacun des éléments de la lignes
     def prepare_line(line)
       @document.prepare_line(line).collect {|v| format_value(v)}
     end

     
    protected

     def format_value(r)
        r = '' if r.nil?
        r = I18n::l(r) if r.is_a? Date
        r = '%0.2f' % r if r.is_a? BigDecimal
        r = '%0.2f' % r if r.is_a? Float
        r = '' if r == '0.00'
        r
     end

     # fait le total des valeurs de la colonne d'indice i
     # n'additionne que s'il en est capable en testant la transformation en Float
     # cela permet d'avoir des valeurs vides dans les colonnes par exemple
     def totalize_column(i)
       prepared_lines.each.sum do |l|
         l[i].to_f if l[i].to_f.is_a?(Float)
       end
     end


    
   

  end

end
