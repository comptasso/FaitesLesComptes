# coding: utf-8

# Classe destinée à afficher une general_book des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la general_book par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une general_book et
# affiche show
#
class Compta::GeneralBooksController < Compta::ApplicationController

  include Pdf::Controller # apporte les méthodes pour la production du grand livre en pdf

  before_filter :set_params_gb, :only=>[:show, :create, :produce_pdf]
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

  def new
    @general_book = Compta::GeneralBook.new(period_id:@period.id).with_default_values
  end

  protected

  def set_params_gb
    @params_gb = {period_id:@period.id}.merge(params[:compta_general_book])
  end

  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @period
    @pdf_file_title = 'Grand livre'
  end

  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::GeneralBookPdfFiller.new(Tenant.current_tenant.id,
    pdf_export.id, @params_gb)
  end




end
