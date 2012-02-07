watch('^app/assets/stylesheets/(.*\.scss)') do |m|
    check_scss(m[1])
    puts "checks #{m[1]}"
end
watch('^db/migrate/(.*)\.rb') {|m| check_migration(m[1]) }

def check_scss(scss_file)
    system("clear; sass --check app/assets/stylesheets/#{scss_file}" )
end

def check_migration migration_file
    system("clear; rake db:migrate:reset RAILS_ENV=test --trace")
end