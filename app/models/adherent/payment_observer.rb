# coding: utf-8

# Cet observateur permet l'intégration avec le gem Adherent et plus précisément
# son modèle de payment. 
# 
# Enregistrer un payment entraîne la création d'une écriture comptable
# 
# TODO : voir comment traiter les natures et destinations qui servent pour
# l'enregistrement des payements des membres. Même problème pour les 
# banques ou la caisse et le livre des recettes.
#
module Adherent
  class PaymentObserver < ::ActiveRecord::Observer
    
    attr_reader :organism, :member, :period, :bridge_values
    
    def after_create(record)
      @member = record.member
      @organism = member.organism
      set_period(record)
      set_bridge_values
      # trouver le livre de recette (par défaut on prend le premier)
      ib = organism.income_books.first
      w = ib.in_out_writings.new(
         date:record.read_attribute(:date),
         ref:"adh #{member.number}",
         narration:"Payment adhérent #{member.to_s}",
         bridge_id:record.id,
         bridge_type:'Adherent',
         compta_lines_attributes:{'1'=>compta_line_attributes(record),
           '2'=>counter_line_attributes(record)}
      )
      Rails.logger.warn "Ecriture générée par un payment de module Adhérent avec des erreurs : #{w.errors.messages}" unless w.valid?
      w.save!
    end
    
    # Si l'écriture n'est pas verrouillée, met à jour les champs. 
    #
    # 
    def before_update(record)
      w = InOutWriting.find_by_bridge_id(record.id)
      return false if w.locked?
      retour =  true
      @member = record.member
      @organism = member.organism
      set_period(record)
      set_bridge_values
      # mise à jour des champs writings qui peuvent être influencés par un 
      # changement des informations du payment 
      new_values = { date:record.read_attribute(:date),
         ref:"adh #{member.number}",
         narration:"Payment adhérent #{member.to_s}"}
      retour = retour && w.update_attributes(new_values)  # passe retour à false si update_attributes échoue
      cl = w.compta_lines.first
      retour = retour && cl.update_attributes(compta_line_attributes(record)) 
      sl = w.support_line
      puts "Inspection de la support line #{sl.inspect}"
      retour = retour && sl.update_attributes(counter_line_attributes(record)) 
      retour
    end
    
    protected
    
    def set_period(record)
      @period = organism.find_period(record.read_attribute(:date))
    end
      
    def compta_line_attributes(record)
      puts bridge_values
      {nature_id:bridge_values[:nature_id], destination_id:bridge_values[:destination_id], credit:record.amount, debit:0}
    end
    
    def counter_line_attributes(record) 
      # selon le mode de paiment, il faut trouver le compte comptable à mouvementer
      # si c'est en Espèces, c'est la caisse, si c'est autrement, c'est la banque
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
    def set_bridge_values 
       @bridge_values ||=  organism.bridge.payment_values(period)
    end
  end
end
