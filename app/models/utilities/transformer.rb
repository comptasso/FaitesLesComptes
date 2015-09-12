
module Utilities
  # Transformer a pour objet de passer de la version avec schéma vers celle
  # sans schéma.
  #
  # Cete transformation se fait en trois étapes :
  # La première étape traite des données dans le schéma public.
  # La seconde consiste à recopier chaque schéma dans la base globale
  # La troisième consistera à faire le nettoyage des schémas.
  #
  # Voir chacune des méthode pour plus de détails.
  #
  class Transformer


    attr_accessor :org_source

    # Etape 1
    # Les modifications aux tables sont les suivantes :
    # Les tables ont toutes un champ tenant_id qui est nul pour les tables
    # User et Tenant (et pour Room, table qui disparaîtra à terme)
    # La table Holders a un champ supplémentaire organism_id
    # La table Room a deux champ supplémentaires : new_org_id et transformed
    # (boolean) pour enregistré les infos de cette étape et pouvoir passer à la
    # deuxième étape.
    #
    # L'objectif de cette étape est de créer les tenants : en pratique chaque
    # user devient un tenant.
    # Puis on remplit le champ tenant_id de la table Holders
    # Puis pour chaque user, on cherche les rooms dont il est propriétaire
    # et on remplit le champ tenant_id correspondant et on crée un
    # un organisme avec les infos qui viennent
    # du schéma.
    def etape1
      nb_rooms = Room.where('new_org_id IS NOT NULL').count
      User.transaction do
        User.find_each do |u|
          # création du tenant
          next unless u.tenants.empty?
          t =  u.tenants.create!
          raise 'Tenant non créé' unless t.is_a? Tenant
          # remplissage du champ tenant pour les holders
          hs = Holder.find_by_sql("select * from holders where user_id = #{u.id}")
          Tenant.set_current_tenant t.id
          hs.each {|h| h.update_attribute(:tenant_id, t.id)}
          # on cherche les rooms appartenant à cet user et on met à jour le
          # champ tenant_id
          u.rooms.each do |r|
            # si le user est le owner, on va créer un organisme
            if r.owner == u
              r.update_attribute(:tenant_id, t.id)
              create_new_org(r.database_name)
              Rails.logger.debug "Traitement de l'organisme #{r.database_name}"
            end
          end

        end
      end
      new_nb_rooms = Room.where('new_org_id IS NOT NULL').count
      return new_nb_rooms - nb_rooms
    end

    # # Petite méthode reprise pour corriger une erreur de efface_tout
    # def etape1bis
    #   Room.find_each do |r|
    #     next if !r.tenant_id || r.new_org_id
    #     Tenant.set_current_tenant r.tenant_id
    #     @org_source = Organism.find_by_sql("select * from #{r.database_name}.organisms limit 1").first
    #     create_new_org(r.database_name)
    #   end
    # end

    # # remplissage des holders à partir des rooms
    # def etape1ter
    #   Room.find_each do |r|
    #     next unless r.tenant_id
    #     Tenant.set_current_tenant r.tenant_id
    #     u = Tenant.current_tenant.users.first
    #     Holder.create!(room_id:r.id, user_id:u.id, status:'owner',
    #                   tenant_id:r.tenant_id, organism_id:r.new_org_id)

    #   end
    # end

    # Ici on remplit la table des holders en complétant le champ organism_id
    # On prend l'ensemble des holders, on prend la room, on trouve l'organisme
    # correspondant et on remplit le champ organism_id
    def etape2
      Tenant.find_each do |t|
        Tenant.set_current_tenant t
        Holder.find_each do |h|
          r = Room.find(h.room_id)
          h.organism_id = r.new_org_id
          h.save
        end
      end
    end

    # étape 3 On dispose maintenant de quelques tables remplies
    # Chaque User a son tenant;
    # La table des organismes est remplie, y compris le champ database_name
    # même si celui-ci pourra être supprimé après la transformation.
    # Chaque Room a été remplie avec le tenant et l'id de l'organisme
    # qui a été créé à l'étape 1.
    #
    # L'étape 3 consiste alors à recopier les différentes tables venant d'un
    # schéma en respectant les relations.
    # Il faut donc lire les tables dans le schéma, connaître les champs
    # references à remplacer, rechercher dans la table flccloner les nouvelles
    # références. Puis enregistrer la nouvelle row ainsi construite ainsi que
    # son id et l'ancien id pour pouvoir passer à la copie d'une table ayant
    # également des références.
    #
    # Dans flccloner, old_org_id devrait toujours être égal à 1.
    #
    def etape3
      delete_trace
      Room.where('tenant_id IS NOT NULL').find_each do |r|
        transformation(r)
      end
    end


    def etape4
      # pour chaque base, reconstruction des folios et rubriks
    end

    def etape5
      # suppression des schémas
    end






    # Appelle successivement les différentes fonctions SQL permettant
    # la recopie des lignes voulues avec maintien des références
    # Attention à l'ordre des tables, puisqu'il y a des dépendances à
    # respecter
    #
    # Toute modification du schéma doit être étudiée ici pour
    # vérifier qu'il n'y a pas d'impact et modifier en conséquence
    #
    #
    def transformation(room)
      if room.transformed?
        puts 'la pièce a déjà été transformée'
        return
      end

      raise 'new_org_id manquant' unless room.new_org_id
      raise 'tenant_id manquant' unless room.tenant_id
      Tenant.set_current_tenant room.tenant_id
        puts "Traitement de la base #{room.database_name}"
        delete_trace
        # ici ajouter l'entrée de l'organisme que l'on va traiter
        # dans la table flccloner.
        uc = Utilities::Cloner.new(name:'Organism', old_id:1, new_id:room.new_org_id,
            old_org_id:1, new_org_id:room.new_org_id)
        uc.save!

      # puis utilisation des ces infos pour appeler successivement toutes
      # les fonctions SQL nécessaires dans l'ordre des demandes
      #
      functions = %w(transform_sectors transform_periods transform_adherent_members
      transform_nomenclatures transform_adherent_payments transform_adherent_coords
      transform_adherent_adhesions transform_adherent_reglements
      transform_bank_accounts transform_cashes transform_bank_extracts transform_cash_controls
      transform_books transform_destinations transform_accounts transform_natures
      transform_writings transform_compta_lines
      transform_bank_extract_lines transform_check_deposits transform_imported_bels
      transform_masks transform_subscriptions transform_adherent_bridges)


      requete = ''
      functions.each do |f|
        requete << "SELECT #{f}('#{room.database_name}', #{1}, #{room.new_org_id}, #{room.tenant_id});"
      end
      Room.transaction do
        Room.connection.execute(requete)
      end
      # reconstruction des folios
      o = Organism.find(room.new_org_id)
      o.send(:reset_folios)
      room.update_attribute(:transformed, true)

    end

    def self.efface_tout
      sql = <<-EOF
        DELETE FROM periods;
        DELETE FROM sectors;
        DELETE FROM accounts;
        DELETE FROM adherent_adhesions;
        DELETE FROM adherent_bridges;
        DELETE FROM adherent_coords;
        DELETE FROM adherent_members;
        DELETE FROM adherent_payments;
        DELETE FROM adherent_reglements;
        DELETE FROM bank_accounts;
        DELETE FROM bank_extract_lines;
        DELETE FROM bank_extracts;
        DELETE FROM books;
        DELETE FROM cash_controls;
        DELETE FROM cashes;
        DELETE FROM check_deposits;
        DELETE FROM compta_lines;
        DELETE FROM destinations;
        DELETE FROM export_pdfs;
        DELETE FROM folios;
        DELETE FROM imported_bels;
        DELETE FROM listings;
        DELETE FROM masks;
        DELETE FROM natures;
        DELETE FROM nomenclatures;
        DELETE FROM rubriks;
        DELETE FROM subscriptions;
        DELETE FROM writings;
        UPDATE rooms SET transformed = FALSE;

      EOF
      Room.transaction do
        Room.connection.execute(sql)

      end
    end

    def self.create_refill_check_deposit_function
      sql = <<-EOF
CREATE OR REPLACE FUNCTION refill_check_deposits(from_schema text, from_id integer, to_id integer, tenant_id integer)
  RETURNS SETOF check_deposits AS
$BODY$
DECLARE
  r RECORD;
BEGIN
FOR r in EXECUTE format('SELECT *, $1 FROM %I.compta_lines WHERE check_deposit_id IN (
    SELECT old_id FROM flccloner WHERE name = %L AND old_org_id = %L AND new_org_id = %L)',
    from_schema, 'CheckDeposit', from_id, to_id)
   USING tenant_id
  LOOP

    UPDATE compta_lines SET check_deposit_id = (SELECT flccloner.new_id FROM flccloner
           WHERE name = 'CheckDeposit'
           AND flccloner.old_id = r.check_deposit_id
           AND old_org_id = from_id AND new_org_id = to_id) WHERE
           compta_lines.id = (SELECT flccloner.new_id FROM flccloner
           WHERE name = 'ComptaLine'
           AND flccloner.old_id = r.id
           AND old_org_id = from_id AND new_org_id = to_id);

  END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
EOF
create_function(sql)
    end


    #   # Création d'un organisme copie de @org_source par
    #   # une reqûete sql avec insertion de l'enregistrement dans la table
    #   # flccloner
    def create_new_org(db_name)
      @org_source = Organism.find_by_sql("select * from #{db_name}.organisms limit 1").first
      Room.find_by_sql("WITH ret AS
(INSERT INTO organisms(title, created_at, updated_at, database_name,
           status, version, comment, siren, postcode, tenant_id)
           VALUES ('#{quote_string @org_source.title}',
           '#{@org_source.created_at}'::timestamp,
           '#{@org_source.updated_at}'::timestamp,
           '#{db_name}',
           '#{quote_string @org_source.status}',
           '#{quote_string @org_source.version}',
           '#{quote_string @org_source.comment}',
           '#{quote_string @org_source.siren}',
           '#{quote_string @org_source.postcode}',
                       #{Tenant.current_tenant_id})
            RETURNING id )
UPDATE rooms SET new_org_id = (SELECT id FROM ret LIMIT 1)
  WHERE database_name = '#{db_name}' RETURNING new_org_id;")

    end

    # # On retire tous les enregistrements de la table flccloner
    def delete_trace
      Room.connection.execute("DELETE FROM flccloner;")
    end



    # méthode de création des fonctions nécessaires à la recopie
    # Sera utilisé dans une migration après mise au point
    def self.create_transformer_functions
      # on commence par les classes de premier niveau
      %w(nomenclatures sectors periods).each do |t|
        create_function(sql_transform_first_level(t))
      end
      # partie Adhérents
      create_clone_adherent_functions
      # les classes de second niveau : bank_account, cash, books et destinations
      # lesquelles ont toutes comme champ secondaire sector_id
      %w(bank_accounts cashes books destinations).each do |t|
        create_function(sql_transform_n_refs('organism_id', ['sector_id'], t))
      end
      # les classes qui découlent directement des précédentes
      # avec un seul champ dépendant
      create_function(sql_transform_one_ref('bank_account_id', 'bank_extracts'))
      create_function(sql_transform_one_ref('cash_id', 'cash_controls'))

      # la partie comptabilité avec les comptes
      create_function(sql_transform_n_refs('period_id',
                                           ['sector_id', 'accountable_id'], 'accounts',
                                           :polymorphic=>'accountable_id'))
      # les natures
      create_function(sql_transform_n_refs('book_id', %w(period_id account_id), 'natures'))
      # puis les écritures
      create_function(sql_transform_n_refs('book_id', ['bridge_id'], 'writings',
                                           bridge_id:Adherent::Member))
      # les remises de chèques (attention à l'ordre)
      create_function(sql_transform_n_refs('bank_account_id',
                                           ['writing_id'], 'check_deposits'))
      # les compta_lines
      create_function(sql_transform_n_refs('writing_id',
                                           %w(nature_id destination_id account_id), 'compta_lines'))
      # et enfin les folios
      create_function(sql_transform_n_refs('nomenclature_id',
                                           %w(sector_id), 'folios'))


      create_clone_mask_functions
      create_clone_bank_functions
      # les données du bridge adhérent
      create_function(sql_transform_n_refs('organism_id',
                                           %w(bank_account_id cash_id destination_id income_book_id),
                                           'adherent_bridges', {modele:Adherent::Bridge, income_book_id:Book}))
      create_refill_check_deposit_function
      # et enfin le holder

    end


    def self.create_clone_mask_functions
      create_function(sql_transform_n_refs('organism_id',
                                           %w(book_id destination_id), 'masks'))
      create_function(sql_transform_one_ref('mask_id', 'subscriptions'))
    end

    def self.create_clone_bank_functions
      create_function(sql_transform_n_refs('bank_extract_id',
                                           %w(compta_line_id), 'bank_extract_lines'))
      create_function(sql_transform_n_refs('bank_account_id',
                                           %w(writing_id nature_id destination_id), 'imported_bels'))
    end

    def self.create_clone_adherent_functions
      # plus Adherent::Member
      create_function(sql_transform_first_level('adherent_members',
                                                modele:Adherent::Member))
      # puis les 3 tables qui découlent de Adherent::Member
      create_function(sql_transform_one_ref('member_id', 'adherent_payments',
                                            modele:Adherent::Payment))
      create_function(sql_transform_one_ref('member_id', 'adherent_coords',
                                            modele:Adherent::Member))
      create_function(sql_transform_one_ref('member_id', 'adherent_adhesions',
                                            modele:Adherent::Adhesion))
      create_function(sql_transform_n_refs('payment_id', ['adhesion_id'],
                                           'adherent_reglements', modele:Adherent::Reglement))
    end

    def quote_string(s)
      return unless s
      s.gsub(/\\/, '\&\&').gsub(/'/, "''")
    end

    # execute la commande sql
    def self.create_function(sql)
      Room.find_by_sql(sql)
    end

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
    def self.sql_transform_first_level(table, options={})
      sql_transform_n_refs('organism_id', [], table, options)
    end



    # Réalise des copies des enregistrements
    # d'une table (argument table) faisant référence à un
    # champ (champ_id) d'une autre table. La différence avec la méthode
    # précédente est juste que organism_id n'est pas le champ_id par défaut.
    #
    # Voir les commentaires de sql_copy_n_refs pour les arguments table et
    # les options
    #
    # Exemple d'utilisation : sql_copy_one_ref('cash_id', 'cash_controls')
    #
    def self.sql_transform_one_ref(champ_id, table, options={})
      sql_transform_n_refs(champ_id, [], table, options)
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
    #  - le nom du modèle lorsque le champ est polymorphique par
    #  une option. Exemple: :polymorphic=>'accountable_id' pour la table Accounts
    #  -
    #
    #
    def self.sql_transform_n_refs(champ_id, champ_ids, table, options= {})

      # on définit ici les variables dont on aura besoin dans le texte sql
      nom_fonction = 'transform_' + table

      begin
        modele = options[:modele] || table.classify.constantize
      rescue NameError
        raise NameError, 'Impossible d\'identifier le modèle ;
vous devez le fournir en deuxième argument'
      end

      # le nom du modèle que l'on cherchera dans la table flc_cloner
      champ = champ_id[0..-4].classify
      # récupération de tous les champs dont on assure la recopie à l'identique
      # ne sont donc pas recopiés le champ id, et les arguments  champ_ids
      list_cols = modele.column_names
      list_cols = list_cols.reject { |c| c == 'id' || c == champ_id || c.in?(champ_ids) || c == 'tenant_id'}
      list  = list_cols.join(', ')
      r_list = list_cols.map { |c| 'r."'+c+'"'}.join(', ')
      # on rajoute des guillemets à cause du champ open de Period, un mot
      # reservé de fait.

      list_champ = champ_ids.join(', ')
      # construction des requêtes cherchant les valeurs dans la table
      # flc_cloner
      values = champ_ids.collect do |cid|
        mod = options[cid.to_sym].to_s
        if options[:polymorphic] == cid
          value_to_insert(cid, mod, polymorphic:true)
        else
          value_to_insert(cid, mod)
        end
      end.join(', ')


      sql = <<-EOF
   CREATE OR REPLACE FUNCTION #{nom_fonction}(from_schema text, from_id integer, to_id integer, tenant_id integer)
   RETURNS SETOF #{table} AS
$BODY$
DECLARE
  r RECORD;
  new_id int;
BEGIN
FOR r in EXECUTE format('SELECT *, $1 FROM %I.#{table} WHERE #{champ_id} IN (
    SELECT old_id FROM flccloner WHERE name = %L AND old_org_id = %L AND new_org_id = %L)',
    from_schema, '#{champ}', from_id, to_id)
   USING tenant_id
  LOOP
    WITH  correspondance AS
    ( INSERT INTO #{table}
       (tenant_id, #{champ_id},
      #{ list_champ + ', ' unless list_champ.empty?}
      #{list})
      VALUES (tenant_id, #{value_to_insert(champ_id)},
      #{values + ', ' unless values.empty?}
      #{r_list})
     RETURNING id, r.id  oldid)
      INSERT INTO flccloner (name, old_id, new_id, old_org_id, new_org_id)
      VALUES ('#{modele}', r.id,
      (SELECT id FROM correspondance WHERE oldid = r.id ), from_id, to_id);
  END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
      EOF

      sql
    end

    # protected

    # Définit le morceau de requête qui permet de trouver dans la table
    # flccloner la valeur souhaitée pour mettre à jour les références.
    #
    # Le deuxième champ permet de préciser le nom du modèle lorsqu'il ne
    # peut être déduit de champ_id. C'est notamment le cas pour
    # la table des Writing dont le champ bridge_id fait référence à
    # Adherent::Member
    #
    # On peut précisier via le hash options si le champ est polymorphique
    def self.value_to_insert(champ_id, champ = nil, options={})
      raise ArgumentError, 'L\'argument doit être de la forme wwww_id' unless
      champ_id =~ /.*_id$/
      champname = champ_to_search(champ_id, champ, options)
      "(SELECT flccloner.new_id FROM flccloner
           WHERE name = #{champname}
           AND flccloner.old_id = r.#{champ_id}
           AND old_org_id = from_id AND new_org_id = to_id)"
    end


    # trouve le nom du champ à rechercher dans la table de correspondance
    # des id (flccloner).
    # Si le champ est polymorphique (cas dans la table Account des
    # BankAccount et Cash (ce qui donne accountable_type et accountable_id)
    def self.champ_to_search(champ_id, champ, options={})
      if options[:polymorphic]
        s =champ_id[0..-4]+'_type'
        s = "r.#{s}"
      else
        s = champ.blank? ? champ_id[0..-4].classify : champ
        s = "'#{s}'"
      end
      return s

    end

  end

end
