module Adherent
# On rajoute pour chaque modèle de Adherent l'instruction
# acts_as_tenant de façon à ce que les adhérents soient
# aient la même logique de rattachement.
#
# TODO décider si on met cette logique dans le gem Adherent ou si
# on la laisse ici définitivement
#

  class Member; acts_as_tenant; end
  class Coord; acts_as_tenant; end
  class Adhesion; acts_as_tenant; end
  class Payment; acts_as_tenant; end
  class Reglement; acts_as_tenant; end

  def self.table_name_prefix
    'adherent_'
  end
end
