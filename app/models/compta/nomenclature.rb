# coding: utf-8

module Compta
  class Nomenclature

    include ActiveModel::Validations

    attr_accessor :instructions

    # permet de définir l'ensemble des méthodes d'accès aux pages (:actif, :passif, ...
    # voir juste dessous l'utilisation
    def self.def_doc(*args)
      args.each do |a|
        define_method a do
          instructions[a]
      end
    end
    end
    
    def_doc :exploitation, :actif, :passif, :financier, :exceptionnel, :benevolat

    validates :exploitation, :actif, :passif, :financier, :exceptionnel,:presence=>true
    validate :bilan_complete, :bilan_balanced, :resultats_67, :benevolat_8


    def initialize(period, yml_file)
      @period = period
      path = case Rails.env
      when 'test' then File.join Rails.root, 'spec', 'fixtures', 'nomenclatures', yml_file
      else
        File.join Rails.root, 'app', 'assets', 'parametres', 'asso', yml_file 
      end
      @instructions = YAML::load_file(path)
    #  def_document
    end




    def bilan_complete?
      bilan_complete.empty? ? true : false
    end

    def sheet(doc)
      Compta::Sheet.new(@period, @instructions[doc])
    end


    protected

    # vérifie que tous les comptes sont pris en compte pour l'établissement du bilan
    # à l'exception des comptes de classes 8 qui servent à valoriser le bénévolat
    def bilan_complete
      list_accs = @period.two_period_account_numbers # on a la liste des comptes
      rubrik_accs = []
      rubrik_accs += numbers_from_document(:actif) + numbers_from_document(:passif)
      not_selected =  list_accs.select {|a| !a.in?(rubrik_accs) && !(a=~/^8\d*$/) }
      unless not_selected.empty?
        self.errors[:bilan] << "Tous les comptes ne sons pas repris pour l\'édition du bilan. Comptes non trouvés : #{not_selected.join(', ')}"
      end
      return not_selected
    end


    # sert à vérifier que si on compte C est pris, on trouve également un compte D
    # et vice_versa.
    # Ajoute une erreur à :bilan si c'est le cas avec comme message la liste des comptes
    # qui n'ont pas de correspondant
    def bilan_balanced
      
      array_numbers = rough_accounts_list(:actif) + rough_accounts_list(:passif)
      
      # maintenant on crée une liste des comptes D et une liste des comptes C
      numbers_d = array_numbers.map {|n| $1 if n =~ /^(\d*)D$/}.compact.sort
      numbers_c = array_numbers.map {|n| $1 if n =~ /^(\d*)C$/}.compact.sort
    
      if numbers_d == numbers_c
        return true
      else
        d_no_c = numbers_d.reject {|n| n.in? numbers_c}
        c_no_d = numbers_c.reject {|n| n.in? numbers_d}
        
        self.errors[:bilan] << "Comptes D sans comptes C correspondant: #{d_no_c.join(', ')}" unless d_no_c.empty?
        self.errors[:bilan] << "Comptes C sans comptes D correspondant: #{c_no_d.join(', ')}" unless c_no_d.empty?
        
        return false
      end
    end

    # sert à contrôler que les différentes rubriques de resultats n'utilisent que des comptes 6 et 7
    def resultats_67
      retour = true
      [:exploitation, :financier, :exceptionnel].each do |partie|
        r = rough_accounts_reject(rough_accounts_list(partie), 6, 7)
        unless r.empty?
          self.errors[partie] << "La partie #{partie.capitalize} comprend un compte étranger aux classes 6 et 7 : #{r.join(', ')}"
          retour = false
        end
      end
      retour
    end


    def benevolat_8
      unless  (r = rough_accounts_reject(rough_accounts_list(:benevolat), 8)).empty?
        self.errors[:benevolat] << "La partie #{:benevolat.capitalize} comprend un compte étranger à la classe 8 : #{r.join(', ')}"
        return false
      end
      true
    end


    

    # vérifie que les numéros de comptes ne comprennent que les comptes qui commencent pas *args
    # par exemple include_only(%w(701, 603, 407), 6, 7)
    def include_only(list_numbers, *args)
      args.each do |a|
        list_numbers.select! {|n| n !~ /^#{a}\d*/}
      end
      list_numbers
    end

    # A partir d'un array numbers ne garde que les nombres commencent par
    # les chiffres donnés par args.
    # Utilisé par resultat_67 et benevolat_8
    # Exemple : rough_include_select
    def rough_accounts_reject(array_numbers, *args)
      args.each do |a|
        array_numbers.select! {|n| n !~ /^[-!]?#{a}\d*/}
      end
      array_numbers
    end

    # rencoie la liste brute des informations de comptes repris dans la partie doc
    # rough_accounts_list(:benevolat) renvoie par exemple %w(87 !870 870 86 !864 864)
    def rough_accounts_list(doc)
      list = ''
      @instructions[doc][:rubriks].each {|k,v| v.each { |t, accs| list += ' ' + accs } } if @instructions[doc]
      list.split
    end

    # doc est un symbol comme :actif, :passif, :exploitation, :financier, :exceptionnel et :benevolat
    def numbers_from_document(doc)
      numbers = []
      if @instructions[doc]
        @instructions[doc][:rubriks].each {|k,v| v.each { |t, accs| numbers += Compta::RubrikParser.new(@period, :actif, accs).list_numbers } }
      end
      numbers
    end

    def self.def_doc(*args)
      args.each do |a|
        instructions[a]
      end
    end



    
    # Définit automatiquement l'ensemble des méthodes correspondant à chacun des documents
    # figurant dans le fichier yml, par exemple def actif; @instructions[:actif]; end
#    def def_document
#      @instructions.each do |k,v|
#      self.class.send(:define_method, k) do
#           v
#         end
#      end
#    end

  end

end
