# coding: utf-8

module Compta





  # Permet de controler que la nomenclature et les comptes de l'exercice sont 
  # cohérents.
  # 
  # La nomenclature est fournie par le modèle Nomenclature (modèle persistant)
  # 
  # Compta::Nomenclature se crée avec une nomenclature et un exercice. 
  # 
  # Les méthodes de Compta::Nomenclature sont destinées à vérifier que tous les 
  # comptes sont utilisés pour le bilan et pour le compte de résultat, ainsi que
  # pour le bénévolat. 
  #
 
  class Nomenclature

    include ActiveModel::Validations

    attr_accessor :nomenclature

    
    delegate :resultat, :resultats, :actif, :passif, :benevolat, :organism, :to=>:nomenclature
    
    validate :bilan_complete, :resultat_complete, :bilan_no_doublon?, :resultat_no_doublon?
    validate :benevolat_no_doublon?, :if=>Proc.new {organism.status == 'Association'}
   
    def initialize(period, nomenclature)
      @period = period
      @nomenclature = nomenclature
    end

    

# TODO réactiver ces  test sur la cohérence des comptes car pour le bilan, 
# il n'est pas possible de tester totalement la nomenclature et les folios associés
# si on ne teste pas également avec les comptes réels.
# 
# On pourrait par exemple tromper l'analyse avec un 43 !431 mais pas mettre le 431
# problème qui est traité par bilan_complete
# ou encore un -456 et ailleur un 45, problème qui relève du no_doublon
# 
# 
      

   

      
      
      # vérifie que tous les comptes sont pris en compte pour l'établissement du bilan
      # à l'exception des comptes de classes 8 qui servent à valoriser le bénévolat
      #
      # bilan_complete retourne les comptes non utilisés dans le bilan.
      def bilan_complete
        list_accs = @period.two_period_account_numbers.reject {|acc| acc.to_s =~ /\A[8]\d*/} # on a la liste des comptes
        rubrik_accounts = actif.all_numbers(@period) + passif.all_numbers(@period)
        not_selected =  list_accs.select {|a| !a.in?(rubrik_accounts) }
        unless not_selected.empty?
          self.errors[:bilan] << "ne reprend pas tous les comptes pour #{@period.exercice}. Manque #{not_selected.join(', ')}"
        end
        not_selected
      end
      
      # Indique si le document bilan utilise tous les comptes de bilan
      # bilan_complete retournant les comptes inutilisés, la réponse
      # est donnée en testant si bilan_complete est vide.
      def bilan_complete?
        bilan_complete.empty? ? true : false 
      end
   


      # vérifie que tous les comptes 6 et 7 sont pris en compte pour l'établissement du compte de résultats 
      # renvoie la liste des comptes non repris
      def resultat_complete
        list_accs = @period.two_period_account_numbers.reject {|acc| acc.to_s =~ /\A[123458]\d*/}
        not_selected =  list_accs.select {|a| !a.in?(resultats_accounts) }
        self.errors[:resultat] << "Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque #{not_selected.join(', ')}" if not_selected.any?
        not_selected
      end
      
      # Indique si le document bilan utilise tous les comptes de bilan
      # bilan_complete retournant les comptes inutilisés, la réponse
      # est donnée en testant si bilan_complete est vide.
      def resultat_complete?
        resultat_complete.empty? ? true : false 
      end
      
      
      # méthode vérifiant qu'il n'y a aucun doublon dans les comptes actif et passif
      def bilan_no_doublon?
        collection_with_option_no_doublon?(:bilan, actif, passif)
      end
      
      # méthode vérifiant qu'il n'y a aucun doublon dans le (ou les) compte(s) de resultats
      # traite les comptes de résultats l'un après l'autre
      def resultat_no_doublon?
        collection_with_option_no_doublon?(:resultat, *resultats.all)
      end
      
      # méthode vérifiant qu'il n'y a aucun doublon dans le comptes de resultat
      def benevolat_no_doublon?
        collection_with_option_no_doublon?(:benevolat, benevolat)
      end
   
      
protected    

      def resultats_accounts
        @resultats_accounts ||= build_resultats_accounts
      end

      # renvoie la liste des comptes utilisés dans le ou les folios resultats
      def build_resultats_accounts
        rubrik_accounts = []
        resultats.each { |result| rubrik_accounts += result.all_numbers(@period)}
        rubrik_accounts
      end
      
      
      # renvoie une liste d'instructions avec les options sous forme de hash
      #  [{:num=>"201", :option=>nil}, {:num=>"2801", :option=>:col2}, 
      #  {:num=>"2803", :option=>:col2}, {:num=>"206", :option=>nil}, 
      #  {:num=>"2906", :option=>:col2}, {:num=>"208", :option=>nil}, ...
      def collection_numbers_with_option(*docs)
        docs.collect {|doc| doc.all_numbers_with_option(@period)}.flatten
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

      # Cherche les doublons en prenant en compte le fait que les comptes standard (ceux avec nil comme :option
      # ne sont pas déjà pris dans les comptes avec option[:col_2], ce qui pour mémoire, signifie qu'ils sont 
      # retenus en tant qu'amortissement ou provision (deuxième colonne pour les documents actifs)
      # 
      # On effectue le même traitement avec les comptes qui ont nil et les comptes qui ont crédit comme option
      # 
      # Puis enfin avec les comptes qui ont nil et les comptes qui ont débit.
      #
      # Le premier argument servira comme nom pour enregistrer l'erreur s'il y en a une
      # le deuxième argument est une liste de documents à regrouper pour tester l'existence
      # de ces doublons : par exemple pour un bilan : [:actif, :passif].
      #
      # Ainsi collection_with_option_no_doublon?(:bilan, :actif, :passif) recherche les doublons dans
      # les documentsw :actif et :passif et ajoute une erreur sur :bilan s'il y en a
      #
      def collection_with_option_no_doublon?(name, *docs)
        numbers = collection_numbers_with_option(*docs)
        dup = []
        # on doit vérifier que les nil et les col2 n'ont aucun doublon
        list = numbers.select {|o| o[:option] == nil || o[:option] == :col2}.map {|n| n[:num]}
        dup += doublon_in_list(list)
      
        # on n'accepte pas non plus des doublons entre les nil col2 et les credit d'un côté, les débit de l'autre
        # les comptes de crédit ne peuvent être dans list
        n_credit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
        dup +=  (n_credit & list) # intersection avec list
        dup += doublon_in_list(n_credit)
        # les comptes de débit ne peuvent être dans list
        n_debit = numbers.select {|n| n[:option] == :debit}.map {|n| n[:num]}
        dup += (n_debit & list) # intersection avec list
        dup += doublon_in_list(n_debit)
        self.errors[name] << "comprend des doublons (#{dup.uniq.join(', ')})" unless dup.empty?
        dup.empty?
      end

      

    
    end

  end
