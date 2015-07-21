# TODO faire commentaires
class ExportPdf < ActiveRecord::Base
  # attr_accessible :content, :exportable_id, :exportable_type, :status

  acts_as_tenant
  belongs_to :exportable, :polymorphic=>true


  def ready?
    self.status == 'ready'
  end
end
