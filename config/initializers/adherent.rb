require 'milia/base'
# Ces lignes ont pour but d'apporter aux tables du module
# Adherent, le comportement apporté par le gem Milia
require 'adherent/member'
class Adherent::Member; acts_as_tenant; end
require 'adherent/coord'
class Adherent::Coord; acts_as_tenant; end
require 'adherent/adhesion'
class Adherent::Adhesion; acts_as_tenant; end
require 'adherent/payment'
class Adherent::Payment; acts_as_tenant; end
require 'adherent/reglement'
class Adherent::Reglement; acts_as_tenant; end
