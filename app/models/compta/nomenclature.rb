# coding: utf-8

module Compta
  class Nomenclature

    include ActiveModel::Validations 


    validates :resultat, :presence=>true

    def initialize(yml_file)
      path = case Rails.env
      when 'test' then File.join Rails.root, 'spec', 'fixtures', 'nomenclatures', yml_file
      else
        File.join Rails.root, 'app', 'assets', 'parametres', 'asso', yml_file 
      end
      @documents = YAML::load_file(path)

    end

    def document(page)
      @documents[page]
    end

    def resultat
      @documents[:resultat]
    end




    
  end
end
