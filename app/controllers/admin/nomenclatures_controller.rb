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
        flash[:alert] = @nomenclature.collect_errors unless @nomenclature.valid?
        render 'edit'
      end

    rescue NomenclatureLoadError => e
      flash[:alert] = e.message
      render 'edit'
    end

  end

 
end
