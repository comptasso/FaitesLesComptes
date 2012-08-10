class Room < ActiveRecord::Base
  belongs_to :user



  def organism
    look_in(database_name) { Organism.first }
  end


  def look_in(database, &block)
    use_org_connection(database)
    r = yield
    use_main_connection
    return r
  end


  protected

  def use_main_connection
    # FIXME utiliser une fonction de Rails plutôt que le database construit
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "db/development.sqlite3")
  end

  def use_org_connection(db_name)
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "db/organisms/#{db_name}.sqlite3")
  end

end
