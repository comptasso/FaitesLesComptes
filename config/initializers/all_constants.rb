# coding: utf-8


# REM_CHECK_ACCOUNT sert à créer retrouver le compte remise chèque
# 
# TODO A revoir ???
# Il a donc has_many :accounts, :as=>accountable pour que accountable fonctionne
# et to_s qui retourne 'Chèque à l'encaissement'
# Par ailleurs accountable a été surchargé dans Account pour retourner une instance de RemCheckAccount 
# si le type est RemCheckAccount.
REM_CHECK_ACCOUNT = {number:'511', title:'Chèques à l\'encaissement'}.freeze
RESULT_ACCOUNT = '12'


# constante utilisée pour les éditions de pdf
NB_PER_PAGE_PORTRAIT = 40
NB_PER_PAGE_LANDSCAPE = 22

# constantes utilisées pour les lignes de saise
PAYMENT_MODES = %w(CB Chèque Espèces Prélèvement Virement)
BANK_PAYMENT_MODES = %w(CB Chèque Prélèvement Virement)
DIRECT_BANK_PAYMENT_MODES = %w(CB Prélèvement Virement)


LIST_STATUS = ['Association', 'Comité d\'entreprise', 'Entreprise' ]

# limites de validation
NAME_LENGTH_MIN = 3
NAME_LENGTH_MAX = 30
NAME_LENGTH_LIMITS = NAME_LENGTH_MIN..NAME_LENGTH_MAX

MEDIUM_NAME_LENGTH_MAX = 60

LONG_NAME_LENGTH_MAX = 90
LONG_NAME_LENGTH_LIMITS = NAME_LENGTH_MIN..LONG_NAME_LENGTH_MAX

MAX_COMMENT_LENGTH = 300

# plan comptable
RACINE_BANK = '512'
RACINE_CASH = '53'

LISTING_SELECT = ['writings.id AS w_id', 'writings.date AS w_date',
      'books.abbreviation AS b_abbreviation', 'writings.ref AS w_ref', 
      'writings.narration AS w_narration', 'natures.name AS nat_name',
      'destinations.name AS dest_name', 'debit',  'credit']
