# Le module Request contient des classes qui héritent de ActiveRecord::Base
# pour avoir toutes les méthodes qui permettent d'interpréter le résultat 
# d'une Query SQL. 
# 
# L'idée est d'utiliser une classe spécifique lorsque les reqûetes sont 
# vraiment complexes et que un simple joins ou includes ne suffit pas. 
# 
# Une méthode de classe fetch permet d'effectuer la requête. 
# 
# On définit les colonnes en début de classe, on rend ces colonnes accessibles
# pour que la requête puisse remplir les items. 
# 
# TODO voir ici comment gérer une logique similaire à find_each
module Request 
  
  # La class Request::Frontline est destinée à fournir en une seule requête 
  # les informations nécessaires pour l'affichage des lignes dans les livres
  # de recettes et de dépenses. 
  # 
  # Attention, ne fonctionne pas avec un livre d'OD car il n'y a pas de nature
  # TODO si on étend OD pour pouvoir enregistrer des destinations, alors, 
  # il faudra probablement trier sur le type de record.  
  # 
  # Une frontline est initialisée avec un tuple qui vient de la requête.
  # 
  # La méthode de classe fetch permet d'obtenir la collection de tuples
  # 
  class Frontline < ActiveRecord::Base
    
    def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  # les deux derniers champs adherent_member_id et member_id sont normalement
  # identiques. Le premier est obtenu par le champ de la Writing, tandis que le 
  # second est obtenu par le champ de la table des Adhérents. 
  # Il peut donc être nul si l'adhérent a été supprimé. Ceci permet de ne pas 
  # tenter de faire le lien avec le membre dans les line_actions.
  # 
  # TODO on pourrait probablement supprimer adherent_member_id en modifiant 
  # les méthodes frontline_actions. 
  # 

  column :writing_type, :string
  column :nature_name, :string
  column :book_id, :integer
  column :id, :integer
  column :piece_number, :integer
  column :date, :date
  column :date_piece, :date
  column :ref, :string
  column :narration, :string
  column :compta_line_id, :integer
  column :destination_name, :string
  column :debit, :decimal
  column :credit, :decimal
  column :payment_mode, :string
  column :acc_number, :string
  column :acc_title, :string
  column :bel_id, :integer
  column :support_check_id, :integer
  column :support_locked, :boolean
  column :cl_locked, :boolean
  column :adherent_payment_id, :integer
  column :adherent_member_id, :integer
  column :member_id, :integer 
  
    
  # TODO attention : cette requête fonctionne tant que bridge ne renvoie
  # qu'à des adhérents. En cas de nouveau module, il faudra gérer le type 
  # de bridge.
    
    # méthode exécutant la requête
    def self.fetch(book_id, from_date, to_date)
      
      # TODO introduire ici une erreur si le livre n'est pas un income_outcome_book
      sql = <<-hdoc
      SELECT writings.book_id, writings.id, writings.date, writings.piece_number,
      writings.date_piece, writings.ref,
      writings.narration, writings.type AS writing_type, 
      adherent_payments.id AS adherent_payment_id,
      adherent_payments.member_id AS adherent_member_id, 
      (SELECT adherent_members.id AS member_id FROM adherent_members WHERE adherent_members.id = adherent_payments.member_id),
      cls.compta_line_id,
      nature_name, destination_name, cls.debit, cls.credit,
      support.payment_mode AS payment_mode, acc_number, acc_title, bel_id, 
      support_check_id, support_locked, cl_locked
      FROM
      writings LEFT JOIN adherent_payments ON writings.bridge_id = adherent_payments.id, 

      (SELECT compta_lines.id AS compta_line_id, compta_lines.writing_id as wid, 
      natures.name AS nature_name, destinations.name AS destination_name, 
      compta_lines.debit AS debit, compta_lines.credit AS credit, 
      compta_lines.locked AS cl_locked
      FROM compta_lines 
      LEFT JOIN natures ON (natures.id = compta_lines.nature_id)
      LEFT JOIN destinations ON (destinations.id = compta_lines.destination_id)
      WHERE compta_lines.nature_id IS NOT NULL) as cls,
 
      (SELECT compta_lines.writing_id AS wid, payment_mode, 
      accounts.number AS acc_number, accounts.title AS acc_title, 
      bank_extract_lines.id AS bel_id,
      compta_lines.locked AS support_locked,
      compta_lines.check_deposit_id AS support_check_id
      FROM compta_lines 
      LEFT JOIN accounts ON accounts.id = compta_lines.account_id
      LEFT JOIN bank_extract_lines ON bank_extract_lines.compta_line_id = compta_lines.id
      WHERE nature_id IS NULL) as support
      WHERE 
      writings.book_id = '#{book_id}' AND
      cls.wid = writings.id AND support.wid = writings.id AND 
      writings.date >= '#{from_date}' AND 
      writings.date <= '#{to_date}'  
      ORDER BY writings.date
      hdoc
  
      Request::Frontline.find_by_sql( sql)
      
    end
  
    
    
    # reprend la même logique que pour une compta_line
    # une frontline est editable si elle n'est pas verrouillée, si son champ
    # check_deposit_id est nil et s'il n'y a pas de bank_extract_line associée
    def editable?
      !(support_check_id || cl_locked || support_locked || bel_id)
    end
    
     
    
   
  
  end
end
