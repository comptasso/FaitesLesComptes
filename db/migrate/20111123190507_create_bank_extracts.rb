class CreateBankExtracts < ActiveRecord::Migration
  def change
    create_table :bank_extracts do |t|
      t.integer :listing_id
      t.string :reference
      t.date :begin_date
      t.date :end_date
      t.decimal :begin_sold,scale: 10, precision: 2,  default: 0
      
      t.decimal :total_debit,scale: 10, :precision=>2, default: 0
      t.decimal :total_credit, scale: 10,:precision=>2, default: 0
      t.boolean :locked, :default=> false
      t.timestamps
    end

    add_column :lines, :bank_extract_id, :integer
  end
end
