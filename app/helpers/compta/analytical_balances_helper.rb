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
  
  def h3_title(anabal)
    "Balance analytique : du #{l anabal.from_date} au #{l anabal.to_date}"
  end
  
  
end