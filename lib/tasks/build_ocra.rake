# coding: utf-8

# fichier de recherche pour automatiser la creation de l'installer

namespace :ocra do
	
	
	desc 'nettoyage des fichiers tmp et log'
	task :clean do
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
	
	
	desc 'appel de ocra'
	task :build_installer =>[:clean, :copy_files] do
		Dir.chdir('..')
		puts 'appel de ocra'
		system "ocra FaitesLesComptes/start.rb FaitesLesComptes --output FaitesLesComptes.exe --add-all-core --dll ssleay32-1.0.0-msvcrt.dll --dll sqlite3.dll --icon FaitesLesComptes/public/favicon.ico   --gemfile FaitesLesComptes/Gemfile --gem-full --no-dep-run --chdir-first --no-lzma --innosetup flc2.iss -- server mongrel -e ocra"
	end
 
end
