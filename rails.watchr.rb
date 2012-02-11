# Run me with:
#
#   $ watchr specs.watchr

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------

#START:SPECS
watch('^spec/(.*)_spec\.rb') do |m|
  puts "Modification de #{m[1]}"
  run_test_matching(m[1])
end
watch('^app/(.*)\.rb') { |m| puts "Modification de #{m[1]}"; run_test_matching(m[1]) }
watch('^app/(.*)\.erb') { |m|  puts "Modification de #{m[1]}"; run_test_matching(m[1]) }
#END:SPECS


#START:MIGRATION
watch('^db/migrate/(.*)\.rb') { |m| check_migration(m[1]) }
#END:MIGRATION

#START:ALL_TESTS
watch('^spec/spec_helper\.rb') { run_all_tests }
watch('^app/views/layouts/.*\.erb') { run_all_tests }
#END:ALL_TESTS

#START: SCSS with SASS --CHECK
watch('^app/assets/stylesheets/(.*\.scss)') do |m|
    check_scss(m[1])
    puts "checked #{m[1]}"
end
# END: SCSS

#START: JS
watch('^(app/assets/javascripts/(.*)\.js)') do |m|
 jslint_check("#{m[1]}")
end

watch('^(spec/javascripts/(.*)\.js)') do |m|
 jslint_check("#{m[1]}")
end

#START:SPECS
def all_specs
  Dir['spec/**/*_spec.rb']
end

def run_test_matching(thing_to_match)
  matches = all_specs.grep(/#{thing_to_match}/i)
  run matches.join(' ') unless matches.empty?
end

def run(files_to_run)
  system("clear;rspec --drb #{files_to_run}")
end
#END:SPECS

#START:ALL_TESTS
def run_all_tests
  @all_tests_passing = run(all_specs.join(' '))
  puts 'All tests pass' if @all_tests_passing
end

def run_test_matching(thing_to_match)
  matches = all_specs.grep(/#{thing_to_match}/i)
  if matches.any?
    @all_tests_passing &= run(matches.join(' '))
    run_all_tests unless @all_tests_passing
  end
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
 system('clear')
 puts "checking #{files_to_check}"
 system("jslint #{files_to_check}")
end