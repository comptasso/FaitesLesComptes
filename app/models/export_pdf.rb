class ExportPdf < ActiveRecord::Base
  attr_accessible :content, :exportable_id, :exportable_type, :status
  
  belongs_to :exportable, :polymorphic=>true
end
