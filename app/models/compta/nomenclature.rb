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
    
    def_doc :resultat, :actif, :passif, :benevolat

    validates :actif, :passif, :resultat,:presence=>true
    validate :bilan_complete, :bilan_balanced, :resultats_67, :benevolat_8, :no_doublon?


    def initialize(period, yml_file)
      @period = period
      path = case Rails.env
      when 'test' then File.join Rails.root, 'spec', 'fixtures', 'nomenclatures', yml_file
      else
        File.join Rails.root, 'app', 'assets', 'parametres', 'association', yml_file
      end
      @instructions = YAML::load_file(path)
      #  def_document
    end



    # no_doublon vérifie que la nomenclature ne prend pas deux fois le même compte
    # dans le cadre d'une page seule
    def no_doublon?
      pages.each {|p| doc_no_doublon?(p) }
      collection_no_doublon?(:resultats, :exploitation, :financier, :exceptionnel)
      collection_with_option_no_doublon?(:bilan, :actif, :passif)
    end

    # vérifie qu'il n'y a pas de doublon dans les comptes pris dans les différentes documents
    # utilisé par no_doublon? pour faire l'ensemble de ses tests,
    # exemple [:exploitation, :financier, :exceptionnel]
    def collection_no_doublon?(name, *docs)
      numbers = []
      docs.each {|doc| numbers += numbers_from_document(doc) }
      dil = doublon_in_list(numbers)
      unless  dil.empty?
        Rails.logger.info "La partie #{name.capitalize} comprend des doublons : #{dil.join(', ')}"
        self.errors[name] << "comprend des doublons (#{dil.join(', ')})"
        return false
      end
      true
    end

    def collection_with_option_no_doublon?(name, *docs)
      numbers = collection_numbers_with_option(*docs)
      dup = []
      # puts numbers.inspect
      # on doit vérifier que les nil et les col2 n'ont aucun doublon
      list = numbers.select {|o| o[:option] == nil || o[:option] == :col2}.map {|n| n[:num]}
      dup += doublon_in_list(list)
      
      # on n'accepte pas non plus des doublons entre les nil col2 et les credit d'un côté, les débit de l'autre
      # les comptes de crédit ne peuvent être dans list
      n_credit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
      dup +=  (n_credit & list) # intersection avec list
      dup += doublon_in_list(n_credit)
      # les comptes de débit ne peuvent être dans list
      n_debit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
      dup += (n_debit & list) # intersection avec list
      dup += doublon_in_list(n_debit)
      self.errors[name] << "comprend des doublons (#{dup.uniq.join(', ')})" unless dup.empty?
     


    end

    def doc_no_doublon?(doc)
      dil = doublon_in_list(numbers_from_document(doc))
      unless dil.empty?
        Rails.logger.info "#{doc} comprend un compte en double (#{dil.join(', ')})"
        self.errors[doc] << "comprend un compte en double (#{dil.join(', ')})"
        return false
      end
      true
    end

    def bilan_complete?
      bilan_complete.empty? ? true : false
    end

    def sheet(doc)
      Compta::Sheet.new(@period, @instructions[doc], doc) if @instructions[doc]
    end

    # renvoie la liste des pages existant dans cette nomenclature
    def pages
      @instructions.map {|k, v| k}
    end


    # permet d'extraire toutes les instructions de liste de comptes de la nomenclature
    # la logique récursive permet de faire des nomenclatures à plusieurs niveaux
    # sans imposer un nombre de niveaux précis
    def accumulated_values(hash_rubriks)
      values = []
      hash_rubriks.each do |k,v|
        values << (v.is_a?(Hash) ? accumulated_values(v) : v)
      end
      values.flatten
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
        self.errors[:bilan] << "ne reprend pas tous les comptes. Manque #{not_selected.join(', ')}"
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
        
        self.errors[:bilan] << " : comptes D sans comptes C correspondant (#{d_no_c.join(', ')})" unless d_no_c.empty?
        self.errors[:bilan] << " : comptes C sans comptes D correspondant (#{c_no_d.join(', ')})" unless c_no_d.empty?
        
        return false
      end
    end

    # sert à contrôler que les différentes rubriques de resultats n'utilisent que des comptes 6 et 7
    def resultats_67
      retour = true
      [:exploitation, :financier, :exceptionnel].each do |partie|
        r = rough_accounts_reject(rough_accounts_list(partie), 6, 7)
        unless r.empty?
          self.errors[partie] << "comprend un compte étranger aux classes 6 et 7 (#{r.join(', ')})"
          retour = false
        end
      end
      retour
    end


    def benevolat_8
      unless  (r = rough_accounts_reject(rough_accounts_list(:benevolat), 8)).empty?
        self.errors[:benevolat] << "comprend un compte étranger à la classe 8 (#{r.join(', ')})"
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
      if @instructions[doc]
        accumulated_values(@instructions[doc][:rubriks]).join(' ').split
      else
        []
      end
    end




    # doc est un symbol comme :actif, :passif, :exploitation, :financier, :exceptionnel et :benevolat
    def numbers_from_document(doc)
      if @instructions[doc]
        accumulated_values(@instructions[doc][:rubriks]).map {|accounts| Compta::RubrikParser.new(@period, :actif, accounts).list_numbers}.flatten
      else
        []
      end
    end

    def numbers_with_options_from_document(doc)
      if @instructions[doc]
        accumulated_values(@instructions[doc][:rubriks]).map {|accounts| Compta::RubrikParser.new(@period, :actif, accounts).list}.flatten
      else
        []
      end
    end

    def collection_numbers_with_option(*docs)
      r = []
      docs.each {|doc| r+= numbers_with_options_from_document(doc)}
      r
    end

    # à partir d'une liste de numéros, retourne la liste des doublons
    def doublon_in_list(array_numbers)
      uniq_numbers = array_numbers.uniq
      if uniq_numbers.size != array_numbers.size
        # pour trouver les dupliqués, on fait un hash avec comme clé le numéro et comme nombre le count de fois ce numéro
        return array_numbers.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
      end
      []
    end

    
  end

end
