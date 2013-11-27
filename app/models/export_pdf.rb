class ExportPdf < ActiveRecord::Base
  attr_accessible :content, :exportable_id, :exportable_type, :status
end
