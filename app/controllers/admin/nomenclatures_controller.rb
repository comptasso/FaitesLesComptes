# -*- encoding : utf-8 -*-

class Admin::NomenclaturesController <  Admin::ApplicationController

  class NomenclatureLoadError < StandardError; end


  def edit
    @nomenclature = @organism.nomenclature
  end

  def update
    @nomenclature = @organism.nomenclature
 
    begin

      # vérification que l'extension est bien la bonne
      extension = File.extname(params[:file_upload].original_filename)
      if  ".yml" != extension
        raise NomenclatureLoadError, "Le format des nomenclatures doit être un fichier YAML (extension yml et non #{extension}"
      end

      @nomenclature.load_io(params[:file_upload].read)
      if @nomenclature.save
        flash[:notice] = "La nomenclature chargée est maintenant celle qui sera appliquée pour les prochaines éditions de documents"
        redirect_to admin_organism_url(@organism)
      else
        collect_errors
        render 'edit'
      end

    rescue NomenclatureLoadError => e
      flash[:alert] = e.message
      render 'edit'
    end

  end

  protected

  # appelé par before_filter pour s'assurer que la nomenclature est valide
  def collect_errors

    unless @nomenclature.valid?
      al = 'La nomenclature utilisée comprend des incohérences avec le plan de comptes. Les documents produits risquent d\'être faux.</br> '
      al += 'Liste des erreurs relevées : <ul>'
      @nomenclature.errors.full_messages.each do |m|
        al += "<li>#{m}</li>"
      end
      al += '</ul>'
      flash[:alert] = al.html_safe
    end
  end
end
