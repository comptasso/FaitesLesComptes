module Compta::AnalyticalBalancesHelper

  def destination_and_sector_name(dest_name, sector_name)
    if @organism.sectored?
      "#{dest_name} (Secteur #{sector_name})"
    else
      dest_name
    end
  end
end