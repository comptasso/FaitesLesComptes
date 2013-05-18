# des regex pour faciliter les validations de format avec des caractères accentués

ALNUM = '[a-zA-Z0-9]|[\u00e0-\u00ff]'
ALNUMEND = '[a-zA-Z0-9]|[\u00e0-\u00ff]|[\.]'
WORDCHARS =  '[a-zA-Z0-9]|[\u00e0-\u00ff]|\s|[\u0153@&_\-\'\.,]'
WORD = "((#{ALNUM})((#{WORDCHARS})*(#{ALNUMEND}))?)"
NAME_REGEX = /^#{WORD}$/