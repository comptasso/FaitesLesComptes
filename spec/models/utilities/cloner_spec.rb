# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
#    c.filter =  {wip:true}
end

describe Utilities::Cloner do
  include OrganismFixtureBis

  before(:each) do
    Tenant.set_current_tenant(1)
    use_test_organism
    @cl = Utilities::Cloner.new(old_org_id:@o.id)
  end

  after(:each) do
    Organism.find_by_sql('DELETE FROM flccloner;')
    Organism.where('comment = ?', 'testclone').each {|o| o.destroy}
    Organism.where('comment = ?', "aujourd'hui").each {|o| o.destroy}
  end

  it 'clone_organism crée un nouvel organisme' do
    expect {@cl.clone_organism("aujourd'hui")}.to change{Organism.count}.by(1)
  end

  it 'clone double les secteurs' do
    expect {@cl.clone_organism('testclone')}.
      to change{Sector.count}.by(@o.sectors.count)
  end

  it 'clone double les exercices' do
    expect {@cl.clone_organism('testclone')}.
      to  change{Period.count}.by(@o.periods.count)
  end

  context 'vérification du clone' do

    before(:each) do
      @cl.clone_organism('testclone')
      @norg = Organism.where('comment = ?', 'testclone').first
    end

    it 'cet organisme a le même tenant' do
      expect( @norg.tenant_id).to eq(@o.tenant_id)
    end

    it 'les secteurs sont identiques' do
      champs_identiques = Sector.column_names.reject {|f| f == 'id' || f == 'organism_id'}
      @norg.sectors.each do |s|
        oldsect = @o.sectors.where('name = ?', s.name).first
        champs_identiques.each do |champ|
          expect(s.send(champ)).to eq oldsect.send(champ)
        end
      end
    end


    it 'les livres sont similaires', wip:true do
      champs_identiques = Book.column_names.
        reject { |f| f != 'tenant_id' && (f =~ /.*id$/)}
      @norg.books.each do |b|
        oldbook = @o.books.where('title = ?', b.title).first
        champs_identiques.each do |champ|
          expect(b.send(champ)).to eq oldbook.send(champ)
        end
      end
    end



    it 'les natures sont identiques pour les champs conservés' do
      expect(@o.natures.count).to eq(@norg.natures(true).count)
      champs_identiques = Nature.column_names.reject do |f|
        f != 'tenant_id' && (f =~ /.*id$/) # || f =~ /.*_at$/)
      end
      @norg.in_out_books.each do |b|
         oldbook = @o.books.where('title = ?', b.title).first


        b.natures.each do |r|
          per = r.period
          oldper = @o.periods.where('start_date = ?', per.start_date).first
          oldnat = Nature.
            where('name = ? AND period_id = ? AND book_id = ?',
                  r.name, oldper.id, oldbook.id ).first
          champs_identiques.each do |champ|
            # if r.send(champ) != oldnat.send(champ)
            #   puts "différence dans la nature #{champ}"
            #   puts "id des exercices - nouveau : #{per.id} - ancien : #{oldper.id}"
            #   puts "id des livres - nouveau : #{b.id} - ancien : #{oldbook.id}"
            #   puts "Nouvelle nature #{r.inspect}"
            #   puts "ancienne nature #{oldnat.inspect}"
            # end
            expect(r.send(champ)).to eq oldnat.send(champ)
          end
        end
      end
    end

    it 'l exercice est similaire pour les champs conservés' do
      expect(@o.periods.count).to eq(@norg.periods(true).count)
      champs_identiques = Period.column_names.reject do |f|
        f != 'tenant_id' && (f =~ /.*id$/)
      end
      @norg.periods(true).each do |r|
         oldper = @o.periods.where('start_date = ?', r.start_date).first
         # puts oldper.inspect
         champs_identiques.each do |champ|
           expect(r.send(champ)).to eq oldper.send(champ)
         end
      end

    end

    it 'la banque et le compte de la banque sont disponibles' do
      nba = @norg.bank_accounts.first
      np = @norg.periods.first
      expect(nba.number).to eq(@ba.number)
      expect(nba.current_account(np)).to eq @baca
    end

    it 'la caisse et le compte de la caisse sont disponibles' do
      nca = @norg.cashes.first
      np = @norg.periods.first
      expect(nca.name).to eq @c.name
      expect(nca.current_account(np)).to eq @caca
    end

    it 'les destinations sont similaires' do
      champs_identiques = Destination.column_names.reject do |f|
        f != 'tenant_id' && (f =~ /.*id$/)
      end
        @norg.destinations.each do |dest|
          oldsect = @o.sectors.where('name = ?', dest.sector.name).first
           olddest = @o.destinations.where('name =  ? AND sector_id = ?',
             dest.name, oldsect.id).first
           champs_identiques.each do |champ|
             expect(dest.send(champ)).to eq olddest.send(champ)
           end
         end

    end

    it 'les comptes sont similaires pour chacun des exercices' do
      champs_identiques = Account.column_names.reject do |f|
        f != 'tenant_id' && (f =~ /.*id$/)
      end
      @norg.periods(true).each do |per|
         oldper = @o.periods.where('start_date = ?', per.start_date).first
         # puts oldper.inspect
         per.accounts.each do |acc|
           oldacc = oldper.accounts.where('number = ?', acc.number).first
           champs_identiques.each do |champ|
             expect(acc.send(champ)).to eq oldacc.send(champ)
           end
         end
      end

    end

  end

  context 'avec une écriture dans un organisme', wip:true do

    before(:each) do
      create_outcome_writing
      create_transfer
      @cl.clone_organism('testclone')
      @norg = Organism.where('comment = ?', 'testclone').first
    end

    after(:each) do
      erase_writings
    end

    it 'l ecriture est recopiee' do
      expect(@norg.writings.count).to eq(@o.writings.count)
    end

    it 'les champs significatifs sont identiques' do
      champs_identiques = Writing.column_names.reject do |f|
        f != 'tenant_id' && (f =~ /.*id$/)
      end
      @norg.writings.each do |w|
        oldw = @o.writings.where('piece_number= ?', w.piece_number).first
        champs_identiques.each do |champ|
          expect(w.send(champ)).to eq oldw.send(champ)
        end
      end

    end

    it 'les compta_lines sont recopiées' do
      champs_identiques = ComptaLine.column_names.reject do |f|
        f != 'tenant_id' && (f =~ /.*id$/)
      end
      @norg.compta_lines.each do |cl|
        oldw = @o.writings.where('piece_number = ?', cl.writing.piece_number).first
        oldcl = @o.compta_lines.where('writing_id = ? AND debit = ?',
           oldw.id, cl.debit).first
        champs_identiques.each do |champ|
          expect(cl.send(champ)).to eq oldcl.send(champ)
        end
      end

    end


  end
  # TODO poursuivre les tests pour chacun des modèles
  # Il manque par exemple les subscriptions et quelques autres modèles
  # secondaires.

end
