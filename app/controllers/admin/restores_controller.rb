# coding: utf-8
class Admin::RestoresController < Admin::ApplicationController
   def archive
     tmp_file="#{Rails.root}/tmp/#{@organism.title}_#{@period.exercice}.jcl"
      # Créer un fichier : y écrirer les infos de l'exercice
      File.open(tmp_file, 'w') do |f|
        f.write @organism.to_yaml
        f.write @period.to_yaml
        f.write @organism.destinations.all.to_yaml
        f.write @organism.natures.all.to_yaml
        f.write @organism.bank_accounts.all.to_yaml
        @organism.bank_accounts.all.each do |b|
          f.write b.bank_extracts.all.to_yaml
          b.bank_extracts.all.each do |be|
            f.write be.bank_extract_lines.all.to_yaml
          end
          f.write b.check_deposits.all.to_yaml
        end
        f.write @organism.books.all.to_yaml
        @organism.books.all.each do |b|
          f.write b.lines.all.to_yaml
        end
        f.write @organism.cashes.all.to_yaml
        @organism.cashes.all.each do |c|
          f.write c.cash_controls.all
        end
        f.write @period.accounts.all.to_yaml
      end

    send_file tmp_file, type: 'application/jcl'

  end

  def restore

  end

end