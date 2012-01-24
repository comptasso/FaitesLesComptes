# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
# 
#

class Admin::RestoresController < Admin::ApplicationController

  def new
    
  end

  def create
    # ici on récupère le fichier 
  tmp = params[:file_upload].tempfile
    # TODO vérifier l'extension
  message=''
  message += "Erreur : l'extension du fichier ne correspond pas.\n" unless (params[:file_upload].original_filename =~ /jcl$/)
  if message != ''

      flash[:alert]=message
      render :new
      return
  end
  require_models
  a=Admin::Archive.new
  @datas =  a.parse_file(tmp)

    if a.valid?
        
        @info=a.info
        render :confirm
    else
      message += a.list_errors
      flash[:alert]=message
      render :new
    end
 
 end



   def archive
     tmp_file="#{Rails.root}/tmp/#{@organism.title}_#{@period.exercice}.jcl"
      # Créer un fichier : y écrirer les infos de l'exercice
      arch={}
      arch[:organism]=@organism
      arch[:period]=@period
      arch[:destinations]=@organism.destinations.all
      arch[:natures]=@period.natures.all
      arch[:bank_accounts]=@organism.bank_accounts.all
#      arch[:bank_extracts]= @organism.bank_extracts.period(@period).all
#      arch[:bank_extract_lines]=@organism.bank_extract_lines.period(@period).all
#       arch[:check_deposits]=@organism.check_deposits.period(@period).all
       arch[:books]=@organism.books.all
       arch[:lines]=@organism.lines.period(@period).all
       arch[:cashes]=@organism.cashes.all
#       arch[:cash_controls]=@organism.cash_controls.period(@period)
       arch[:accounts]=@period.accounts.all
      
    File.open(tmp_file, 'w') {|f| f.write arch.to_yaml}
    send_file tmp_file, type: 'application/jcl'

  end

  def restore

  end

  private


  # TODO voir si on ne pourrait pas faire ça dynamiquement 
  def require_models
    require 'destination'
    require 'nature'
    require 'bank_account'
    require 'cash'
    require 'bank_extract'
    require 'line'
    require 'book'
    require 'income_book'
    require 'outcome_book'
    require 'bank_extract_line'
    require 'check_deposit'
    require 'cash_control'
    require 'account'
  end


end