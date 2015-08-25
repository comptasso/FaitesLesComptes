# NomenclatureChecker vérifie que la nomenclature permet d'afficher
# correctement compte de résultats et de bilans pour les exercices d'un
# organisme.
#
#

class Utilities::NomenclatureChecker

  attr_reader :nomen

  delegate :actif, :passif, :resultat, :benevolat, to: :nomen

  def initialize(nomen)
    @nomen = nomen
  end

  def valid?
    check_folios_present
    folios_coherent?
    bilan_balanced?
    bilan_no_doublon?
    periods_coherent? # periods au pluriel
    sectors_result_compliant?
    !nomen.errors.present?
  end

  # indique si les folios nécessaires sont présents
  def complete?
    res = actif && passif && resultat
    res = (res && benevolat) if (nomen.organism.status == 'Association')
    res
  end

  # Contrôle de la cohérence de la nomenclature avec les comptes d'un exercice
  # Cette action est en fait déléguée à Compta::Nomenclature
  # Les exercices qui sont cohérents ont un champ nomenclature_ok pour rendre
  # ce contrôle persistant
  def period_coherent?(exercice)
    cn = Compta::Nomenclature.new(exercice, nomen)
    validity = cn.valid?
    exercice.update_attribute(:nomenclature_ok, validity)
    cn.errors.each { |k, err| nomen.errors.add(k, err) } unless validity
    validity
  end

  # fournir une méthode de classe pour simplifier l'appel à cette logique
  # dans le modèle Period.
  def self.period_coherent?(exercice)
    new(exercice.organism.nomenclature).period_coherent?(exercice)
  end

  protected

  # vérifie la présence des folios et ajoute une erreur à nomen si
  # nécessaire
  def check_folios_present
    nomen.errors.add(:actif, 'Actif est un folio obligatoire') unless actif
    nomen.errors.add(:passif, 'Passif est un folio obligatoire') unless passif
    nomen.errors.add(:resultat, 'Resultat est un folio obligatoire') unless resultat
    if nomen.organism.status == 'Association' && !benevolat
      nomen.errors.add(:benevolat, 'Benevolat est obligatoire pour une association')
    end
  end

  # sert à vérifier que si on compte C est pris, on trouve également un compte D
  # et vice_versa.
  # Ajoute une erreur à :bilan si c'est le cas avec comme message la liste des comptes
  # qui n'ont pas de correspondant
  def bilan_balanced?
    return false unless complete?
    array_numbers = actif.rough_instructions + passif.rough_instructions

    # maintenant on crée une liste des comptes D et une liste des comptes C
    numbers_d = array_numbers.map {|n| $1 if n =~ /^(\d*)D$/}.compact.sort
    numbers_c = array_numbers.map {|n| $1 if n =~ /^(\d*)C$/}.compact.sort

    if numbers_d == numbers_c
      return true
    else
      d_no_c = numbers_d.reject {|n| n.in? numbers_c}
      c_no_d = numbers_c.reject {|n| n.in? numbers_d}

      nomen.errors[:bilan] << " : comptes D sans comptes C correspondant (#{d_no_c.join(', ')})" unless d_no_c.empty?
      nomen.errors[:bilan] << " : comptes C sans comptes D correspondant (#{c_no_d.join(', ')})" unless c_no_d.empty?

      return false
    end
  end

  def bilan_no_doublon?
    return false unless complete?
    array_numbers = actif.rough_instructions + passif.rough_instructions
    nomen.errors.add(:bilan, 'Une instruction apparait deux fois dans la construction du bilan') unless array_numbers.uniq.size == array_numbers.size
  end

  # reprise des validations propres aux folios
  # ce qui comprend le fait qu'un folio resultat ne doit avoir que des comptes 6 et 7
  # et qu'un folio benevolat ne peut avoir que des comptes 8
  def folios_coherent?
    nomen.folios.each do |f|
      nomen.errors.add(:folio, "Le folio #{f.name} indique une incohérence : #{f.errors.full_messages}") unless f.coherent?
    end
  end

  # Au pluriel, vérifie la cohérence pour chacun des exercices
  def periods_coherent?
    nomen.organism.periods.each {|p| period_coherent?(p)}
  end

  # Une nomenclature ne peut calculer correctement le résultat que si les
  # comptes de résultats autre que le 12 sont correctement sectorisés.
  def sectors_result_compliant?
    nomen.organism.periods.each {|p| sector_result_compliant?(p)}
  end

  # au singulier, vérifie que l'exercice ne comporte pas de compte 12XX non
  # sectorisé
  def sector_result_compliant?(exercice)
    if exercice.report_accounts.reject {|a| a.sector_id != nil}.count != 1
      nomen.errors.add(:resultat, 'Plus d\'un compte de resultat global')
    end
  end

end
