# coding: utf-8

require 'pdf_document/table_line'

module PdfDocument

  # TODO : on devrait se passer de document car page connait document

  # la classe Table du module PdfDocument est une classe qui doit alimenter le
  # template de prawn avec les méthodes nécessaires pour fournir
  # la ligne de titre de la table,
  # la ligne de report si elle existe, 
  # les lignes de la table
  # la ligne de total de la table
  # la ligne A reporter si nécessaire
  # la ligne Total Général pour la dernière page
  #
  # La classe se constuit à partir d'une page d'un document.
  # La variable d'instance
  # et des indications de colonnes en terme de largeur,
  # ainsi que le fait de savoir si les colonnes doivent être totalisées ou non
  #
  # C'est le PdfDocument qui définit les colonnes que l'on retient,
  # leur largeur et quelles colonnes on veut totaliser.
  #
  #
  class Table
    attr_reader :page, :document

    def initialize(page)
      @page = page
      @document = page.document
    end

    # retourne la ligne de titre à partir des informations de PdfDocument::Default
    def title
      document.columns_titles
    end

    # retourne le tableau de lignes à partir du numéro de la page fourni par
    # page, du nombre de lignes par pages, de la source et de la méthode
    #
    # fournis par PdfDocument::Default
    # lines renvoie donc un Arel
    def lines
      @lines ||= document.fetch_lines(page.number)
    end

    # lines renvoie un array
    def prepared_lines
      @prepared_lines ||= lines.collect {|l| prepare_line(l)} if lines
    end

    # renvoie un array des profondeur de lignes. Utilisé par rubriks.pdf.prawn pour
    # préciser les styles des lignes
    # La profondeur 0 est en maigre, la 1 en gras, la 2 en plus gras encore,...
    #
    def depths
      @depths ||= lines.map do |l|
        if l.respond_to? 'depth'
          l.depth
        else
          nil
        end
      end
    end

   
    # total_lines renvoie un array correspondant à une première colonne
    # intitulée Total, puis des nils ou des totaux si la colonne a été indiquée
    # par document comme devant être totalisée.
    # total_line fait ensuite un formatage des valeurs avant de rajouter le mot Totaux
    # dans une première colonne.
    def total_line
      r = document.columns_to_totalize.collect {|index| totalize_column(index)}
      r.insert(0, 'Totaux')
    end

    # demande au document de préparer la ligne
    # TODO à éliminer dès que possible
    def prepare_line(line)
      if line.is_a?(PdfDocument::TableLine)
        line.prepared_values
      else
        Rails.logger.warn 'L\'appel d\'une méthode prepare_line du document est dépréciéé. Il faut utiliser des TableLine'
        document.prepare_line(line)
      end
    end

    
 
    protected

        
    # fait le total des valeurs de la colonne d'indice i
    # modifie d'abord les valeurs en transformant en Float.
    #
    # Pour que les totaux fonctionnent sur les chiffres français,
    # il faut enlever les espaces et remplacer les virgules par des
    # points.
    # TODO supprimer le if lorsqu'on aura passé toutes les éditions 
    # avec des PdfDocument::TableLine
    # 
    # N'additionne que s'il y a une valeur
    # ce qui permet d'avoir des valeurs vides dans les colonnes
    # 
    # Retourne 0 s'il n'y a aucune ligne
    def totalize_column(i)
      total = BigDecimal.new(0, 2)
      lines.each_with_index do |l,j|
        if l.is_a? PdfDocument::TableLine
          total += l.subtotal? ? 0 : french_to_d(l.values[i])
        else
          total += french_to_d(prepared_lines[j][i])
        end
      end 
      total
    end


    # Transforme un string représentant un nombre en format français, par exemple
    # '1 300,25' en un float que le programme saura additionner.
    #
    # On prévoit le cas ou number serait malgré tout Numeric en retournant la valeur
    #
    # TODO faire une sous classe de Float qui sache additionner nativement le
    # format français.
    def french_to_d(number = 0)
      number.is_a?(Numeric) ? number : number.gsub(',', '.').gsub(' ', '').to_d rescue 0
    end

    
   

  end

end
