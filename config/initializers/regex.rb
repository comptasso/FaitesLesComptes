# des regex pour faciliter les validations de format avec des caractères accentués


# Définition des constantes pour les REGEX
#
# NAME_REGEX doit commercer par un chiffre, une lettre minuscule ou majuscule ou encore
# minuscule accentuée.
#
# Ce premier caractère est suivi par autant de caractères du même type mais ce peut être
# aussi le signe @ ou & ou un point ou une virgule ou une apostrophe
#
# Le dernier caractère de la chaîne ne peut être qu'un ALNUM ou un point pour marquer la fin
# de la phrase. Par exemple pour un commentaire.
#
ALNUM = '[a-zA-Z0-9]|[\u00e0-\u00ff]|[€]'    # chiffre, lettre et caractères accentués
ALNUMEND = '[a-zA-Z0-9]|[\u00e0-\u00ff]|[\?)€\.]' # les mêmes plus le point final, point d'interrogation et parenthèse fermante
WORDCHARS =  '[a-zA-Z0-9]|[\u00e0-\u00ff]|\s|[\u0153€@()&_\:°\-\'\.\/,]' # les mêmes plus les espaces ainsi que () ° @ & / - ' , et .
WORD = "((#{ALNUM})((#{WORDCHARS})*(#{ALNUMEND}))?)"  # on regroupe le tout
NAME_REGEX = /\A#{WORD}\Z/ # pour obtenir le regex
