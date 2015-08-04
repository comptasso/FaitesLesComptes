module Utilities
  # Cloner a pour objet de prendre une comptabilité (actuellement un organisme)
  # et de faire la copie de cette comptabilité en conservant les références
  #
  class Cloner


    # Méthodes ayant pour effet de fournir des textes SQL pour création des
    # fonctions nécessaires à la copie des données.
    #
    # sql_copy_first traite les descendants directs de Organism tels
    # Sector, Period, Nomenclature, et Adherent::Member
    #
    # Les arguments sont le nom de la table (par exemple sectors), et
    # éventuellement une option pour préciser le modèle,
    # ce qui est nécessaire lorsqu'il n'est pas
    # possible de récupérer le nom du modèle par la table (cas des
    # Adherent::Members par exemple, on écrira alors en options
    # :modele=>Adherent::Member)
    def sql_copy_first_level(table, options={})
      sql_copy_n_refs('organism_id', [], table, modele)
    end



    # Réalise des copies des enregistrements
    # d'une table (argument table) faisant référence à un
    # champ (champ_id) d'une autre table. La différence avec la méthode
    # précédente est juste que organism_id n'est pas le champ_id par défaut.
    #
    # On doit préciser le modèle sous-jacent
    # à la table si le programme ne sait pas le déduire par l'option
    # {:modele=>NomDuModele}.
    #
    # Exemple d'utilisation : sql_copy_one_ref('cash_id', 'cash_controls')
    #
    # La méthode renvoie un texte sql qui peut alors être utilisé pour créer
    # dans la base la fonction de recopie par un appel de type
    # Organism.find_by_sql(la requête renvoyée).
    #
    def sql_copy_one_ref(champ_id, table, options={})
      sql_copy_n_refs(champ_id, [], table, options)
    end

    # Réalise des copies des enregistrements
    # d'une table (argument table) faisant référence à un champ principal
    # (champ_id) et une série de champs secondaires (sous le format champ_id)
    # qui devront être mis à jour simultanément.
    #
    # Ainsi, le premier champ est le champ de référence (par exemple
    # pour Account, c'est period_id),
    # le second champ est un array de champs qui doivent
    # être mis à jour (pour Account, c'est [sector_id])
    #
    # Pour des compta_lines, le champ principal est writing_id, tandis que le
    # tableau des autres champs sera [destination_id, account_id, nature_id,
    # check_deposit_id].
    #
    # Il est possible de fournir un array vide []
    #
    # Exemple d'utilisation :
    # sql_copy_n_refs('writing_id', ['nature_id', 'destination_id',
    # 'account_id', 'check_deposit_id], 'compta_lines')
    #
    # La méthode renvoie un texte sql qui peut alors être utilisé pour créer
    # dans la base la fonction de recopie.
    #
    # Les options sont un hash facultatif permettant de préciser
    #  - le modèle à traiter lorsqu'il ne peut être déduit du nom de la table
    #  C'est typiquement le cas pour la famille des tables adherent_members
    #  qui fait référence à Adherent::Member. Dans ce cas, on précise dans les
    #  options :modele=>Adherent::Member
    #  - le nom du champ lorsqu'il ne peut être déduit de champ_ids, le seul
    #  cas actuellement étant bridge_id qui fait référence à un
    #  Adherent::Member. Dans ce cas, on mettra dans les options
    #  :bridge_id=>Adherent::Member
    #
    #
    def sql_copy_n_refs(champ_id, champ_ids, table, options= {})

      # on définit ici les variables dont on aura besoin dans le texte sql
      nom_fonction = 'copy_' + table

      begin
        modele = options[:modele] || table.classify.constantize
      rescue NameError
        raise NameError, 'Impossible d\'identifier le modèle ;
vous devez le fournir en deuxième argument'
      end

      # le nom du modèle que l'on cherchera dans la table flc_cloner
      champ = champ_id[0..-4].capitalize
      # récupération de tous les champs dont on assure la recopie à l'identique
      # ne sont donc pas recopiés le champ id, et les arguments  champ_ids
      list_cols = modele.column_names
      list_cols = list_cols.reject { |c| c == 'id' || c == champ_id || c.in?(champ_ids)}
      list  = list_cols.join(', ')
      r_list = list_cols.map { |c| '(r).'+c}.join(', ')

      list_champ = champ_ids.join(', ')
      # construction des requêtes cherchant les valeurs dans la table
      # flc_cloner
      values = champ_ids.collect do |cid|
        mod = options[cid.to_sym].to_s
        value_to_insert(cid, mod)
      end.join(', ')


      sql = <<-EOF
   CREATE OR REPLACE FUNCTION #{nom_fonction}(from_id integer, to_id integer)
   RETURNS SETOF #{table} AS
$BODY$
DECLARE
  r #{table}%rowtype;
  new_id int;
BEGIN
  FOR r in SELECT * FROM #{table} WHERE #{champ_id} IN (
    SELECT old_id FROM flccloner WHERE name = '#{champ}' AND old_org_id = from_id
      AND new_org_id = to_id
)

  LOOP
    WITH  correspondance AS
    ( INSERT INTO #{table}
       (#{champ_id},
        #{ list_champ + ', ' unless list_champ.empty?}
        #{list})
      VALUES (#{value_to_insert(champ_id)},
      #{values + ', ' unless values.empty?}
      #{r_list})
     RETURNING id, (r).id  oldid)
      INSERT INTO flccloner (name, old_id, new_id, old_org_id, new_org_id)
      VALUES ('#{modele}', (r).id,
      (SELECT id FROM correspondance WHERE oldid = (r).id ), from_id, to_id);
    RETURN NEXT r;
  END LOOP;
  RETURN;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
      EOF

      sql
    end

    protected

    # Définit le morceau de requête qui permet de trouver dans la table
    # flccloner la valeur souhaitée pour mettre à jour les références.
    #
    # Le deuxième champ permet de préciser le nom du modèle lorsqu'il ne
    # peut être déduit de champ_id. C'est notamment le cas pour
    # la table des Writing dont le champ bridge_id fait référence à
    # Adherent::Member
    def value_to_insert(champ_id, champ = nil)
      raise ArgumentError, 'L\'argument doit être de la forme wwww_id' unless
      champ_id =~ /.*_id$/
      champ ||= champ_id[0..-4].capitalize
      "(SELECT flccloner.new_id FROM flccloner WHERE name = '#{champ}'
           AND flccloner.old_id = (r).#{champ_id}
           AND old_org_id = from_id AND new_org_id = to_id)"
    end

  end

end
