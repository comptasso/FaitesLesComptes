# Admin::VersionController est destiné à permettre la mise à jour des versions
# lorsque l'on change de version de logiciel ou lorsqu'on importe une base
# qui a été créée dans une version antérieure.
#
# Il y a plusieurs cas de figure qui sont traités, soit par version_controller, soit
# par rooms_controller.
#
# Nous expliquons ici les deux cas:
#
# == Premier cas de figure
# Il s'agit du cas le plus fréquent et que je cherche à gérer; cas où l'utilisateur
# est allé chercher une version mise à jour
# du fichier .exe et a substitué dans son PC, cette version à  la précédente.
#
#  Il faut donc mettre à jour l'ensemble des bases. C'est ce que fait version_controller
#  qui est appelé par le before_filter control_version de ApplicationController.
#
#  On considère que cette manipulation doit concerner l'ensemble des bases
#
# == Deuxième cas de figure
# On importe un fichier par le restore_controller : ce fichier peut être d'une
# version postérieure ou antérieure à la version actuelle du programme.
# Dans ce cas, le controller restore renvoie sur la page Rooms#index avec une information
# de ce qu'il faut faire au travers du flash.
#
# == Troisième cas de figure
# A priori à éviter; on a substitué directement des fichiers sqlite3 dans le répertoire
# des bases de données. On pourrait donc avoir des bases postérieures à la base présente
#
# 
#
class Admin::VersionsController < ApplicationController

  skip_before_filter :control_version
  skip_before_filter :log_in?


  # GET new pour demander si on veut effectivement faire migrer les bases de données
  def new

  end

  # POST migrate_each pour migrer l'ensemble des bases de données
  def migrate_each
    Room.migrate_each # migre Room et les différentes bases
    Rails.cache.clear('version_update')
    redirect_to admin_organisms_url
  end

end
