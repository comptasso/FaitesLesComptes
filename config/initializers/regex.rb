# des regex pour faciliter les validations de format avec des caractères accentués

ALNUM = '[a-zA-Z0-9]|[\u00e0-\u00ef]'
WORDCHARS =  '[a-zA-Z0-9]|[\u00e0-\u00ef]|\s|[@&_\-\']'
WORD = "((#{ALNUM})((#{WORDCHARS})*(#{ALNUM}))?)"
NAME_REGEX = /^#{WORD}$/