

namespace :elasticsearch do
	task :reindex => :environment do 
		GoLink.import
	end
end