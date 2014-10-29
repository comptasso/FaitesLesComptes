#coding: utf-8

module Pdflc
  
  # Cette classe sait dessiner une page d'un document pdf pour l'édition 
  # d'un listing de compte. 
  # 
  # Elle s'appuie sur Table pour les lignes de la table.
  # Table fournit aussi les totaux. 
  # 
  # FlcPage est alors capable de fournir les reports qui seront utilisés pour 
  # la page suivante.
  # 
  # Un array de largeurs permet de calculer la largeur des différentes lignes.
  # Les largeurs sont exprimées en % de la largeur (le total devant faire 100).
  # 
  # Un array de titres fournit les titres
  # Enfin un array d'alignements fournit les alignements
  # 
  # La seule option actuellement prévue est :fond pour pouvoir définir un 
  # fond tel que 'Provisoire' ou 'Brouillard'
  #
  class FlcPage < Prawn::Document
    
    FLC_TITLE_STYLE = {:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }
    FLC_LINE_STYLE = {:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate}
    FLC_REPORT_LINE_STYLE = {:font_style=>:bold, :align=>:right }
    
    attr_reader :titles, :widths, :alignments, :trame, :flctable 
    attr_accessor :reports
    
    def initialize(titles, widths, alignments, reports, table, trame, options={})
      @titles = titles
      @widths = widths
      @alignments = alignments
      # TODO on peut s'en passer en faisant calculer les reports  
      # au bon moment par Book
      @reports = reports # reports initiaux
      @flctable = table # la logique veut que la table soit initialisée
      # à la page 1
      @trame = trame
      
      # TODO rajouter quelques validations 
      #  par exemplela somme des widths doit faire 100,
      super(page_layout: :landscape, page_size:'A4')
      if options[:fond]
        set_stamp_fond(options[:fond])
        @fond = true
      end
      trame.trame_stamp(self) # création du stamp 'trame' à partir de la trame
      set_total_columns_widths # calcule les dimensions pour les colonnes totals
    end
    
    # to_reports additionne les reports et les totaux de la table
    def to_reports
      tls = @flctable.totals
      torpts = @reports.collect.with_index do |r, i|
        r + tls[i]
      end
      torpts
    end
    
    # 
    def draw_pdf(pagination = true)
      
      nb_p = flctable.nb_pages
      nb_p.times do |i|
        last_page =  (i+1) == nb_p ? true : false
        first_page = (i == 0) ? true : false
        draw_heart(first_page, last_page)        
        draw_stamps 
        next_page unless last_page
      end
      numerote if pagination # sinon on laisse ce soin au pdf_doc qui
      # a initié la demande.
    end
    
    # juste imprimer le coeur des informatiosn
    def draw_heart(first_page, last_page)
      draw_page_titles
      bounding_box [0, height-50], width:width, height:height-40 do
        font_size(10) do 
          draw_table_title # on écrit les titres de la table
          draw_report_line(first_page) # on écrit les reports 
          draw_table_lines # on écrit le contenu de la table
          draw_total_lines(last_page) # le total de la table plus la ligne A reporter
        end
      end
    end
    
    def draw_stamps
      stamp('trame') # on applique le stamp trame sur la page
      stamp('fond') if @fond
    end
    
    def numerote
      number_pages("page <page>/<total>",
        { :at => [width - 150, 0],:width => 150,
          :align => :right, :start_count_at => 1 })
    end
    
   
    
    
    protected 
    
    def next_page
      @reports = to_reports
      @flctable.next_page
      start_new_page
    end
    
    def draw_page_titles
      bounding_box [150, height], :width => width-300, :height => 40 do
        font_size(20) { text trame.title.capitalize, :align=>:center }
        text trame.subtitle,
          :align=>:center if trame.subtitle
      end
    end
    
    def draw_table_title
      table [titles], column_widths:col_widths, :cell_style=>FLC_TITLE_STYLE  
    end
    
    def draw_report_line(first_page = false)
      int = [first_page ? "Valeurs début de période" : 'A reporter']
      table [int + format_num_values(reports)], column_widths:@total_columns_widths,
        :cell_style=>FLC_REPORT_LINE_STYLE 
    end
    
    def draw_total_lines(last_page = false)
      tl = ['Totaux'] + format_num_values(@flctable.totals)
      lib = last_page ? 'Valeurs fin de période' : 'A reporter'
      trs = [lib] + format_num_values(to_reports)
      
      table [tl, trs], 
        column_widths: @total_columns_widths,  :cell_style=>FLC_REPORT_LINE_STYLE 
    end
    
    def draw_table_lines
      pls = @flctable.prepared_lines
      
      # la table des lignes proprement dites
      table @flctable.prepared_lines,  :row_colors => ["FFFFFF", "DDDDDD"], 
        :header=> false , 
        :column_widths=>col_widths,
        :cell_style=>FLC_LINE_STYLE  do |table|
        alignments.each_with_index do |alignement,i|
          table.column(i).style {|c| c.align = alignement} 
        end
      end unless pls.empty?
    end
    
    def col_widths
      @col_widths ||= widths.collect { |w| width*w/100 }
    end
    
    
    # la largeur de la page
    def width
      bounds.right
    end
    
    def height
      bounds.top
    end
    
    def set_total_columns_widths
      raise 'Impossible de calculer les largeurs des lignes de total 
car les largeurs de la table ne sont pas fixées' unless widths
      tot_widths = []
      # si la colonne est à totaliser on retourne la valeur
      # sinon on la garde et on examine la colonne suivant
      l = 0 # variable pour accumuler les largeurs des colonnes qui ne sont 
      # pas à totaliser
      Rails.logger.debug "DEBUG : Largeur des colonnes #{widths.inspect}"
      widths.each_with_index do |w,i|
        if @flctable.columns_to_totalize.include? i
          if l != 0
            tot_widths << l
            l = 0
          end
          tot_widths << w
        else
          l += w
        end
       
      end
      # au cas où il y ait des colonnes sans total en fin de tableau
      # on en rajoute une pour arriver à 100
      s = tot_widths.sum
      tot_widths << (100 -s) if s < 100
      # et on calcule maintenant par rapport à la largeur de la page du pdf
      @total_columns_widths = tot_widths.collect { |w| width*w/100 }
    end
    
    def format_num_values(array_values)
      array_values.collect do |v|
        ActionController::Base.helpers.
          number_with_precision(v, precision:2)
      end
    end
    
    
    
    # Définit une méthode tampon pour le PrawnSheet qui peut ensuite être appelée 
    # par fill_actif_pdf et fill_passif_pdf 
    #
    def set_stamp_fond(text)
      if stamp_dictionary_registry['fond'].nil?
        create_stamp("fond") do
          rotate(stamp_rotation) do
            stroke_color "888888"
            font_size(120) do
              text_rendering_mode(:stroke) do
                draw_text(text, :at=>stamp_position)
              end
            end
            stroke_color '000000'
          end
          
        end
      end
    end
    
    def stamp_rotation
      page.layout == :landscape ? 30 : 65
    end
    
    def stamp_position
      page.layout == :landscape ? [200, -20] : [250, -150]
    end
    
  end
end