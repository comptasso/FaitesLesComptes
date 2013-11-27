class CreateExportPdfs < ActiveRecord::Migration
  def change
    create_table :export_pdfs do |t|
      t.binary :content
      t.string :exportable_type
      t.integer :exportable_id
      t.string :status

      t.timestamps
    end
  end
end
