# coding: utf-8

# La classe restore fait les différentes opérations de restauration d'un fichier
#
#

require 'organism'
require 'period'
require 'bank_account'
require 'destination'
require 'nature'
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

class Admin::ArchivesController < Admin::ApplicationController
  def index
    @archives=@organism.archives.all
  end

  def show
    @archive=@organism.archives.find(params[:id])
  end

  def new
    @archive=@organism.archives.new
  end

  def create
    @organism=Organism.find(params[:organism_id])
    @archive=@organism.archives.new(params[:archive])
    tmp_file_name="#{Rails.root}/tmp/#{@organism.title}.yml"
     if @archive.save
      @archive.collect_datas
      File.open(tmp_file_name, 'w') {|f| f.write @archive.datas.to_yaml}
      send_file tmp_file_name, type: 'text/yml'
      File.delete(tmp_file_name)
    else
      render new
    end
  end




end
