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

# chiffre, lettre et caractères accentués
ALNUM = '[a-zA-Z0-9]|[\u00e0-\u00ff]|[€]'
# les mêmes plus le point final, point d'interrogation et parenthèse fermante
ALNUMEND = '[a-zA-Z0-9]|[\u00e0-\u00ff]|[\?)€\.]' 
# les mêmes plus les espaces ainsi que () ° @ & / - +' , et .
WORDCHARS =  '[a-zA-Z0-9]|[\u00e0-\u00ff]|\s|[\u0153€@()&_\*\:°\-\+\'\.\/,]' 
 # on regroupe le tout
WORD = "((#{ALNUM})((#{WORDCHARS})*(#{ALNUMEND}))?)" 
NAME_REGEX = /\A#{WORD}\Z/ # pour obtenir le name_regex
