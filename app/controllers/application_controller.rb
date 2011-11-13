class ApplicationController < ActionController::Base
  protect_from_forgery

   def find_organism
    @organism=Organism.find(params[:organism_id]) if params[:organism_id]
  end
end
