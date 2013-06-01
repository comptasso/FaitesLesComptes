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
		files = " FaitesLesComptes/start.rb FaitesLesComptes/app FaitesLesComptes/config FaitesLesComptes/db FaitesLesComptes/lib FaitesLesComptes/log FaitesLesComptes/public FaitesLesComptes/script FaitesLesComptes/vendor FaitesLesComptes/config.ru FaitesLesComptes/Gemfile FaitesLesComptes/Gemfile.lock FaitesLesComptes/Rakefile "
		gems = " --gemfile FaitesLesComptes/Gemfile --gem-full"
		output = " --output FaitesLesComptes.exe --add-all-core  --icon FaitesLesComptes/public/favicon.ico "
		other =   " --no-dep-run --chdir-first --no-lzma --innosetup flc2.iss  -- server -e ocra"
		dlls = " --dll libgdbm_compat-3.dll --dll libgdbm-3.dll --dll libiconv-2.dll --dll libyaml-0-2.dll --dll pdcurses.dll --dll ssleay32.dll --dll zlib1.dll "
		instruction = "ocra " + files + output + gems + dlls + other
		system(instruction)
		Dir.chdir('FaitesLesComptes')
	end
		
	
	
	desc 'appel principal et construction de l installer avec ocra'
	task :build_installer =>[:clean, :copy_files] do
		require '../commenter'
		Commenter.comment('Gemfile', 'Gemfilesave', :assets, :test, :development)
		Rake::Task["ocra:ocra"].invoke
		puts 'Remise en place du Gemfile original'
		mv 'Gemfilesave', 'Gemfile'
	end 
	
 
end
