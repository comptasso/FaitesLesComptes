desc "Run watchr"
task :watchr do
  sh %{bundle exec watchr railswatchr.rb}
end