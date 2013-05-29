# coding: utf-8

# fichier de recherche pour automatiser la creation de l'installer

namespace :ocra do
	
	
	desc 'nettoyage des fichiers tmp et log'
	task :clean do
		
		puts 'creation du fichier flc.log'
		file 'log/flc.log' # car non suivi par git
		puts 'Nettoyage des fichiers logs'
		Rake::Task["log:clear"].invoke
		puts 'Nettoyage des fichiers tmp'
		Rake::Task["tmp:clear"].invoke
		
	end
	
	
	desc 'copie des fichiers necessaires'
	task :copy_files do
		puts 'copie des fichiers' 
		cp 'flc2.iss', '../flc2.iss'
		cp 'public/favicon.ico', '../favicon.ico'
	end
	
	desc 'juste la construction du ocra' 
	task :ocra =>[:clean, :copy_files] do
		Dir.chdir('..')
		puts 'appel de ocra'
		system "ocra FaitesLesComptes/start.rb FaitesLesComptes --output FaitesLesComptes.exe --verbose --add-all-core  --icon FaitesLesComptes/public/favicon.ico   --gemfile FaitesLesComptes/Gemfile --gem-full --no-dep-run --chdir-first --no-lzma   -- server -e ocra > log.txt"
		Dir.chdir('FaitesLesComptes')
	end
		
	
	desc 'appel principal et construction de l installer avec ocra'
	task :build_installer =>[:clean, :copy_files] do
		Dir.chdir('..')
		system "bundle install --local --without development test assets"
		puts 'appel de ocra'
		system "ocra FaitesLesComptes/start.rb FaitesLesComptes --output FaitesLesComptes.exe --add-all-core --dll ssleay32-1.0.0-msvcrt.dll --dll sqlite3.dll --icon FaitesLesComptes/public/favicon.ico   --gemfile FaitesLesComptes/Gemfile --gem-full --no-dep-run --chdir-first --no-lzma --innosetup flc2.iss -- server -e ocra"
		puts 'Remise en place du Gemfile original'
		mv 'Gemfilesave', 'FaitesLesComptes/Gemfile'
		Dir.chdir('FaitesLesComptes')
		system "bundle install --local"
	end
 
end
