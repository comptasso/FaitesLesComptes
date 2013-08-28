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
    
    attr_reader :organism, :member, :period
    
    
    # on est obligé d'avoir un after_create car on a besoin du record_id
    def after_create(record)
      set_variables(record)
      ib = organism.bridge.income_book
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
      w.save
    end
    
    # Si l'écriture n'est pas verrouillée, met à jour les champs. 
    # Retourne false ou true selon que la mise à jour a pû se faire.
    # 
    # Etant un before_callback, cela permet de faire un rollback si
    # la modification ne peut se faire (cas notamment d'une écriture verrouillée)
    # 
    # TODO : voir comment ajouter un message d'erreur qui pourrait être 
    # affiché par le controller d'Adherent::Payment
    # 
    def before_update(record)
      w = InOutWriting.find_by_bridge_id(record.id)
      return false if w.locked?
      retour =  true
      set_variables(record)
  
      # mise à jour des champs writings qui peuvent être influencés par un 
      # changement des informations du payment 
      new_values = { date:record.read_attribute(:date),
         ref:"adh #{member.number}",
         narration:"Payment adhérent #{member.to_s}"} 
      retour = retour && w.update_attributes(new_values)  # passe retour à false si update_attributes échoue
      cl = w.compta_lines.first
      retour = retour && cl.update_attributes(compta_line_attributes(record)) 
      sl = w.support_line
      retour = retour && sl.update_attributes(counter_line_attributes(record)) 
      retour
    end
    
    def before_destroy(record)
      w = InOutWriting.find_by_bridge_id(record.id)
      if w.locked?
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
    
  end
end
