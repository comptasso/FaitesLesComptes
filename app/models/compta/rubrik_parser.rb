# coding: utf-8

module Compta
  #
  # Cette classe prend en argument un exercice et un tableau de chaine de caractères
  # Il retourne une collection de RubrikLine.
  # Le parsing prend par défaut l'argument % en fin de numéro
  # - indique que l'on cherche un amortissement ou une dépréciation.
  # 
  # ! indique que le compte doit être retiré de la liste
  # D indique que l'on prend ce compte que s'il est débiteur
  # C indique que l'on prend ce compte que s'il est créditeur
  #
  # Le but est par exemple d'avoir une série de lignes
  # avec avec le numéro de compte principal, l'intitulé principal
  # le montant brut, l'amortissement
  #
  # Ainsi 20 renvoie l'ensemble des comptes 20
  # 20, 201 doit renvoyer l'ensemble des comptes 20 mais pas compter le 201 deux fois
  # 20, !208, doit prendre tous les comptes 20 mais pas le 208
  # 20, -280, doit prendre tous les comptes 20 et tous les comptes 280 mais avec colon_1 mis à false
  # 20, 201D, doit prendre le compte 201 que s'il est débiteur
  #
  #
  class RubrikParser

    class ListError < StandardError; end

   
    # le RubrikParser s'initialise avec un exercice et une chaine de caractères
    #  représentant une liste de numéros par exemple '20 -280'
    # première étape, il identifie les numéros de comptes dont il aura besoin
    # deuxième étape, il crée les RubrikLine correspondantes
    # il fait ça pour les deux exercices (celui demandé et précédent s'il existe)
    
    def initialize(period, sens, args)
      @period = period
      # TODO Les rejets doivent être à la fin
      @numeros = args.split
      @sens = sens
      @select_nums = []
      @col2_nums = []
      @debit_nums = []
      @credit_nums = []
      # ceci nous donne tous les comptes des deux périodes
      @numbers = @period.two_period_account_numbers
      set_numbers # déclanche le parsing
      set_lines # trie et réordonne les numéros trouvés
      # à la fin de initialize, on a une variable d'instance @list
      # qui contient un tableau de hash ordonné
      # il suffit d'appeler rubrik_lines pour avoir les lignes de rubriques
    end
    
    # construit et renvoie la série des rubrik_lines
    def rubrik_lines
      @list.map {|l| Compta::RubrikLine.new(@period, @sens, l[:num], l[:option])}
    end
    
    # renvoie la liste des numéros de compte qui ont été retenus
    # cela est utilisé dans nomenclature pour vérifier que tous les comptes sont repris
    def list_numbers
      @list.map {|l| l[:num]}
    end



    protected

    def set_numbers
      @numeros.each {|num| parse_num(num)}
    end


    # rubrik_lines renvoie la collection de lignes
    # la méthode commence par former des hash pour chacune des variabls d'instances
    # select_nums, col2_nums, debit_nums et credit_nums
    # les réordonne,
    # puis génère la rubrik_line correspondante
    def set_lines
      @list = []
      @list += @select_nums.map { |n| {:num=>n, :option=>nil} }
      @list += @col2_nums.map {|n| {:num=>n, :option=>:col2}}
      @list += @credit_nums.map {|n| {:num=>n, :option=>:credit}}
      @list += @debit_nums.map {|n| {:num=>n, :option=>:debit}}
      # il faut maintenant les comptacter ou rejeter dans débit
      check_list
      reorder_list!
      @list
    end


    # check_list vérifie qu'aucun compte n'est inclut deux fois
    def check_list
      list_num = @list.map {|l| l[:num]}
      raise ListError, 'un numéro apparait en double' if list_num != list_num.uniq
    end

    def reorder_list!
      @list.sort!{|a,b| a[:num] <=> b[:num]}
    end

    

    def parse_num(num)
      case  num
      when  /^\d*$/ then add_numbers(num)
      when  /^-(\d*)$/ then add_col2_numbers($1)
      when /^!(\d*)$/ then reject_numbers($1)
      when /^(\d*)C$/ then add_credit_numbers($1)
      when /^(\d*)D$/ then add_debit_numbers($1)
      else
        raise ArgumentError, "argument mal formé : #{num}. Il n'est possible que d'avoir des chiffres éventuellement \n
        précédés du signe - ou de ! ou suivi de C ou de D"
      end


    end

    # On ajoute les comptes correspondant à la liste des comptes sélectionnés
    # en veillant à ne pas les ajouter deux fois
    def add_numbers(num)
      @select_nums += @numbers.select {|n| n =~ /^#{num}\d*/ && !n.in?(@select_nums) }
    end

    # on rejeète le numéro de la liste générale
    # et on l'ajoute dans celle de col2
    def add_col2_numbers(num)
      @select_nums.reject! {|n| n =~ /^#{num}\d*/}
      @col2_nums += @numbers.select {|n| n =~ /^#{num}\d*/}
    end

    def reject_numbers(num)
      Rails.logger.info "le numéro rejeté est #{num}"
      @select_nums.reject! {|n| n =~ /^#{num}\d*/}
    end

    # ajoute les numéros à la liste des numéros à logique de crédit
    # mais avant les retire de la liste générale au cas où ils y seraient
    def add_credit_numbers(num)
      @select_nums.reject! {|n| n =~ /^#{num}\d*/}
      @credit_nums += @numbers.select {|n| n =~ /^#{num}\d*/}
    end

    # ajoute les numéros à la liste des numéros à logique de crédit
    # mais avant les retire de la liste générale au cas où ils y seraient
    def add_debit_numbers(num)
      @select_nums.reject! {|n| n =~ /^#{num}\d*/}
      @debit_nums += @numbers.select {|n| n =~ /^#{num}\d*/}
    end
  end
end