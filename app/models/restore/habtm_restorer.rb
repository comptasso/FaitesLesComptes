# coding: utf-8


module Restore

  # La classe HabtmRestorer est dédiée à la restauration des informations d'une
  # table représentant une relation habtm.
  #
  # Dans compta, c'est par exemple BankExtractLines_Lines
  #
  # Pour la création, elle est appelée par compta_restorer
  # qui lui transmet la compta et les deux
  # modèles que l'on veut restaurer.
  #
  # Ensuite la méthode restore_records effectue la restauration
  # proprement dite.
  #
  class HabtmRestorer

    def initialize(sender, sym_model1, sym_model2)
       @sym_model1 = sym_model1
       @sym_model2 = sym_model2
       @compta = sender
    end

    # restore_records doit être appelé avec un array de hash reprenant
    # les infos de la table d'origine :
    #
    # Par exemple restore_records([ {:bank_extract_line => 1, :line => 1 }, ...])
    # restore_records appelle demande alors à @compta les nouvelles id
    # substutives et crée le record souhaité
    #
    def restore_records(array_of_infos)
      model1 = sym_model1.to_s.camelize.constantize
      model2 = sym_model1.to_s.camelize.constantize

      array_of_infos.each do |a|
        new_id1 = new_id2 = nil
        new_id1 = compta.ask_id_for(sym_model1.to_s, a[sym_model1])
        new_id2 = compta.ask_id_for(sym_model2.to_s, a[sym_model2])

        if (new_id1 && new_id2)
          bel = model1.find(new_id1)
          bel << model2.find(new_id2)
          bel.save!
          rails.logger "Reconstitution de #{sym_model1}_#{sym_model2} with #{new_id1} et #{new_id2}"
        end
      end
    end
  end
end
