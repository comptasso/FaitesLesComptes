# coding: utf-8

# Cet observateur permet l'intégration avec le gem Adherent et plus précisément
# son modèle de payment.
#
# Enregistrer un payment entraîne la création d'une écriture comptable
#
# Les informations nécessaires à cet enregistrement (livre, compte recevant
# la cotisation, compte bancaire, caisse) sont obtenues à partir du modèle
# Bridge dont le but est de faire le pont avec le module Adhérent.
#
# Le libellé de l'écriture est produit par le commentaire entré lors de la
# saisie du paiement (payement.comment) où, s'il est vide, par un libellé
# automatique.
#
module Adherent
  class PaymentObserver < ::ActiveRecord::Observer

    attr_reader :organism, :member, :period


    # on est obligé d'avoir un after_create car on a besoin du record_id
    def after_create(record)
      set_variables(record)
      ib = organism.bridge.income_book
      w = ib.adherent_writings.new(
         date:record.read_attribute(:date),
         ref:"adh #{member.number}".truncate(NAME_LENGTH_MAX),
         narration:libelle(record),
         bridge_id:record.id,
         bridge_type:'Adherent',
         compta_lines_attributes:{'1'=>compta_line_attributes(record),
           '2'=>counter_line_attributes(record)}
      )
      if w.valid?
        w.save
      else
        Rails.logger.warn "Ecriture générée par un payment de module Adhérent avec des erreurs : #{w.errors.messages}"
        copy_writing_errors(w, record)
      end
    end

    # Si l'écriture n'est pas verrouillée, met à jour les champs.
    # Retourne false ou true selon que la mise à jour a pû se faire.
    #
    # Etant un before_callback, cela permet de faire un rollback si
    # la modification ne peut se faire (cas notamment d'une écriture verrouillée)
    #
    #
    def before_update(record)
      w = Adherent::Writing.find_by_bridge_id(record.id)
      return true unless w # il n'y a pas d'écriture associée à ce payment
      unless w.editable?
        record.errors.add(:base, :writing_uneditable)
        return false
      end
      cl = w.compta_lines.where('nature_id IS NOT NULL').first
      # puts "COMPTA_LINE : #{cl.inspect}"
      sl = w.support_line
      # puts " SUPPORT LINE : #{sl.inspect}"

      retour =  true
      set_variables(record)

      # mise à jour des champs writings qui peuvent être influencés par un
      # changement des informations du payment
      new_values = { date:record.read_attribute(:date),
         ref:"adh #{member.number}".truncate(NAME_LENGTH_MAX),
         narration:libelle(record)}
      retour = retour && w.update_attributes(new_values)  # passe retour à false si update_attributes échoue
      # puts w.inspect
      Rails.logger.debug w.errors.messages unless retour
      retour = retour && cl.update_attributes(compta_line_attributes(record))
      Rails.logger.debug cl.errors.messages unless retour
      retour = retour && sl.update_attributes(counter_line_attributes(record))
      Rails.logger.debug sl.errors.messages unless retour
      copy_writing_errors(w, record) unless retour
      retour
    end

    def before_destroy(record)
      w = Adherent::Writing.find_by_bridge_id(record.id)
      return true unless w # il n'y a pas d'écriture associée à ce payment
      unless w.editable?
        record.errors.add(:base, :writing_uneditable)
        false
      else
        w.destroy
      end
    end

    protected

    # Définit les 3 variables d'instance, member, organism et period;
    # Ce dernier dépendant évidemment de la date.
    def set_variables(record)
      @member = record.member
      @organism = member.organism
      @period = organism.find_period(record.read_attribute(:date))
    end

    # construit la narration qui sera utilisée pour l'écriture, soit
    # en reprenant le commentaire de payment, soit en créant un libellé
    # automatique
    #
    #  On utilise read_attribute car libelle est également utilisé dans
    #  un before update
    #  TODO voir si on pourrait utiliser un nested_attribute pour simplifier
    #  cette logicue (payment nested_attributes writing)
    #
    def libelle(record)
      c = record.read_attribute(:comment)
      if c && !c.empty?
        return c
      else
        return "Paiement adhérent #{member.to_s}".truncate(LONG_NAME_LENGTH_MAX)
      end
    end


    # Définit les attributs pour remplir (ou modifier) les éléments de la compta line
    def compta_line_attributes(record)
      {nature_id:bridge_values[:nature_id], destination_id:destination.id, credit:record.amount, debit:0}
    end

    # Définit les attributs pour remplir (ou modifier) les attributs de la counter_line (aussi
    # appelée support_line).
    def counter_line_attributes(record)
      # selon le mode de paiment, il faut trouver le compte comptable à mouvementer
      # si c'est en Espèces, c'est la caisse, si c'est un chèque, c'est le
      # compte de remise de chèque, autrement, c'est la banque
      account_id =  case record.mode

      when 'Espèces' then bridge_values[:cash_account_id]
      when 'Chèque' then period.rem_check_account.id
      else
        bridge_values[:bank_account_account_id]
      end

      {account_id:account_id, payment_mode:record.mode, debit:record.amount, credit:0}
    end

    protected

    # instancie les valeurs à partir du modèle bridge qui fait le lien
    # entre la compta et le gem Adherent
    def bridge_values
       organism.bridge.payment_values(period)
    end

    def income_book
      organism.bridge.income_book
    end

    def destination
      organism.bridge.destination
    end

    # recopie les erreurs éventuelle de writing dans les erreurs[:base] du payment
    def copy_writing_errors(writing, record)
      writing.errors.each {|e| record.errors.add(:base, e)}
    end

  end
end
