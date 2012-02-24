# Run me with:
#
#   $ watchr specs.watchr

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------

#START:SPECS
watch('^spec/(.*)_spec\.rb') do |m|
  puts 'Dans watch ^spec'
  puts "Modification de #{m[1]}"
  run_test_matching(m[1])
end
watch('^app/(.*)\.rb') { |m| puts 'Dans watch ^app rb'; puts "Modification de #{m[1]}"; run_test_matching(m[1]) }
watch('^app/(.*)\.erb') { |m| puts 'Dans watch ^app erb';  puts "Modification de #{m[1]}"; run_test_matching(m[1]) }
#END:SPECS


#START:MIGRATION
watch('^db/migrate/(.*)\.rb') { |m| puts 'Dans watch migration'; check_migration(m[1]) }
#END:MIGRATION

#START:ALL_TESTS
watch('^spec/spec_helper\.rb') {puts 'Dans watch spec_helper et donc all tests'; run_all_tests }
watch('^app/views/layouts/.*\.erb') { puts 'Dans watch layouts et donc all tests';run_all_tests }
#END:ALL_TESTS

#START: SCSS with SASS --CHECK
watch('^app/assets/stylesheets/(.*\.scss)') do |m|
  puts 'Dans watch .scss avec appel de check_scss';
    check_scss(m[1])
    puts "checked #{m[1]}"
end
# END: SCSS

#START: JS
watch('^(app/assets/javascripts/(.*)\.js)') do |m|
 jslint_check("#{m[1]}")
end

watch('^(spec/javascripts/(.*)\.js)') do |m|
  puts 'Dans watch .scss avec appel de jslint';
 jslint_check("#{m[1]}")
end

#START:SPECS

def run(files_to_run)
 # system("rspec --drb --format doc #{files_to_run}")
  system("rspec --drb #{files_to_run}")
end
#END:SPECS


#START:ALL_TESTS
def all_specs
  Dir['spec/**/*_spec.rb']
end





def run_test_matching(thing_to_match)

  matches = all_specs.grep(/#{thing_to_match}/i)
  puts 'Aucun fichier spec matching' if matches.empty?
  puts matches.join(';' ) unless matches.empty?
  run(matches.join(' ')) unless matches.empty?

  if !matches.empty? && run(matches.join(' '))
    run_all_tests unless @all_tests_passing
  end
end

def run_test_erb_matching(thing_to_match)
  matches= all_specs.grep(/#{thing_to_match}/i)
  puts 'Aucun fichier spec matching' if matches.empty?
  puts matches.join(';' ) unless matches.empty?

end

def run_all_tests
  @all_tests_passing = run(all_specs.join(' '))
  puts 'All tests pass' if @all_tests_passing
end



#END:ALL_TESTS

def check_scss(scss_file)
    system("clear; sass --check app/assets/stylesheets/#{scss_file}" )
end

def check_migration migration_file
    system("clear; rake db:migrate:reset RAILS_ENV=test --trace")
    run_test_matching(migration_file)
end

def jslint_check(files_to_check)
 # system('clear')
 puts "checking #{files_to_check}"
 system("jslint #{files_to_check}")
end