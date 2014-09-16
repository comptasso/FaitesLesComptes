module Compta::AnalyticalBalancesHelper

  def destination_and_sector_name(dest_name, sector_name)
    if @organism.sectored?
      dest_name 
      dest_name += " (Secteur #{sector_name})" unless sector_name.blank?
      dest_name
    else
      dest_name
    end
  end
  
  
end