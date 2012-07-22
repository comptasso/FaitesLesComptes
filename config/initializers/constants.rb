# coding: utf-8

 # organism est traité à part car c'est le modèle mère de tous les autres et du coup, il est au singulier dans archive ou restore
  # pour que l'archive fonctionne, il faut que le modèle organism puisse accéder à tous les autres modèles directement ou au travers de through
  # ne pas oublier d'ajouter les nouveaux modèles en cas d'évolution de l'architecture de la base
  # ne pas oublier de redémarrer le serveur en cas de modification de ce fichier
  ORGANISM = ['organism']
  MODELS = %w(period bank_account destination line bank_extract check_deposit cash cash_control book account nature bank_extract_line income_book outcome_book od_book transfer)
  ORGMODELS = ORGANISM + MODELS

  NB_PER_PAGE_PORTRAIT = 40
  NB_PER_PAGE_LANDSCAPE = 22

