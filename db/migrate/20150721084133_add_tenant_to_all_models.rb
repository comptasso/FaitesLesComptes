class AddTenantToAllModels < ActiveRecord::Migration
  def change
    add_column :accounts, :tenant_id, :integer
    add_index :accounts, :tenant_id

    add_column :adherent_adhesions, :tenant_id, :integer
    add_index :adherent_adhesions, :tenant_id

    add_column :adherent_bridges, :tenant_id, :integer
    add_index :adherent_bridges, :tenant_id

    add_column :adherent_coords, :tenant_id, :integer
    add_index :adherent_coords, :tenant_id

    add_column :adherent_members, :tenant_id, :integer
    add_index :adherent_members, :tenant_id
    add_column :adherent_payments, :tenant_id, :integer
    add_index :adherent_payments, :tenant_id
    add_column :adherent_reglements, :tenant_id, :integer
    add_index :adherent_reglements, :tenant_id
    add_column :bank_accounts, :tenant_id, :integer
    add_index :bank_accounts, :tenant_id
    add_column :bank_extract_lines, :tenant_id, :integer
    add_index :bank_extract_lines, :tenant_id
    add_column :bank_extracts, :tenant_id, :integer
    add_index :bank_extracts, :tenant_id
    add_column :books, :tenant_id, :integer
    add_index :books, :tenant_id
    add_column :cash_controls, :tenant_id, :integer
    add_index :cash_controls, :tenant_id
    add_column :cashes, :tenant_id, :integer
    add_index :cashes, :tenant_id
    add_column :check_deposits, :tenant_id, :integer
    add_index :check_deposits, :tenant_id
    add_column :compta_lines, :tenant_id, :integer
    add_index :compta_lines, :tenant_id
    add_column :destinations, :tenant_id, :integer
    add_index :destinations, :tenant_id
    add_column :export_pdfs, :tenant_id, :integer
    add_index :export_pdfs, :tenant_id
    add_column :folios, :tenant_id, :integer
    add_index :folios, :tenant_id
    add_column :holders, :tenant_id, :integer
    add_index :holders, :tenant_id
    add_column :imported_bels, :tenant_id, :integer
    add_index  :imported_bels, :tenant_id
    
    
    add_column :masks, :tenant_id, :integer
    add_index :masks, :tenant_id
    add_column :natures, :tenant_id, :integer
    add_index :natures, :tenant_id
    add_column :nomenclatures, :tenant_id, :integer
    add_index :nomenclatures, :tenant_id
    add_column :organisms, :tenant_id, :integer
    add_index :organisms, :tenant_id
    add_column :periods, :tenant_id, :integer
    add_index :periods, :tenant_id
    add_column :rooms, :tenant_id, :integer
    add_index :rooms, :tenant_id
    add_column :rubriks, :tenant_id, :integer
    add_index :rubriks, :tenant_id
    add_column :sectors, :tenant_id, :integer
    add_index :sectors, :tenant_id
    add_column :subscriptions, :tenant_id, :integer
    add_index :subscriptions, :tenant_id
    add_column :writings, :tenant_id, :integer
    add_index :writings, :tenant_id

  end
end
